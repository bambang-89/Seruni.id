/**
 * Seed New Tables Script
 * Seeds data for newly created tables
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const H = {
  'apikey': KEY,
  'Authorization': `Bearer ${KEY}`,
  'Content-Type': 'application/json',
  'Prefer': 'return=representation'
};

async function seed(table, data) {
  try {
    const r = await fetch(`${BASE}/rest/v1/${table}`, {
      method: 'POST',
      headers: H,
      body: JSON.stringify(data)
    });
    if (r.ok) {
      const result = await r.json();
      return { table, success: true, count: result.length || 1 };
    }
    return { table, success: false, error: r.status };
  } catch (e) {
    return { table, success: false, error: e.message };
  }
}

async function getTenantId() {
  const r = await fetch(`${BASE}/rest/v1/tenants?select=id&subdomain=eq.seruni`, { headers: H });
  const data = await r.json();
  return data[0]?.id;
}

async function getWilayah() {
  const r = await fetch(`${BASE}/rest/v1/wilayah_dusun?select=id,nama`, { headers: H });
  return r.json();
}

async function getBansos() {
  const r = await fetch(`${BASE}/rest/v1/bantuan_sosial?select=id,nama`, { headers: H });
  return r.json();
}

async function getBencana() {
  const r = await fetch(`${BASE}/rest/v1/bencana_kejadian?select=id,jenis`, { headers: H });
  return r.json();
}

async function getPosyandu() {
  const r = await fetch(`${BASE}/rest/v1/posyandu_agregat?select=id,nama`, { headers: H });
  return r.json();
}

async function getPBBTagihan() {
  const r = await fetch(`${BASE}/rest/v1/pbb_tagihan?select=id,no_objek`, { headers: H });
  return r.json();
}

async function main() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║       SEED NEW TABLES                               ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');

  const tenantId = await getTenantId();
  if (!tenantId) {
    console.error('Tenant not found!');
    return;
  }
  console.log(`Tenant ID: ${tenantId}\n`);

  const wilayah = await getWilayah();
  const bansos = await getBansos();
  const bencana = await getBencana();
  const posyandu = await getPosyandu();
  const pbb = await getPBBTagihan();

  // 1. Seed apotek_resep
  console.log('Seeding apotek_resep...');
  const resep = await seed('apotek_resep', [
    {
      tenant_id: tenantId,
      nomor_resep: 'RES-001/2026',
      tanggal: '2026-07-01',
      pasien_nama: 'Hj. Rina binti Hasan',
      pasien_alamat: 'Mandar',
      diagnosa: 'Demam Berdarah Dengue',
      dokter: 'dr. Ahmad Fauzi',
      obat_list: [{ nama: 'Paracetamol 500mg', jumlah: 10, dosis: '3x1' }],
      total_harga: 50000,
      status: 'selesai'
    },
    {
      tenant_id: tenantId,
      nomor_resep: 'RES-002/2026',
      tanggal: '2026-07-05',
      pasien_nama: 'Andi Rahman',
      pasien_alamat: 'Sasak',
      diagnosa: 'Diabetes Mellitus Tipe 2',
      dokter: 'dr. Siti Aminah',
      obat_list: [{ nama: 'Metformin 500mg', jumlah: 30, dosis: '2x1' }],
      total_harga: 75000,
      status: 'selesai'
    },
    {
      tenant_id: tenantId,
      nomor_resep: 'RES-003/2026',
      tanggal: '2026-07-10',
      pasien_nama: 'Siti Zahra',
      pasien_alamat: 'Dames',
      diagnosa: 'ISPA',
      dokter: 'dr. Ahmad Fauzi',
      obat_list: [{ nama: 'Ambroxol', jumlah: 1, dosis: '3x1' }, { nama: 'CTM', jumlah: 1, dosis: '3x1' }],
      total_harga: 35000,
      status: 'proses'
    }
  ]);
  console.log(resep.success ? '  ✅ apotek_resep' : `  ❌ apotek_resep: ${resep.error}`);

  // 2. Seed buku_perpustakaan
  console.log('Seeding buku_perpustakaan...');
  const buku = await seed('buku_perpustakaan', [
    { tenant_id: tenantId, judul: 'UU Desa No 6 Tahun 2014', pengarang: 'Kemendagri RI', kategori: 'Hukum', rak: 'A-1', stok: 5 },
    { tenant_id: tenantId, judul: 'PP No 43 Tahun 2014 tentang Prasarana Desa', pengarang: 'Kemendagri RI', kategori: 'Hukum', rak: 'A-2', stok: 3 },
    { tenant_id: tenantId, judul: 'Permendagri 20 Tahun 2018', pengarang: 'Kemendagri RI', kategori: 'Hukum', rak: 'A-3', stok: 3 },
    { tenant_id: tenantId, judul: 'Buku Pedoman APBDes', pengarang: 'Kemendagri RI', kategori: 'Keuangan', rak: 'B-1', stok: 10 },
    { tenant_id: tenantId, judul: 'Buku SAK-KPKD', pengarang: 'Kemendagri RI', kategori: 'Keuangan', rak: 'B-2', stok: 5 },
    { tenant_id: tenantId, judul: 'Kesehatan Ibu dan Anak', pengarang: 'WHO Indonesia', kategori: 'Kesehatan', rak: 'C-1', stok: 4 },
    { tenant_id: tenantId, judul: 'Pedoman Posyandu', pengarang: 'Kementerian Kesehatan', kategori: 'Kesehatan', rak: 'C-2', stok: 6 },
    { tenant_id: tenantId, judul: 'Buku Administrasi Desa', pengarang: 'Kemendagri RI', kategori: 'Administrasi', rak: 'D-1', stok: 8 }
  ]);
  console.log(buku.success ? '  ✅ buku_perpustakaan' : `  ❌ buku_perpustakaan: ${buku.error}`);

  // 3. Seed pemilihan (future election)
  console.log('Seeding pemilihan...');
  const pemilihan = await seed('pemilihan', [
    {
      tenant_id: tenantId,
      judul: 'Pilkades Seruni Mumbul',
      periode: '2026-2031',
      tanggal_pemilihan: '2026-11-15',
      status: 'rencana',
      jumlah_dpt: 5000,
      keterangan: 'Pemilihan Kepala Desa Seruni Mumbul periode 2026-2031'
    }
  ]);
  console.log(pemilihan.success ? '  ✅ pemilihan' : `  ❌ pemilihan: ${pemilihan.error}`);

  // 4. Seed pbb_pembayaran (sample)
  console.log('Seeding pbb_pembayaran...');
  if (pbb && pbb.length > 0) {
    const pembayaranData = pbb.slice(0, 3).map(t => ({
      tenant_id: tenantId,
      tagihan_id: t.id,
      tahun_pajak: 2026,
      jumlah_bayar: 50000,
      tanggal_bayar: '2026-06-15',
      metode_bayar: 'tunai',
      keterangan: 'Pembayaran PBB 2026'
    }));
    const pembayaran = await seed('pbb_pembayaran', pembayaranData);
    console.log(pembayaran.success ? '  ✅ pbb_pembayaran' : `  ❌ pbb_pembayaran: ${pembayaran.error}`);
  } else {
    console.log('  ⚠️ pbb_pembayaran: No tagihan found, skipped');
  }

  // 5. Seed bansos_penerima
  console.log('Seeding bansos_penerima...');
  if (bansos && bansos.length > 0) {
    const penerimaData = [];
    for (const b of bansos) {
      penerimaData.push({
        tenant_id: tenantId,
        bantuan_id: b.id,
        dusun: wilayah[0]?.nama || 'Mandar',
        status: 'diterima',
        tanggal_daftar: '2026-01-15',
        tanggal_terima: '2026-02-01',
        keterangan: `Penerima ${b.nama}`
      });
    }
    const bansosPenerima = await seed('bansos_penerima', penerimaData);
    console.log(bansosPenerima.success ? '  ✅ bansos_penerima' : `  ❌ bansos_penerima: ${bansosPenerima.error}`);
  }

  // 6. Seed posyandu_balita (sample)
  console.log('Seeding posyandu_balita...');
  if (posyandu && posyandu.length > 0) {
    const balitaData = [];
    for (let i = 1; i <= 20; i++) {
      const p = posyandu[i % posyandu.length];
      balitaData.push({
        tenant_id: tenantId,
        posyandu_id: p.id,
        nama: `Bayi Sample ${i}`,
        nik: `520401100${String(i).padStart(4, '0')}`,
        jenis_kelamin: i % 2 === 0 ? 'L' : 'P',
        tanggal_lahir: new Date(2025, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0],
        berat_badan: Math.round((8 + Math.random() * 4) * 100) / 100,
        tinggi_badan: Math.round((60 + Math.random() * 30) * 10) / 10,
        status_gizi: Math.random() > 0.3 ? 'Gizi Baik' : 'Gizi Kurang',
        z_score: Math.round((0 + (Math.random() - 0.5) * 2) * 100) / 100,
        nama_ortu: `Ortu Sample ${i}`,
        dusun: wilayah[i % wilayah.length]?.nama || 'Mandar',
        keterangan: 'Data sample untuk testing'
      });
    }
    const balita = await seed('posyandu_balita', balitaData);
    console.log(balita.success ? '  ✅ posyandu_balita' : `  ❌ posyandu_balita: ${balita.error}`);
  }

  // 7. Seed bencana_bantuan
  console.log('Seeding bencana_bantuan...');
  if (bencana && bencana.length > 0) {
    const bantuanData = [
      { tenant_id: tenantId, kejadian_id: bencana[0].id, jenis_bantuan: 'Logistik Makanan', sumber: 'APBD Kab Lombok Timur', jumlah: 50, satuan: 'paket', lokasi: 'Mandar', tanggal: '2026-06-01' },
      { tenant_id: tenantId, kejadian_id: bencana[0].id, jenis_bantuan: 'Selimut', sumber: 'Baznas', jumlah: 30, satuan: 'lembar', lokasi: 'Sasak', tanggal: '2026-06-01' },
      { tenant_id: tenantId, kejadian_id: bencana[0].id, jenis_bantuan: 'Bibit Tanaman', sumber: 'Distan', jumlah: 100, satuan: 'paket', lokasi: 'Dames', tanggal: '2026-06-02' },
      { tenant_id: tenantId, kejadian_id: bencana[0].id, jenis_bantuan: 'Obat-obatan', sumber: 'Puskesmas', jumlah: 20, satuan: 'paket', lokasi: 'Brangtapen Asri', tanggal: '2026-06-02' }
    ];
    const bantuan = await seed('bencana_bantuan', bantuanData);
    console.log(bantuan.success ? '  ✅ bencana_bantuan' : `  ❌ bencana_bantuan: ${bantuan.error}`);
  }

  // 8. Seed apotek_obat (additional)
  console.log('Seeding additional apotek_obat...');
  const obatTambahan = await seed('apotek_obat', [
    { tenant_id: tenantId, nama_obat: 'Vitamin C 500mg', kategori: 'Vitamin', satuan: 'tablet', stok: 1000, harga: 200, keterangan: 'Vitamin C umum' },
    { tenant_id: tenantId, nama_obat: 'Vitamin D3', kategori: 'Vitamin', satuan: 'tablet', stok: 500, harga: 500, keterangan: 'Vitamin D untuk tulang' },
    { tenant_id: tenantId, nama_obat: 'Tolak Angin', kategori: 'Obat Tradisional', satuan: 'sachet', stok: 200, harga: 3000, keterangan: 'Obat herbal masuk angin' },
    { tenant_id: tenantId, nama_obat: 'Promag', kategori: 'Obat Maag', satuan: 'tablet', stok: 300, harga: 1500, keterangan: 'Obat maag dan asam lambung' },
    { tenant_id: tenantId, nama_obat: 'Bodrex', kategori: 'Obat Sakit Kepala', satuan: 'tablet', stok: 400, harga: 1000, keterangan: 'Obat sakit kepala dan demam' }
  ]);
  console.log(obatTambahan.success ? '  ✅ apotek_obat (additional)' : `  ❌ apotek_obat: ${obatTambahan.error}`);

  console.log('\n' + '='.repeat(60));
  console.log('🎉 SEEDING COMPLETE!');
  console.log('='.repeat(60));
}

main().catch(console.error);
