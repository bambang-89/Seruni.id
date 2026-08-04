const fs = require('fs');

const content = fs.readFileSync('E:/Seruni.id/docs/penduduk.csv', 'utf8');
const lines = content.split('\n').filter(line => line.trim() !== '');

const header = lines[0].split(',');
console.log('Header columns:', header.length);
console.log('---');

const rows = lines.slice(1);

function getField(row, header, fieldName) {
  const idx = header.indexOf(fieldName);
  if (idx === -1) return '';
  const parts = row.split(',');
  return (parts[idx] || '').trim();
}

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
const DUSUN_IDX = findFieldIndex(header, 'DUSUN');
const NAMA_IBU_IDX = findFieldIndex(header, 'NAMA_IBU');
const NAMA_BAPAK_IDX = findFieldIndex(header, 'NAMA_BAPAK');
const RT_IDX = findFieldIndex(header, 'RT');
const DESA_IDX = findFieldIndex(header, 'DESA');
const KECAMATAN_IDX = findFieldIndex(header, 'KECAMATAN');
const KABUPATEN_IDX = findFieldIndex(header, 'KABUPATEN');
const PROVINSI_IDX = findFieldIndex(header, 'PROVINSI');
const JENIS_KELAMIN_IDX = findFieldIndex(header, 'JENIS_KELAMIN');
const TANGGAL_LAHIR_IDX = findFieldIndex(header, 'TANGGAL_LAHIR');
const PEKERJAAN_IDX = findFieldIndex(header, 'PEKERJAAN');

// 1. Total rows
console.log('=== 1. Total data rows (excluding header) ===');
console.log('Total rows:', rows.length);

// 2. Unique NIK count
const nikValues = rows.map(r => getFieldByIdx(r, NIK_IDX));
const validNikValues = nikValues.filter(n => n && n !== '-' && n !== '');
const uniqueNik = new Set(validNikValues);
console.log('\n=== 2. Unique NIK count ===');
console.log('Unique NIKs (non-empty):', uniqueNik.size);
console.log('Empty/blank NIKs:', nikValues.length - validNikValues.length);

// 3. Unique NO_KK count
const noKkValues = rows.map(r => getFieldByIdx(r, NO_KK_IDX));
const validKkValues = noKkValues.filter(n => n && n !== '-' && n !== '');
const uniqueKk = new Set(validKkValues);
console.log('\n=== 3. Unique NO_KK count ===');
console.log('Unique NO_KKs (non-empty):', uniqueKk.size);
console.log('Total rows:', rows.length);
console.log('Avg members per KK:', (rows.length / uniqueKk.size).toFixed(2));

