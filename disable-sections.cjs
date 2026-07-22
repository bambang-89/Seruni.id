const fs = require('fs');
let content = fs.readFileSync('src/seruni/HomePage.tsx', 'utf8');

// Find and replace each section with null
const sections = ['S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12'];

for (const name of sections) {
  // Simple replace: function S1() { ... } -> function S1() { return null; }
  const regex = new RegExp(`function ${name}\\(\\) \\{`, 'g');
  content = content.replace(regex, `function ${name}() { return null; // `);
  console.log(`Processed ${name}`);
}

fs.writeFileSync('src/seruni/HomePage.tsx', content);
console.log('Done');
