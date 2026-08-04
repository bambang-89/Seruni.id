const fs = require('fs');
const path = require('path');
const Papa = require('papaparse');

const csvFilePath = path.join(__dirname, '../docs/penduduk.csv');
const sqlFilePath = path.join(__dirname, '../supabase/migrations/20260832000001_sync_no_kk.sql');

if (!fs.existsSync(csvFilePath)) {
  console.error("File not found:", csvFilePath);
  process.exit(1);
}

const csvData = fs.readFileSync(csvFilePath, 'utf8');
const parsed = Papa.parse(csvData, { header: true, skipEmptyLines: true });
const data = parsed.data;

const keluargaMap = new Map(); // NO_KK -> { kepala_nama, dusun, rt }
const nikToKkMap = new Map();  // NIK -> NO_KK

data.forEach(row => {
  const nik = row['NIK']?.trim();
  const noKk = row['NO_KK']?.trim();
  const nama = row['NAMA']?.trim();
  const status = row['STATUS_DALAM_KK']?.trim();
  const dusun = row['DUSUN']?.trim() || '';
  const rt = row['RT']?.trim() || '';
  
  if (nik && noKk) {
    nikToKkMap.set(nik, noKk);
    
    if (!keluargaMap.has(noKk)) {
      keluargaMap.set(noKk, { kepala_nama: '', dusun, rt });
    }
    
    if (status && status.toLowerCase() === 'kepala keluarga') {
      keluargaMap.get(noKk).kepala_nama = nama;
      keluargaMap.get(noKk).dusun = dusun;
      keluargaMap.get(noKk).rt = rt;
    }
  }
});

let currentPart = 1;
const getHeader = (part) => `-- ============================================================
-- SYNC NO_KK FROM CSV TO PENDUDUK (PART ${part})
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  -- 1. Ambil tenant_id
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant ID tidak ditemukan.';
  END IF;

`;

const getFooter = () => `END $$;
`;

let sql = getHeader(currentPart);
let count = 0;
const MAX = 1000;

function savePart() {
  sql += getFooter();
  const filePath = path.join(__dirname, `../supabase/migrations/20260832000001_sync_no_kk_part${currentPart}.sql`);
  fs.writeFileSync(filePath, sql);
  console.log(`Saved part ${currentPart}: ${filePath}`);
  currentPart++;
  sql = getHeader(currentPart);
  count = 0;
}

let i = 1;
for (const [noKk, info] of keluargaMap.entries()) {
  const nama = info.kepala_nama.replace(/'/g, "''");
  const dusun = info.dusun.replace(/'/g, "''");
  const rt = info.rt.replace(/'/g, "''");
  
  sql += `  UPDATE public.keluarga SET kepala_nama = '${nama}', dusun = '${dusun}', rt = '${rt}' WHERE tenant_id = v_tenant_id AND no_kk = '${noKk}';
  INSERT INTO public.keluarga (id, tenant_id, no_kk, kepala_nama, dusun, rt) SELECT gen_random_uuid(), v_tenant_id, '${noKk}', '${nama}', '${dusun}', '${rt}' WHERE NOT EXISTS (SELECT 1 FROM public.keluarga WHERE tenant_id = v_tenant_id AND no_kk = '${noKk}');
`;
  count++;
  if (count >= MAX) savePart();
  i++;
}

for (const [nik, noKk] of nikToKkMap.entries()) {
  sql += `  UPDATE public.penduduk SET keluarga_id = (SELECT id FROM public.keluarga WHERE tenant_id = v_tenant_id AND no_kk = '${noKk}' LIMIT 1) WHERE tenant_id = v_tenant_id AND nik = '${nik}';
`;
  count++;
  if (count >= MAX) savePart();
}

if (count > 0) savePart();

const oldFile = path.join(__dirname, '../supabase/migrations/20260832000001_sync_no_kk.sql');
if (fs.existsSync(oldFile)) fs.unlinkSync(oldFile);
