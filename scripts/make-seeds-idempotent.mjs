#!/usr/bin/env node
// Make all seed INSERT statements idempotent by adding ON CONFLICT DO NOTHING
// Strategy: find each INSERT's semicolon and add ON CONFLICT before it
import fs from 'fs';
import path from 'path';

const migrationsDir = 'supabase/migrations';
const files = fs.readdirSync(migrationsDir).filter(f => f.endsWith('.sql'));

// Tables with known unique constraints for ON CONFLICT
const conflictTargets = {
  berita: 'slug',
  agenda: 'slug',
  pengumuman: 'nomor',
  wilayah_dusun: 'nama',
  idm_status_desa: 'tenant_id',
  usulan_warga: 'nomor_tiket',
  aduan_warga: 'nomor_tiket',
  dashboard_agregat: ['kategori', 'metrik_key', 'periode'],
  layanan_statistik: ['tenant_id', 'jenis_layanan', 'periode'],
  ref_aduan_kategori: 'kode',
  posyandu_balita: 'nik',
};

let totalModified = 0;

for (const filename of files) {
  const filepath = path.join(migrationsDir, filename);
  let content = fs.readFileSync(filepath, 'utf8');
  const original = content;

  for (const [table, conflictCol] of Object.entries(conflictTargets)) {
    const escapedTable = table.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

    // Find each INSERT INTO table ... VALUES ... ;
    // We need to be careful about multi-row INSERTs
    // Pattern: INSERT INTO table (cols) VALUES (vals) ;
    // Multi-row: INSERT INTO table (cols) VALUES (r1), (r2), ... ;
    // The ; we want is the one that follows the VALUES clause

    const insertStart = new RegExp(
      `INSERT\\s+INTO\\s+(?:public\\.)?${escapedTable}\\s*\\([^)]+\\)\\s*VALUES`,
      'gi'
    );

    let match;
    while ((match = insertStart.exec(content)) !== null) {
      const startIdx = match.index;

      // Skip if inside a function body (between CREATE FUNCTION and $$ or $BODY$)
      // Simple heuristic: check if we're inside a $$
      const before = content.substring(0, startIdx);
      const lastDollarDollar = before.lastIndexOf('$$');
      const lastDollarBody = before.lastIndexOf('$BODY$');
      const lastDelim = Math.max(lastDollarDollar, lastDollarBody);
      const lastEndDelim = before.lastIndexOf('$$', lastDelim > 0 ? lastDelim - 1 : 0);
      const lastEndDelimBody = before.lastIndexOf('$BODY$', lastDelim > 0 ? lastDelim - 1 : 0);
      if (lastEndDelim > lastDelim || lastEndDelimBody > lastDelim) {
        continue; // inside function body
      }

      // If already has ON CONFLICT, skip
      const snippet = content.substring(startIdx, startIdx + 500);
      if (/ON\s+CONFLICT/i.test(snippet)) continue;

      // Find the semicolon that ends this INSERT
      // Strategy: find the first ; after VALUES keyword
      const valsIdx = content.indexOf('VALUES', startIdx);
      if (valsIdx === -1) continue;

      // Count parens from VALUES to find the end
      let parenDepth = 0;
      let endIdx = -1;
      for (let i = valsIdx + 6; i < content.length; i++) {
        const ch = content[i];
        if (ch === '(') parenDepth++;
        else if (ch === ')') {
          parenDepth--;
          if (parenDepth === 0 && content[i + 1] === ';') {
            endIdx = i;
            break;
          }
          if (parenDepth === 0 && content[i + 1] === ' ' && content[i + 2] === ';') {
            endIdx = i;
            break;
          }
        }
      }

      if (endIdx === -1) continue;

      // Build ON CONFLICT clause
      let onConflict;
      if (Array.isArray(conflictCol)) {
        onConflict = ` ON CONFLICT (${conflictCol.join(', ')}) DO NOTHING`;
      } else {
        onConflict = ` ON CONFLICT (${conflictCol}) DO NOTHING`;
      }

      // Insert ON CONFLICT before the semicolon
      // The semicolon might be ';' or ' ;' or ';\n'
      let semiIdx = endIdx + 1;
      while (semiIdx < content.length && content[semiIdx] === ' ') semiIdx++;
      if (content[semiIdx] === '\n') semiIdx++;

      content = content.substring(0, semiIdx) + onConflict + content.substring(semiIdx);
    }
  }

  if (content !== original) {
    fs.writeFileSync(filepath, content);
    totalModified++;
    console.log('Fixed:', filename);
  }
}

console.log(`\nTotal files modified: ${totalModified}`);