// 4. Rows with no_kk = "-" or empty
console.log('\n=== 4. Rows with NO_KK = "-" or empty ===');
const noKkRows = rows.filter(r => {
  const v = getFieldByIdx(r, NO_KK_IDX);
  return v === '-' || v === '';
});
console.log('Count:', noKkRows.length);
if (noKkRows.length > 0 && noKkRows.length <= 10) {
  noKkRows.forEach(r => {
    console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NIK: ${getFieldByIdx(r, NIK_IDX)}, NO_KK: "${getFieldByIdx(r, NO_KK_IDX)}"`);
  });
} else if (noKkRows.length > 10) {
  console.log('  First 5:');
  noKkRows.slice(0, 5).forEach(r => {
    console.log(`    NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NIK: ${getFieldByIdx(r, NIK_IDX)}, NO_KK: "${getFieldByIdx(r, NO_KK_IDX)}"`);
  });
}

// 5. STATUS_DALAM_KK = "Kepala Keluarga"
console.log('\n=== 5. STATUS_DALAM_KK = "Kepala Keluarga" ===');
const kkRows = rows.filter(r => getFieldByIdx(r, STATUS_DALAM_KK_IDX) === 'Kepala Keluarga');
console.log('Count:', kkRows.length);
console.log('Expected unique KKs:', uniqueKk.size);

// 6. Rows with blank/null NIK
console.log('\n=== 6. Rows with blank/null NIK ===');
const blankNikRows = rows.filter(r => {
  const v = getFieldByIdx(r, NIK_IDX);
  return !v || v === '';
});
console.log('Count:', blankNikRows.length);

// 7. Duplicate NIK
console.log('\n=== 7. Duplicate NIK ===');
const nikCount = {};
validNikValues.forEach(n => {
  nikCount[n] = (nikCount[n] || 0) + 1;
});
const duplicateNik = Object.entries(nikCount).filter(([k, v]) => v > 1);
console.log('Total duplicate NIKs:', duplicateNik.length);
console.log('Total duplicate NIK entries:', duplicateNik.reduce((acc, [k, v]) => acc + v, 0));
if (duplicateNik.length > 0) {
  console.log('Duplicate NIK list:');
  duplicateNik.sort((a, b) => b[1] - a[1]).forEach(([nik, count]) => {
    console.log(`  NIK: ${nik}, Count: ${count}`);
    // Show the rows
    rows.filter(r => getFieldByIdx(r, NIK_IDX) === nik).forEach(r => {
      console.log(`    NAMA: ${getFieldByIdx(r, NAMA_IDX)}, STATUS: ${getFieldByIdx(r, STATUS_DALAM_KK_IDX)}, NO_KK: ${getFieldByIdx(r, NO_KK_IDX)}`);
    });
  });
}

// 8. Unique DUSUN values
console.log('\n=== 8. Unique DUSUN values ===');
const dusunValues = rows.map(r => getFieldByIdx(r, DUSUN_IDX)).filter(v => v);
const uniqueDusun = new Set(dusunValues);
console.log('Unique DUSUNs:', uniqueDusun.size);
console.log('Values:', [...uniqueDusun].sort());
const dusunCounts = {};
dusunValues.forEach(d => { dusunCounts[d] = (dusunCounts[d] || 0) + 1; });
console.log('Per-DUSUN breakdown:');
Object.entries(dusunCounts).sort((a, b) => b[1] - a[1]).forEach(([dusun, count]) => {
  console.log(`  ${dusun}: ${count} penduduk`);
});

// 9. Blank NAMA_IBU or NAMA_BAPAK
console.log('\n=== 9. Blank NAMA_IBU or NAMA_BAPAK ===');
const blankIbu = rows.filter(r => {
  const v = getFieldByIdx(r, NAMA_IBU_IDX);
  return !v || v === '-';
});
const blankBapak = rows.filter(r => {
  const v = getFieldByIdx(r, NAMA_BAPAK_IDX);
  return !v || v === '-';
});
console.log('Blank NAMA_IBU:', blankIbu.length, '/', rows.length);
console.log('Blank NAMA_BAPAK:', blankBapak.length, '/', rows.length);
const blankBoth = rows.filter(r => {
  const ibu = getFieldByIdx(r, NAMA_IBU_IDX);
  const bapak = getFieldByIdx(r, NAMA_BAPAK_IDX);
  return (!ibu || ibu === '-') && (!bapak || bapak === '-');
});
console.log('Blank both NAMA_IBU AND NAMA_BAPAK:', blankBoth.length);

// 10. Sample 5 rows with STATUS_DALAM_KK = "Kepala Keluarga"
console.log('\n=== 10. Sample 5 Kepala Keluarga rows ===');
kkRows.slice(0, 5).forEach((r, i) => {
  const parts = r.split(',');
  console.log(`\n  --- Sample ${i + 1} ---`);
  console.log(`  NAMA: ${parts[NAMA_IDX]}`);
  console.log(`  NIK: ${parts[NIK_IDX]}`);
  console.log(`  NO_KK: ${parts[NO_KK_IDX]}`);
  console.log(`  JENIS_KELAMIN: ${parts[JENIS_KELAMIN_IDX]}`);
  console.log(`  TANGGAL_LAHIR: ${parts[TANGGAL_LAHIR_IDX]}`);
  console.log(`  PEKERJAAN: ${parts[PEKERJAAN_IDX]}`);
  console.log(`  DUSUN: ${parts[DUSUN_IDX]}`);
  console.log(`  RT: ${parts[RT_IDX]}`);
  console.log(`  AGAMA: ${getFieldByIdx(r, findFieldIndex(header, 'AGAMA'))}`);
  console.log(`  PENDIDIKAN: ${getFieldByIdx(r, findFieldIndex(header, 'PENDIDIKAN'))}`);
  console.log(`  KEPEMILIKAN_RUMAH: ${getFieldByIdx(r, findFieldIndex(header, 'KEPEMILIKAN_RUMAH'))}`);
  console.log(`  NAMA_IBU: ${getFieldByIdx(r, NAMA_IBU_IDX)}`);
  console.log(`  NAMA_BAPAK: ${getFieldByIdx(r, NAMA_BAPAK_IDX)}`);
});

// 11. Distribution of STATUS_DALAM_KK
console.log('\n=== 11. Distribution of STATUS_DALAM_KK ===');
const statusCounts = {};
rows.forEach(r => {
  const s = getFieldByIdx(r, STATUS_DALAM_KK_IDX) || '(blank)';
  statusCounts[s] = (statusCounts[s] || 0) + 1;
});
Object.entries(statusCounts).sort((a, b) => b[1] - a[1]).forEach(([status, count]) => {
  const pct = ((count / rows.length) * 100).toFixed(1);
  console.log(`  "${status}": ${count} (${pct}%)`);
});

// 12. Malformed NO_KK (not 16-20 digits)
console.log('\n=== 12. Malformed NO_KK (not 16-20 digits) ===');
const malformedKk = rows.filter(r => {
  const v = getFieldByIdx(r, NO_KK_IDX);
  if (!v || v === '-') return false;
  return !/^\d{16,20}$/.test(v);
});
console.log('Count of malformed NO_KK:', malformedKk.length);
if (malformedKk.length > 0 && malformedKk.length <= 10) {
  malformedKk.forEach(r => {
    const v = getFieldByIdx(r, NO_KK_IDX);
    console.log(`  NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NO_KK: "${v}", length: ${v.length}`);
  });
} else if (malformedKk.length > 10) {
  console.log('  First 10:');
  malformedKk.slice(0, 10).forEach(r => {
    const v = getFieldByIdx(r, NO_KK_IDX);
    console.log(`    NAMA: ${getFieldByIdx(r, NAMA_IDX)}, NO_KK: "${v}", length: ${v.length}`);
  });
}

// KK length distribution
console.log('\n  NO_KK digit length distribution:');
const kkLengths = {};
noKkValues.filter(v => v && v !== '-').forEach(v => {
  const len = v.length;
  kkLengths[len] = (kkLengths[len] || 0) + 1;
});
Object.entries(kkLengths).sort((a, b) => a[0] - b[0]).forEach(([len, count]) => {
  console.log(`    ${len} digits: ${count} rows`);
});

// Extra: Check consistency - every NO_KK should have exactly one Kepala Keluarga
console.log('\n=== Extra: NO_KK consistency check ===');
const kkByNoKk = {};
kkRows.forEach(r => {
  const kk = getFieldByIdx(r, NO_KK_IDX);
  if (!kkByNoKk[kk]) kkByNoKk[kk] = [];
  kkByNoKk[kk].push(getFieldByIdx(r, NAMA_IDX));
});
const multipleKK = Object.entries(kkByNoKk).filter(([kk, names]) => names.length > 1);
console.log('NO_KKs with multiple Kepala Keluarga:', multipleKK.length);
if (multipleKK.length > 0) {
  multipleKK.slice(0, 5).forEach(([kk, names]) => {
    console.log(`  NO_KK ${kk}: ${names.join(', ')}`);
  });
}

// Extra: PEKERJAAN distribution
console.log('\n=== Extra: PEKERJAAN distribution ===');
const pekerjaanCounts = {};
rows.forEach(r => {
  const p = getFieldByIdx(r, PEKERJAAN_IDX) || '(blank)';
  pekerjaanCounts[p] = (pekerjaanCounts[p] || 0) + 1;
});
Object.entries(pekerjaanCounts).sort((a, b) => b[1] - a[1]).forEach(([p, count]) => {
  const pct = ((count / rows.length) * 100).toFixed(1);
  console.log(`  "${p}": ${count} (${pct}%)`);
});

// Extra: AGAMA distribution
console.log('\n=== Extra: AGAMA distribution ===');
const agamaIdx = findFieldIndex(header, 'AGAMA');
const agamaCounts = {};
rows.forEach(r => {
  const a = getFieldByIdx(r, agamaIdx) || '(blank)';
  agamaCounts[a] = (agamaCounts[a] || 0) + 1;
});
Object.entries(agamaCounts).sort((a, b) => b[1] - a[1]).forEach(([a, count]) => {
  const pct = ((count / rows.length) * 100).toFixed(1);
  console.log(`  "${a}": ${count} (${pct}%)`);
});

// Extra: PENDIDIKAN distribution
console.log('\n=== Extra: PENDIDIKAN distribution ===');
const pendidikanIdx = findFieldIndex(header, 'PENDIDIKAN');
const pendidikanCounts = {};
rows.forEach(r => {
  const p = getFieldByIdx(r, pendidikanIdx) || '(blank)';
  pendidikanCounts[p] = (pendidikanCounts[p] || 0) + 1;
});
Object.entries(pendidikanCounts).sort((a, b) => b[1] - a[1]).forEach(([p, count]) => {
  const pct = ((count / rows.length) * 100).toFixed(1);
  console.log(`  "${p}": ${count} (${pct}%)`);
});

console.log('\n=== DONE ===');
