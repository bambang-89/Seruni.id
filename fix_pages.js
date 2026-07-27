
const fs = require('fs');

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Remove eyebrow, judul, deskripsi props from EditorialLayout
  content = content.replace(/<EditorialLayout\s+([^>]*?)>/gs, (match, p1) => {
    let newProps = p1
      .replace(/eyebrow=[^]*/g, '')
      .replace(/eyebrow=\x22[^\x22]*\x22/g, '')
      .replace(/judul=[^]*/g, '')
      .replace(/judul=\x22[^\x22]*\x22/g, '')
      .replace(/deskripsi=\{[^]*\}/g, '')
      .replace(/deskripsi=\x22[^\x22]*\x22/g, '')
      .replace(/\s+/g, ' ')
      .trim();
    return '<EditorialLayout\n        ' + newProps + '\n      >';
  });

  // Remove Seo tags
  content = content.replace(/<Seo[^>]*\/>/g, '');

  fs.writeFileSync(filePath, content);
  console.log('Fixed', filePath);
}

processFile('e:/Seruni.id/src/seruni/pages.tsx');
processFile('e:/Seruni.id/src/seruni/PartisipasiPages.tsx');
processFile('e:/Seruni.id/src/seruni/PendudukPages.tsx');

