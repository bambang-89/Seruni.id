/**
 * Bulk Link Penduduk Script
 * Links penduduk to keluarga and wilayah via batch processing
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const H = {
  'apikey': KEY,
  'Authorization': `Bearer ${KEY}`,
  'Content-Type': 'application/json'
};

async function getPenduduk(batch = 0, limit = 100) {
  const offset = batch * limit;
  try {
    const r = await fetch(`${BASE}/rest/v1/penduduk?select=id,dusun,alamat&limit=${limit}&offset=${offset}`, { headers: H });
    if (r.ok) return await r.json();
    return [];
  } catch { return []; }
}

async function getWilayah() {
  try {
    const r = await fetch(`${BASE}/rest/v1/wilayah_dusun?select=id,nama`, { headers: H });
    if (r.ok) return await r.json();
    return [];
  } catch { return []; }
}

async function getKeluarga() {
  try {
    const r = await fetch(`${BASE}/rest/v1/keluarga?select=id,nama,dusun`, { headers: H });
    if (r.ok) return await r.json();
    return [];
  } catch { return []; }
}

async function linkPenduduk(id, dusun_id, keluarga_id) {
  try {
    const updates = {};
    if (dusun_id) updates.dusun_id = dusun_id;
    if (keluarga_id) updates.keluarga_id = keluarga_id;

    if (Object.keys(updates).length === 0) return false;

    const r = await fetch(`${BASE}/rest/v1/penduduk?id=eq.${id}`, {
      method: 'PATCH',
      headers: H,
      body: JSON.stringify(updates)
    });
    return r.ok || r.status === 204;
  } catch { return false; }
}

async function main() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║       BULK LINK PENDUDUK                        ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');

  // Get mappings
  console.log('Loading wilayah mapping...');
  const wilayah = await getWilayah();
  const wilayahMap = {};
  wilayah.forEach(w => { wilayahMap[w.nama] = w.id; });
  console.log(`  Loaded ${wilayah.length} wilayah`);

  console.log('Loading keluarga mapping...');
  const keluarga = await getKeluarga();
  const keluargaMap = {};
  keluarga.forEach(k => {
    const key = (k.dusun || '') + '|' + (k.nama || '');
    keluargaMap[key] = k.id;
  });
  console.log(`  Loaded ${keluarga.length} keluarga`);

  // Process penduduk in batches
  const BATCH_SIZE = 50;
  const TOTAL = 8059;
  const BATCHES = Math.ceil(TOTAL / BATCH_SIZE);

  let linkedWilayah = 0;
  let linkedKeluarga = 0;
  let failed = 0;

  console.log(`\nProcessing ${TOTAL} penduduk in ${BATCHES} batches...`);

  for (let batch = 0; batch < BATCHES; batch++) {
    const penduduk = await getPenduduk(batch, BATCH_SIZE);

    for (const p of penduduk) {
      let dusunId = null;
      let keluargaId = null;

      // Link to wilayah by dusun name
      if (p.dusun && wilayahMap[p.dusun]) {
        dusunId = wilayahMap[p.dusun];
        linkedWilayah++;
      }

      // Link to keluarga by dusun + nama
      if (p.dusun && p.alamat) {
        const key = p.dusun + '|' + p.alamat;
        if (keluargaMap[key]) {
          keluargaId = keluargaMap[key];
          linkedKeluarga++;
        }
      }

      if (dusunId || keluargaId) {
        const success = await linkPenduduk(p.id, dusunId, keluargaId);
        if (!success) failed++;
      }
    }

    // Progress
    const progress = Math.min((batch + 1) * BATCH_SIZE, TOTAL);
    process.stdout.write(`\r  Progress: ${progress}/${TOTAL} (${Math.round(progress/TOTAL*100)}%)`);
  }

  console.log('\n');
  console.log('='.repeat(60));
  console.log('RESULTS');
  console.log('='.repeat(60));
  console.log(`  Linked to Wilayah: ${linkedWilayah}`);
  console.log(`  Linked to Keluarga: ${linkedKeluarga}`);
  console.log(`  Failed: ${failed}`);
  console.log('');

  if (failed > 0) {
    console.log('⚠️  Some links failed. Run fix-data-consistency.sql for complete fix.');
  } else {
    console.log('🎉 Bulk linking complete!');
  }
}

main().catch(console.error);
