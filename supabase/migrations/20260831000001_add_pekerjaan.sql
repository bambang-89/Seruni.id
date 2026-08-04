INSERT INTO ref_pekerjaan (kode, nama) VALUES
('90', 'Perangkat Desa'),
('91', 'Tenaga Honorer'),
('92', 'Pegawai Pemerintah dengan Perjanjian Kerja (P3K)'),
('93', 'Wiraswasta / UMKM'),
('94', 'Buruh Tani / Perkebunan'),
('95', 'Nelayan / Perikanan'),
('96', 'Pekerja Lepas / Freelance'),
('97', 'Pengrajin / Industri Rumah Tangga')
ON CONFLICT (kode) DO NOTHING;
