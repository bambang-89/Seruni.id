const fs = require('fs');

const content = fs.readFileSync('E:/Seruni.id/docs/penduduk.csv', 'utf8');
const lines = content.split('\n').filter(line => line.trim() !== '');

const header = lines[0].split(',');

function findFieldIndex(header, fieldName) {
  return header.indexOf(fieldName);
}
function getFieldByIdx(row, idx) {
  if (idx === -1) return '';
  const parts = row.split(',');
  return (parts[idx] || '').trim();
}

const NAMA_IDX = findFieldIndex(header, 'NAMA');
const NIK_IDX = findFieldIndex(header, 'NIK');
const NO_KK_IDX = findFieldIndex(header, 'NO_KK');
const STATUS_DALAM_KK_IDX = findFieldIndex(header, 'STATUS_DALAM_KK');
const PEKERJAAN_IDX = findFieldIndex(header, 'PEKERJAAN');
const AGAMA_IDX = findFieldIndex(header, 'AGAMA');
const PENDIDIKAN_IDX = findFieldIndex(header, 'PENDIDIKAN');
const PENDAPATAN_IDX = findFieldIndex(header, 'PENDAPATAN_BULAN');

const rows = lines.slice(1);

// Odd STATUS_DALAM_KK: "Orangtua", "Perempuan", "Laki-Laki"
console.log('=== Odd STATUS_DALAM_KK entries ===');
const oddStatus = ['Orangtua', 'Perempuan', 'Laki-Laki'];
oddStatus.forEach(s => {
  const found = rows.filter(r => getFieldByIdx(r, STATUS_DALAM_KK_IDX) === s);
  console.log(`\n"${s}" (${found.length} rows):`);
  found.forEach(r => {
    console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NIK: ${getFieldByIdx(r, NIK_IDX)}, NO_KK: ${getFieldByIdx(r, NO_KK_IDX)}, PEKERJAAN: ${getFieldByIdx(r, PEKERJAAN_IDX)}`);
  });
});

// Rows where AGAMA looks wrong (should be religion, not nationality)
console.log('\n=== AGAMA = "Indonesia" (likely wrong) ===');
rows.filter(r => getFieldByIdx(r, AGAMA_IDX) === 'Indonesia').forEach(r => {
  console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NIK: ${getFieldByIdx(r, NIK_IDX)}`);
});

// Rows with dates in PENDIDIKAN
console.log('\n=== PENDIDIKAN that looks like a date ===');
rows.filter(r => {
  const p = getFieldByIdx(r, PENDIDIKAN_IDX);
  return p.match(/\d{2}\/\d{2}\/\d{4}/);
}).forEach(r => {
  console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, PENDIDIKAN: ${getFieldByIdx(r, PENDIDIKAN_IDX)}`);
});

// Very short NO_KK (< 10 digits)
console.log('\n=== NO_KK < 10 digits ===');
rows.filter(r => {
  const v = getFieldByIdx(r, NO_KK_IDX);
  return v && v !== '-' && v.length < 10;
}).forEach(r => {
  console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NO_KK: "${getFieldByIdx(r, NO_KK_IDX)}", STATUS: ${getFieldByIdx(r, STATUS_DALAM_KK_IDX)}`);
});

// Rows with non-numeric NIK (shouldn't exist but checking)
console.log('\n=== NIK with non-numeric characters ===');
const nonNumericNik = rows.filter(r => {
  const n = getFieldByIdx(r, NIK_IDX);
  return n && !/^\d+$/.test(n);
});
console.log('Count:', nonNumericNik.length);
nonNumericNik.forEach(r => {
  console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NIK: "${getFieldByIdx(r, NIK_IDX)}"`);
});

// Rows where PENDAPATAN_BULAN is non-numeric (not 0 or a number)
console.log('\n=== PENDAPATAN_BULAN non-numeric entries ===');
const badPendapatan = rows.filter(r => {
  const p = getFieldByIdx(r, PENDAPATAN_IDX);
  return p && p !== '0' && !/^\d+$/.test(p);
});
console.log('Count:', badPendapatan.length);
badPendapatan.forEach(r => {
  console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, PENDAPATAN: "${getFieldByIdx(r, PENDAPATAN_IDX)}"`);
});

// NIK length check
console.log('\n=== NIK length distribution ===');
const nikLengths = {};
rows.forEach(r => {
  const n = getFieldByIdx(r, NIK_IDX);
  if (n) {
    const len = n.length;
    nikLengths[len] = (nikLengths[len] || 0) + 1;
  }
});
Object.entries(nikLengths).sort((a, b) => a[0] - b[0]).forEach(([len, count]) => {
  console.log(`  ${len} digits: ${count} rows`);
});

// NO_KK 393 gap: unique NO_KK - kepala_keluarga count
console.log('\n=== NO_KK / Kepala Keluarga gap analysis ===');
const allNoKk = rows.map(r => getFieldByIdx(r, NO_KK_IDX)).filter(v => v && v !== '-' && v !== '' && v !== 'NON KK' && v !== 'BLM ADA KK');
const uniqueAllNoKk = new Set(allNoKk);
console.log('Unique NO_KKs (excluding NON KK / BLM ADA KK):', uniqueAllNoKk.size);
const kkRows = rows.filter(r => getFieldByIdx(r, STATUS_DALAM_KK_IDX) === 'Kepala Keluarga');
const uniqueKkNo = new Set(kkRows.map(r => getFieldByIdx(r, NO_KK_IDX)));
console.log('NO_KKs with a Kepala Keluarga:', uniqueKkNo.size);
console.log('NO_KKs missing a Kepala Keluarga:', uniqueAllNoKk.size - uniqueKkNo.size);
// Find NO_KKs that don't have a kepala keluarga
const noKkMissingKK = [...uniqueAllNoKk].filter(kk => !uniqueKkNo.has(kk));
console.log('\nNO_KKs without Kepala Keluarga (first 10):');
noKkMissingKK.slice(0, 10).forEach(kk => {
  const members = rows.filter(r => getFieldByIdx(r, NO_KK_IDX) === kk);
  console.log(`  NO_KK: ${kk}, Members (${members.length}): ${members.map(r => getFieldByIdx(r, NAMA_IDX) + '(' + getFieldByIdx(r, STATUS_DALAM_KK_IDX) + ')').join(', ')}`);
});

console.log('\n=== DONE ===');
