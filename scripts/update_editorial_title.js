const fs = require('fs');
const file = 'src/seruni/pages.tsx';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(/<EditorialTitle\s+kicker=\{?["'](.+?)["']\}?\s+judul=\{?["']([^"']+)["']\}?\s*\/>/g, (match, p1, p2) => {
  const slug = (p1 + '-' + p2).toLowerCase().replace(/[^a-z0-9]+/g, '-');
  return match.replace('<EditorialTitle', '<EditorialTitle sectionKey="' + slug + '"');
});

// Also handle dynamic judul like judul={g.j}
content = content.replace(/<EditorialTitle\s+kicker=\{?["'](.+?)["']\}?\s+judul=\{([^}]+)\}\s*\/>/g, (match, p1, p2) => {
  const slug = p1.toLowerCase().replace(/[^a-z0-9]+/g, '-');
  return match.replace('<EditorialTitle', '<EditorialTitle sectionKey="' + slug + '"');
});

fs.writeFileSync(file, content);
