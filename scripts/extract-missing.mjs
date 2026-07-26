import fs from 'fs';
import path from 'path';

const migrationsDir = 'e:/Seruni.id/supabase/migrations';

const finalJenisContent = fs.readFileSync(path.join(migrationsDir, '20260805000003_seed_jenis_surat_final.sql'), 'utf-8');
const allLettersMatch = finalJenisContent.matchAll(/'([\d\.]+)',\s*'\d+',\s*'[^']+'/g);
const allLetters = new Set();
for (const match of allLettersMatch) {
    allLetters.add(match[1]);
}
console.log(`Total letters in 20260805000003: ${allLetters.size}`);

const dnas = new Set();
const seed4 = fs.readFileSync(path.join(migrationsDir, '20260805000004_seed_dna_final.sql'), 'utf-8');
const seed5 = fs.readFileSync(path.join(migrationsDir, '20260805000005_seed_dna_remaining.sql'), 'utf-8');
const seed7 = fs.existsSync(path.join(migrationsDir, '20260805000007_seed_missing_dna.sql')) 
    ? fs.readFileSync(path.join(migrationsDir, '20260805000007_seed_missing_dna.sql'), 'utf-8') 
    : '';

for (const match of [...seed4.matchAll(/kode_surat\s*=\s*'([\d\.]+)'/g), ...seed5.matchAll(/kode_surat\s*=\s*'([\d\.]+)'/g), ...seed7.matchAll(/kode_surat\s*=\s*'([\d\.]+)'/g)]) {
    dnas.add(match[1]);
}
console.log(`Total DNA seeded in final batch: ${dnas.size}`);

const missing = [...allLetters].filter(x => !dnas.has(x));
console.log(`Missing DNA for:`, missing);

const oldFiles = fs.readdirSync(migrationsDir).filter(f => f.startsWith('20260802') || f.startsWith('20260803')).sort();

let sqlOutput = `
-- ============================================================
-- SEED DNA FIELDS - Restoring all missing fields
-- Tanggal: 2026-08-05
-- ============================================================
DO $$
DECLARE v_tenant_id UUID; v_jenis UUID;
BEGIN SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
`;
const found = new Set();

for (const file of oldFiles) {
    const content = fs.readFileSync(path.join(migrationsDir, file), 'utf-8');
    const blocks = content.split(/SELECT\s+id\s+INTO\s+v_jenis\s+FROM\s+public\.surat_jenis\s+WHERE\s+kode_surat\s*=\s*/i);
    for (let i = 1; i < blocks.length; i++) {
        const block = blocks[i];
        const kodeMatch = block.match(/^'([\d\.]+)'/);
        if (kodeMatch) {
            const kode = kodeMatch[1];
            if (missing.includes(kode) && !found.has(kode)) {
                found.add(kode);
                let endIdx = block.indexOf('END IF;');
                if (endIdx !== -1) {
                    let blockContent = block.substring(0, endIdx + 'END IF;'.length);
                    const optionsUpdateMatch = block.match(/UPDATE\s+public\.surat_jenis_dna[\s\S]*?;/i);
                    if (optionsUpdateMatch && block.indexOf(optionsUpdateMatch[0]) > endIdx) {
                        blockContent += '\n    ' + optionsUpdateMatch[0];
                    }
                    sqlOutput += `\n-- ${kode}\nSELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '${blockContent}\n`;
                }
            }
        }
    }
}
sqlOutput += `\nEND $$;\n`;
fs.writeFileSync(path.join(migrationsDir, '20260805000008_seed_dna_all_missing.sql'), sqlOutput);
console.log(`Missing DNA restored for ${found.size} out of ${missing.length} letters.`);

const extractInserts = () => {
    let inserts = [];
    for (const file of oldFiles) {
        const content = fs.readFileSync(path.join(migrationsDir, file), 'utf-8');
        const valuesMatches = content.matchAll(/VALUES\s*\(([\s\S]*?)\)\s*ON\s*CONFLICT/gi);
        for (const match of valuesMatches) {
            const inner = match[1];
            const rows = inner.split(/,\s*\(\s*v_tenant_id/);
            for (let r of rows) {
                if (!r.startsWith('v_tenant_id') && !r.startsWith('(v_tenant_id')) {
                    r = 'v_tenant_id' + r;
                }
                // FIXED REGEX
                const parts = r.replace(/\\\(/g, '').replace(/\\\)/g, '').split(/,(?=(?:[^']*'[^']*')*[^']*$)/).map(s => s.trim());
                if (parts.length >= 10) {
                    const kode = parts[2].replace(/'/g, '');
                    if (missing.includes(kode)) {
                        inserts.push({
                            kode_surat: kode,
                            field_name: parts[3].replace(/'/g, ''),
                            label: parts[4].replace(/'/g, ''),
                            tipe: parts[5].replace(/'/g, ''),
                            placeholder: parts[6].replace(/'/g, ''),
                            wajib: parts[7] === 'true',
                            grup: parts[8].replace(/'/g, ''),
                            urutan: parseInt(parts[9]),
                            help_text: parts[10] && parts[10] !== 'NULL' ? parts[10].replace(/'/g, '') : null
                        });
                    }
                }
            }
        }
    }
    return inserts;
};

const missingInserts = extractInserts();

const tsScript = `
import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';

const envPath = path.join(process.cwd(), '.env');
const envContent = fs.readFileSync(envPath, 'utf8');
const env: Record<string, string> = {};
envContent.split('\\n').forEach(line => {
  const [key, ...values] = line.split('=');
  if (key && values.length > 0) {
    env[key.trim()] = values.join('=').trim().replace(/['"]/g, '');
  }
});

const supabase = createClient(
  env['VITE_SUPABASE_URL'] || 'http://127.0.0.1:54321', 
  env['SUPABASE_SERVICE_ROLE_KEY'] || env['VITE_SUPABASE_ANON_KEY'] || 'dummy'
);

const missingDnas = ${JSON.stringify(missingInserts, null, 2)};

async function run() {
    const { data: jenisAll, error: e1 } = await supabase.from('surat_jenis').select('id, kode_surat, tenant_id');
    if (!jenisAll) return console.error(e1);
    
    const jenisMap = {};
    for (const j of jenisAll) jenisMap[j.kode_surat] = j;

    let payload = [];
    let seen = new Set();
    for (const d of missingDnas) {
        if (!jenisMap[d.kode_surat]) continue;
        const key = d.kode_surat + '_' + d.field_name;
        if (seen.has(key)) continue;
        seen.add(key);
        
        payload.push({
            tenant_id: jenisMap[d.kode_surat].tenant_id,
            jenis_surat_id: jenisMap[d.kode_surat].id,
            ...d
        });
    }

    console.log(\`Inserting \${payload.length} missing DNA fields...\`);
    const { error } = await supabase.from('surat_jenis_dna').upsert(payload, { onConflict: 'jenis_surat_id,field_name' });
    if (error) console.error(error);
    else console.log("Done successfully!");
}
run();
`;
fs.writeFileSync(path.join(process.cwd(), 'scripts', 'apply-all-missing-dna.ts'), tsScript);
