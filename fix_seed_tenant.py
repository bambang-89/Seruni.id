# Fix apbdes INSERT: correct column order and add tenant_id to each row
# Column order: id, tahun, jenis, kategori, sub_kategori, uraian, anggaran, realizations, sumber_dana, keterangan, urutan, created_at, updated_at, tenant_id

import re

filepath = 'supabase/migrations/20260719123539_39657bd4-5b9a-41c5-b152-456736219b40.sql'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the apbdes INSERT
# The apbdes table column order is:
# id, tahun, jenis, kategori, sub_kategori, uraian, anggaran, realizations, sumber_dana, keterangan, urutan, created_at, updated_at, tenant_id
# We want: tahun, tenant_id, jenis, kategori, uraian, anggaran, realizations, sumber_dana, urutan
# sub_kategori and keterangan are NULL, created_at/updated_at have defaults, id has default

# Find and replace the apbdes section
old_start = '-- Seed APBDes 2026\nINSERT INTO public.apbdes'
old_end = ';\n\n-- Seed PBB dummy'
idx_start = content.find(old_start)
idx_end = content.find(old_end, idx_start)
if idx_end == -1:
    print('Could not find apbdes section boundaries')
    exit(1)

new_apbdes = '''-- Seed APBDes 2026
INSERT INTO public.apbdes (tahun, tenant_id, jenis, kategori, uraian, anggaran, realizations, sumber_dana, urutan) VALUES
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pendapatan', 'Pendapatan Transfer', 'Dana Desa (DD)', 1250000000, 812000000, 'APBN', 1),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pendapatan', 'Pendapatan Transfer', 'Alokasi Dana Desa (ADD)', 680000000, 442000000, 'APBD Kab', 2),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pendapatan', 'Pendapatan Transfer', 'Bagi Hasil Pajak & Retribusi', 95000000, 58000000, 'APBD Kab', 3),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pendapatan', 'Pendapatan Asli Burnett', 'Hasil Usaha BUMDes', 75000000, 41500000, 'PADes', 4),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pendapatan', 'Pendapatan Lain', 'Bantuan Provinsi', 120000000, 60000000, 'APBD Prov', 5),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 1 — Penyelenggaraan Pemerintahan', 'Penghasilan Tetap & Tunjangan Pamong', 420000000, 245000000, 'ADD', 10),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 1 — Penyelenggaraan Pemerintahan', 'Operasional Kantor Burnett', 95000000, 52000000, 'ADD', 11),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 2 — Pelaksanaan Pembangunan', 'Pengerasan Jalan Poros Karang Baru', 480000000, 374400000, 'DD', 20),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 2 — Pelaksanaan Pembangunan', 'Rehabilitasi Posyandu Melati', 85000000, 42500000, 'DD', 21),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 2 — Pelaksanaan Pembangunan', 'Drainase Burnett Presak', 210000000, 84000000, 'DD', 22),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 3 — Pembinaan Kemasyarakatan', 'Kegiatan PKK & Karang Taruna', 48000000, 26500000, 'ADD', 30),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 3 — Pembinaan Kemasyarakatan', 'Bulan Bakti Gotong Royong', 22000000, 22000000, 'ADD', 31),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 4 — Pemberdayaan Masyarakat', 'Pelatihan Pengolahan Hasil Pertanian', 65000000, 32000000, 'DD', 40),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 4 — Pemberdayaan Masyarakat', 'Bantuan Modal BUMDes', 75000000, 75000000, 'DD', 41),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'belanja', 'Bidang 5 — Penanggulangan Bencana & Mendesak', 'Cadangan Kebencanaan', 60000000, 12000000, 'DD', 50),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pembiayaan', 'Penerimaan Pembiayaan', 'SILPA Burnett Sebelumnya', 180000000, 180000000, 'SILPA', 60),
(2026, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pembiayaan', 'Pengeluaran Pembiayaan', 'Penyertaan Modal BUMDes', 75000000, 75000000, 'PADes', 61);

'''

content = content[:idx_start] + new_apbdes + content[idx_end + 2:]

# Fix pbb_tagihan: column order is id, tahun, nop, wajib_pajak_nama, wajib_pajak_nik, alamat_objek, dusun,
# luas_bumi_m2, luas_bangunan_m2, njop_bumi, njop_bangunan, pbb_terutang, jatuh_tempo, status_bayar,
# tanggal_bayar, metode_bayar, keterangan, created_at, updated_at, tenant_id
# We want: tenant_id, tahun, nop, wajib_pajak_nama, alamat_objek, dusun, luas_bumi_m2, luas_bangunan_m2,
# njop_bumi, njop_bangunan, pbb_terutang, jatuh_tempo, status_bayar
# Other columns (wajib_pajak_nik, tanggal_bayar, metode_bayar, keterangan, id, created_at, updated_at) are NULL/default

old_pbb = '-- Seed PBB dummy\nINSERT INTO public.pbb_tagihan'
idx_pbb_start = content.find(old_pbb)
if idx_pbb_start == -1:
    print('Could not find pbb_tagihan section')
else:
    # Find the semicolon that ends the INSERT
    idx_pbb_semicolon = content.find(';', idx_pbb_start)
    new_pbb = '''-- Seed PBB dummy
INSERT INTO public.pbb_tagihan (tenant_id, tahun, nop, wajib_pajak_nama, alamat_objek, dusun, luas_bumi_m2, luas_bangunan_m2, njop_bumi, njop_bangunan, pbb_terutang, jatuh_tempo, status_bayar) VALUES
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 2026, '52.03.140.007.001-0001.0', 'H. Ahmad Saputra', 'Dusun Karang Baru RT 04 RW 02', 'Karang Baru', 400, 120, 80000000, 60000000, 187500, '2026-09-30', 'belum_lunas'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 2026, '52.03.140.007.001-0002.0', 'Ni Wayan Sari', 'Dusun Presak RT 02 RW 01', 'Presak', 350, 90, 63000000, 42000000, 131250, '2026-09-30', 'lunas'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 2026, '52.03.140.007.001-0003.0', 'Lalu Muhammad Zaini', 'Dusun Seruni Utara RT 01 RW 03', 'Seruni Utara', 500, 150, 100000000, 90000000, 237500, '2026-09-30', 'belum_lunas'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 2026, '52.03.140.007.001-0004.0', 'Baiq Nurhayati', 'Dusun Mumbul RT 03 RW 02', 'Mumbul', 280, 72, 50400000, 28800000, 98500, '2026-09-30', 'belum_lunas'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 2026, '52.03.140.007.001-0005.0', 'I Ketut Wirya', 'Dusun Karang Baru RT 05 RW 02', 'Karang Baru', 600, 180, 120000000, 108000000, 285000, '2026-09-30', 'lunas');
'''
    content = content[:idx_pbb_start] + new_pbb + content[idx_pbb_semicolon + 1:]

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed apbdes and pbb_tagihan INSERTs')
