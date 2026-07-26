import fs from 'fs';

const filePath = 'supabase/migrations/20260731000001_surat_template_system.sql';
let content = fs.readFileSync(filePath, 'utf8');

// Replace: CREATE POLICY "name" ON table ...
// With: DROP POLICY IF EXISTS "name" ON table; CREATE POLICY "name" ON table ...
const policyRegex = /CREATE\s+POLICY\s+["']([^"']+)["']\s+ON\s+(?:public\.)?([a-zA-Z0-9_-]+)/g;

let match;
const replacements = [];

// Reset regex state
policyRegex.lastIndex = 0;
while ((match = policyRegex.exec(content)) !== null) {
  const policyName = match[1];
  const tableName = match[2];
  const fullMatch = match[0];
  
  replacements.push({
    target: fullMatch,
    replacement: `DROP POLICY IF EXISTS "${policyName}" ON public.${tableName};\n${fullMatch}`
  });
}

// Apply replacements backwards to not mess up indices
replacements.reverse().forEach(r => {
  content = content.replace(r.target, r.replacement);
});

fs.writeFileSync(filePath, content);
console.log('✅ Added DROP POLICY IF EXISTS before all policy creations in add_image_columns.sql');
