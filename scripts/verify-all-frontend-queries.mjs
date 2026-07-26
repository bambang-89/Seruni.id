import fs from 'fs';
import path from 'path';

const schema = JSON.parse(fs.readFileSync('scripts/db-schema-reference.json', 'utf8'));

// Helper to recursively get files
function getFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const name = path.join(dir, file);
    if (fs.statSync(name).isDirectory()) {
      if (!file.startsWith('.') && file !== 'node_modules' && file !== 'dist') {
        getFiles(name, fileList);
      }
    } else {
      if (file.endsWith('.ts') || file.endsWith('.tsx')) {
        fileList.push(name);
      }
    }
  }
  return fileList;
}

const files = getFiles('src').concat(getFiles('supabase/functions'));
console.log(`🔍 Found ${files.length} TypeScript files to scan.\n`);

let totalIssues = 0;

// Regex to find table queries like: .from("table_name") or .from('table_name')
const fromRegex = /\.from\s*\(\s*['"`]([a-zA-Z0-9_-]+)['"`]\s*\)/g;

// Regex to find select columns
const selectRegex = /\.select\s*\(\s*['"`]([^'"`]+)['"`]\s*\)/g;

files.forEach(filePath => {
  const content = fs.readFileSync(filePath, 'utf8');
  let match;
  
  // Reset regex state
  fromRegex.lastIndex = 0;
  
  while ((match = fromRegex.exec(content)) !== null) {
    const tableName = match[1];
    const index = match.index;
    
    // Skip storage buckets
    const matchPrefix = content.substring(Math.max(0, index - 20), index);
    if (matchPrefix.includes('storage')) {
      continue;
    }
    
    // Get line number
    const linesUpToMatch = content.substring(0, index).split('\n');
    const lineNumber = linesUpToMatch.length;
    
    // Check if table exists
    if (!schema[tableName]) {
      console.log(`❌ [TABLE NOT FOUND] ${filePath}:${lineNumber} -> Table "${tableName}" does not exist in the database schema.`);
      totalIssues++;
      continue;
    }

    // Try to find select block following the .from call
    const context = content.substring(index, index + 300);
    const nextFromIndex = context.indexOf('.from', 1);
    
    selectRegex.lastIndex = 0;
    const selectMatch = selectRegex.exec(context);
    
    if (selectMatch && (nextFromIndex === -1 || selectMatch.index < nextFromIndex)) {
      const selectStr = selectMatch[1].trim();
      // Only check simple column selections (comma separated, no complex joins or aliases)
      if (selectStr !== '*' && !selectStr.includes('(') && !selectStr.includes(':')) {
        const columns = selectStr.split(',').map(c => c.trim()).filter(c => c && !c.includes('*'));
        columns.forEach(col => {
          if (!schema[tableName].includes(col)) {
            console.log(`❌ [COLUMN NOT FOUND] ${filePath}:${lineNumber} -> Column "${col}" does not exist in table "${tableName}".`);
            totalIssues++;
          }
        });
      }
    }

    // Let's also check inserts and updates
    // We look for objects being passed to .insert(object) or .update(object)
    // We do a simple regex check for keys in objects in context
    const insertOrUpdateRegex = /\.(insert|update)\s*\(\s*({[\s\S]*?}|\[[\s\S]*?\])\s*\)/g;
    insertOrUpdateRegex.lastIndex = 0;
    const actionMatch = insertOrUpdateRegex.exec(context);
    if (actionMatch && (nextFromIndex === -1 || actionMatch.index < nextFromIndex)) {
      const objStr = actionMatch[2];
      
      // Strip nested objects to avoid matching their nested keys as table columns
      let strippedObjStr = objStr;
      let prevStr;
      do {
        prevStr = strippedObjStr;
        strippedObjStr = strippedObjStr.replace(/{[^{}]*}/g, '{}');
      } while (strippedObjStr !== prevStr);

      // Extract keys from simple object literals: key: or "key": or 'key':
      const keyRegex = /([a-zA-Z0-9_-]+)\s*:/g;
      let keyMatch;
      const keys = [];
      while ((keyMatch = keyRegex.exec(strippedObjStr)) !== null) {
        keys.push(keyMatch[1]);
      }
      keys.forEach(key => {
        // Exclude common javascript properties or keywords
        if (['true', 'false', 'null', 'undefined'].includes(key)) return;
        if (!schema[tableName].includes(key)) {
          console.log(`❌ [WRITE COLUMN NOT FOUND] ${filePath}:${lineNumber} -> Writing column "${key}" which does not exist in table "${tableName}".`);
          totalIssues++;
        }
      });
    }
  }
});

console.log(`\n📢 Audit finished. Total issues found: ${totalIssues}`);
if (totalIssues > 0) {
  process.exit(1);
} else {
  console.log('✅ All frontend and Edge Function database queries are fully aligned with the Supabase schema!');
  process.exit(0);
}
