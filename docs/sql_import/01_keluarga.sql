-- ============================================
-- KELUARGA (actual schema with tenant_id NOT NULL)
-- ============================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  INSERT INTO public.keluarga (tenant_id, no_kk, kepala_nama, alamat, dusun, rt, rw, catatan)
  SELECT v_tenant_id, t.no_kk, t.kepala_nama, t.alamat, t.dusun, t.rt, t.rw, t.catatan FROM (
    SELECT '5203032809120020' AS no_kk, 'Wiwik Ariani Sapura' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080102160004' AS no_kk, 'Edgar Atala Nando' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080102170001' AS no_kk, 'M. Fajar Al Irsyad' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802120015' AS no_kk, 'Sahura' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080103120017' AS no_kk, 'Didi Samsul Hadi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080103120041' AS no_kk, 'Daeng Jabir' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080103180013' AS no_kk, 'Afriani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907100018' AS no_kk, 'Ahmad Junaedi Aksa' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080106150049' AS no_kk, 'M. Gandi Gunawan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120082' AS no_kk, 'Hendra Gunawan' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080107130007' AS no_kk, 'Satriadi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120039' AS no_kk, 'Firda Apriana' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080308210004' AS no_kk, 'Diego Junian Jayadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120086' AS no_kk, 'Aswatun Nisa' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080211150012' AS no_kk, 'Rosdiana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110120033' AS no_kk, 'Syahrudin' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120100' AS no_kk, 'Nashrudin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110200005' AS no_kk, 'M. Ikbal' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120016' AS no_kk, 'Nurdin' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120024' AS no_kk, 'Buniah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120039' AS no_kk, 'Khulutiyah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120045' AS no_kk, 'Nahariya' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111200503' AS no_kk, 'Muhammad Shopi Anwar Khairi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120052' AS no_kk, 'Ahmad Laduni' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907100015' AS no_kk, 'Amirullah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120058' AS no_kk, 'Aisar' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120061' AS no_kk, 'Ferdian Isrori' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120068' AS no_kk, 'Saparwadi' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120079' AS no_kk, 'Habibuddin' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120097' AS no_kk, 'Irwansyah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082508100017' AS no_kk, 'Ismail Farukh Elrazi. A' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204120035' AS no_kk, 'Ahmad Khalqi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086411650001' AS no_kk, 'Moh.amin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082102180009' AS no_kk, 'Zulkifli' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130019' AS no_kk, 'Al Ardahikam Marna' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130028' AS no_kk, 'Mustiarep' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080209210010' AS no_kk, 'Andri Ferianto' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130038' AS no_kk, 'Maiyah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130039' AS no_kk, 'Muhamad Ramdani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130058' AS no_kk, 'Herman Wirahadi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130063' AS no_kk, 'Andi Edi Mariadi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130069' AS no_kk, 'Galang Maulana Najar' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120143' AS no_kk, 'Muhammad Yusril' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130077' AS no_kk, 'Shandy Rizky Pratama' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501120058' AS no_kk, 'Alia Saputri' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130084' AS no_kk, 'Lalu Teguh Barata' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130086' AS no_kk, 'Novita' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130103' AS no_kk, 'Mahila Putri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130115' AS no_kk, 'Kamariah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201150006' AS no_kk, 'Haerunan' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201150007' AS no_kk, 'Nila Agustina' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080202120033' AS no_kk, 'Ar. Rafi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203210001' AS no_kk, 'Ardian Diwangsa' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120036' AS no_kk, 'Seluhi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120021' AS no_kk, 'Saparudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120051' AS no_kk, 'Pingky Apri Aldi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120079' AS no_kk, 'Sila Atasa Ruslania' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204130004' AS no_kk, 'Eka Budio Muliani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120005' AS no_kk, 'Anisatul Wapiyya' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120029' AS no_kk, 'Ratniwati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120030' AS no_kk, 'Apriyadi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120034' AS no_kk, 'Imam Malik' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120044' AS no_kk, 'Lalu Ardiansyah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120048' AS no_kk, 'Sahrul Ramdan' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207150014' AS no_kk, 'M. Angga Saputra' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120132' AS no_kk, 'Elza Zulyanafa' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208100056' AS no_kk, 'Nurhidayah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081610130010' AS no_kk, 'Elmiati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208120043' AS no_kk, 'Hairil' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082081600400' AS no_kk, 'Silna Faradisa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208160014' AS no_kk, 'Sakha Arkana Ibran' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080209130004' AS no_kk, 'Irasih' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120044' AS no_kk, 'Hidayatullah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210120048' AS no_kk, 'Isaepol Nurhadi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210120136' AS no_kk, 'Endang Astuti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212400025' AS no_kk, 'Raditia Ramadani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080211150004' AS no_kk, 'Ahmad Sahirudin' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080211160010' AS no_kk, 'Akrom Abdillah Yamani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085007000000' AS no_kk, 'Lusi Juliani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802000000' AS no_kk, 'Fahrul Hidayat Yamani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212140014' AS no_kk, 'Muhammad Nuridin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212140018' AS no_kk, 'Wiwin Haslinda' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080214004000' AS no_kk, 'Dodi Irawan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212160004' AS no_kk, 'Budiman' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301120010' AS no_kk, 'Muh. Hasanudin' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080406120021' AS no_kk, 'Herman' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130020' AS no_kk, 'Sivatul Aulia' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130023' AS no_kk, 'Qabila Meisya Fatmira' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087112720232' AS no_kk, 'Hermayanti' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130049' AS no_kk, 'Inaq Anah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130072' AS no_kk, 'Nakunah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301170011' AS no_kk, 'Iqlima Qurrta' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120014' AS no_kk, 'Ratnawati' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120027' AS no_kk, 'Anindita Kaysa Zahra' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120033' AS no_kk, 'Inaq Muhnim' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7371101011150026' AS no_kk, 'Meliyana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120035' AS no_kk, 'Hikmah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120036' AS no_kk, 'M. Nava Ramdhan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082204770001' AS no_kk, 'Anwar Sadat' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100032' AS no_kk, 'Nurfaizah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304140014' AS no_kk, 'Nayla Qoni''Atun Adila' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080307160005' AS no_kk, 'Rama Hiraji' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609120072' AS no_kk, 'Raditya Apriandi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080306150006' AS no_kk, 'Karmah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120037' AS no_kk, 'Inaq Daisah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080306150019' AS no_kk, 'Nurminah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080307120012' AS no_kk, 'Dika Prayudha' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080307120026' AS no_kk, 'Siti Mahnun' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083007130010' AS no_kk, 'Zein Malik Ibrahim' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080307130013' AS no_kk, 'Linda Hasriani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107130020' AS no_kk, 'Roni Riadi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120001' AS no_kk, 'Saiful Basri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080309180010' AS no_kk, 'Muhammad Faisal' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130081' AS no_kk, 'Julinang' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310120006' AS no_kk, 'Sumiati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310120124' AS no_kk, 'I Komang Rai Asa Putra' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083006120004' AS no_kk, 'Dwi Rassya Ihzati' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310130016' AS no_kk, 'Lalu Muhamad Ayubi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811240008' AS no_kk, 'Leni Sartika' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310170012' AS no_kk, 'M. Alparizi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070700' AS no_kk, 'Yunita Anggara Eni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120033' AS no_kk, 'Anisa' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080311170007' AS no_kk, 'Fitri Ariani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120058' AS no_kk, 'Wahyu Nopid Widodo' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082806120005' AS no_kk, 'Muliyati' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312120022' AS no_kk, 'Bayu Haerul Azhari' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312140012' AS no_kk, 'Elma Fitriah Ramadhani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312160001' AS no_kk, 'Saputra Wiranata' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080912140023' AS no_kk, 'Jifaldi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120061' AS no_kk, 'Ahza Danis' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080402130014' AS no_kk, 'Ilham Sobari' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120075' AS no_kk, 'Kurniawan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403130006' AS no_kk, 'Endri' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403130011' AS no_kk, 'Windi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403130013' AS no_kk, 'Arman Maolana' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710100006' AS no_kk, 'Wardiman' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082806240001' AS no_kk, 'Reki Resulistion' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120010' AS no_kk, 'Rohadenin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120024' AS no_kk, 'Sumenah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012110053' AS no_kk, 'Heriadi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084107931656' AS no_kk, 'Iq. Muhani' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107240001' AS no_kk, 'Rosliana Lastari' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080405100029' AS no_kk, 'Nurhayati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080405210001' AS no_kk, 'Sini' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080406120041' AS no_kk, 'Muh. Khaerurrozikin' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081802730007' AS no_kk, 'Khaelal Albi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081405120013' AS no_kk, 'Lalu Hary Satryadi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085008000000' AS no_kk, 'Astuti' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080407120039' AS no_kk, 'Surini' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408100013' AS no_kk, 'Jamil Salam' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408100022' AS no_kk, 'Alya Assifa Putri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408100025' AS no_kk, 'Abdullah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408100027' AS no_kk, 'Satria' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408160004' AS no_kk, 'Daffa Arya Maulana' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409100025' AS no_kk, 'Hendra' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402140014' AS no_kk, 'Quratul Aini' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409100026' AS no_kk, 'Arifullah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409120058' AS no_kk, 'Muhammad Nur Ihsan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409130013' AS no_kk, 'Rismawati' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410120101' AS no_kk, 'Riza Astuti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080702220004' AS no_kk, 'Roni Hariyadi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410120137' AS no_kk, 'Nazya Salma' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410120138' AS no_kk, 'Herni' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082107200001' AS no_kk, 'Delvin Anggara' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081610140015' AS no_kk, 'Andin Nur Afifah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081501140006' AS no_kk, 'Sopiah Hasan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120105' AS no_kk, 'Asri Yadi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412140007' AS no_kk, 'Inaq Sanisah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412140015' AS no_kk, 'Andi Saputra' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412140019' AS no_kk, 'Dita Pibriani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120003' AS no_kk, 'Riski Kurniawan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080911200460' AS no_kk, 'Fauzan Azima' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080502150009' AS no_kk, 'Baiq Marya Febriana' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080503120008' AS no_kk, 'Bayang Al Rizkat' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120069' AS no_kk, 'Mashur' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120079' AS no_kk, 'Selamah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120081' AS no_kk, 'Abdurahman' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504130004' AS no_kk, 'Rahmawati' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086609230001' AS no_kk, 'Mita Nalindra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505100320' AS no_kk, 'Muhsinin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120021' AS no_kk, 'Rijal' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506120018' AS no_kk, 'Harudin' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506120019' AS no_kk, 'Diki Kurniawan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202180003' AS no_kk, 'Maemunah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506120023' AS no_kk, 'Amaq Ahyar' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506120025' AS no_kk, 'Riyan Supriadi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506120027' AS no_kk, 'Muh. Ajmi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506120028' AS no_kk, 'Ennisa' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506150018' AS no_kk, 'Baiq Ariqa Fatina Arumi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507100026' AS no_kk, 'Putri Rengganis' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507122000' AS no_kk, 'Sukri' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507120016' AS no_kk, 'Ilham Musdalifa' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507120021' AS no_kk, 'Akbar Jayadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507120040' AS no_kk, 'Lalu Luqman Hakim' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507130001' AS no_kk, 'Nusripatul Hidayat Tullah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507170007' AS no_kk, 'Hariadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807120008' AS no_kk, 'Baiq Meri Fitriah Hidayah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812120025' AS no_kk, 'Lalu Amirudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080509120028' AS no_kk, 'Sinemah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080509190004' AS no_kk, 'Khairul Ikhwan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084406140001' AS no_kk, 'Alfiara Talita Handa Yani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120087' AS no_kk, 'Irfan Al Farid' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510072897' AS no_kk, 'Sabarudin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5103080510073411' AS no_kk, 'Lukmanul Hakim' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT 'NON KK' AS no_kk, 'Mutiara' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510073415' AS no_kk, 'Ari Saputra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404680002' AS no_kk, 'Tino Anugrah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510120093' AS no_kk, 'Imam Malik Atmam' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510120094' AS no_kk, 'Nurul Hikmah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510120095' AS no_kk, 'Jumaiyah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510120097' AS no_kk, 'Amaq Edy' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084107601384' AS no_kk, 'Khadijah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085009000000' AS no_kk, 'Hartini' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080511120013' AS no_kk, 'Aminah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082112210002' AS no_kk, 'Arma Sadira' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512110020' AS no_kk, 'Nurlaili' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402220005' AS no_kk, 'Sukarta' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512110052' AS no_kk, 'Inaq Mahnim' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120148' AS no_kk, 'Hajri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080608160004' AS no_kk, 'Zikri Alpian' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120153' AS no_kk, 'Abdul Rohim' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081407140008' AS no_kk, 'Ripal' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082509130020' AS no_kk, 'Lia Astuti' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409120051' AS no_kk, 'Sahirudin Efendi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120034' AS no_kk, 'Dian Supriadi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120029' AS no_kk, 'Suparlan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601150023' AS no_kk, 'Paris Tanzzilin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602120032' AS no_kk, 'Muhammad Ilmy' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084712130001' AS no_kk, 'Mayani' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130030' AS no_kk, 'Inaq Durahman' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602190015' AS no_kk, 'Asis Yanto' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602200009' AS no_kk, 'Yullinia' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081506100010' AS no_kk, 'Ipan Sugiman' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111150004' AS no_kk, 'Junita Lestari' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504140004' AS no_kk, 'Muhammad Adriawan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120054' AS no_kk, 'Rafa Nurfita Sari' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120056' AS no_kk, 'Nur Faiqa' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080608120080' AS no_kk, 'Aqila Zahrani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609120097' AS no_kk, 'Lalu Muhammad Pahrullah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609120098' AS no_kk, 'Bq. Bilgina Anisa Pitri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609170004' AS no_kk, 'Keysya Mauliana Sakina' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070231' AS no_kk, 'Yudi Rahmatullah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070430' AS no_kk, 'M. Aidil Hafizi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507240003' AS no_kk, 'M. Zaenudin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070500' AS no_kk, 'Rismawati' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070529' AS no_kk, 'Neni' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081501130030' AS no_kk, 'Sabnu' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070540' AS no_kk, 'Mirda Maulia' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412110081' AS no_kk, 'Zaenuddin' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082001140022' AS no_kk, 'Riska Ulandari' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120020' AS no_kk, 'Sarimah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120026' AS no_kk, 'I. Mahyuni' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120179' AS no_kk, 'Epa Asmiranda' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120182' AS no_kk, 'Natasya Maulida' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120186' AS no_kk, 'Jaelani' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120192' AS no_kk, 'Mawardi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120934' AS no_kk, 'Nurdan' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120202' AS no_kk, 'Alimah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806150017' AS no_kk, 'Nira Handayani' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120206' AS no_kk, 'Rendi Sunardi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120230' AS no_kk, 'Nanda Aulia' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120232' AS no_kk, 'Rabitah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080406120001' AS no_kk, 'M. Alfian Ramadan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010130098' AS no_kk, 'Lisabri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612110058' AS no_kk, 'Januardi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612110061' AS no_kk, 'M. Hamdan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612110062' AS no_kk, 'Perdi Pebrian Maulana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612110063' AS no_kk, 'Danil Purwanda' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207240003' AS no_kk, 'Zuwendi Ari Saputra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612120016' AS no_kk, 'Amaq Mis' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612120017' AS no_kk, 'Lohaeri Putrawan' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612120058' AS no_kk, 'M. Tirtian Ramadan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080701100001' AS no_kk, 'Nurhasanah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080702120015' AS no_kk, 'Fatir Ali Agis Dzikri' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120073' AS no_kk, 'Azril Setiawan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080702180010' AS no_kk, 'Nanda Nazwa' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909220004' AS no_kk, 'Aldi Antorik Ramadhani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080703140009' AS no_kk, 'M. Rizki Maulana' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080704140014' AS no_kk, 'Najwa Latifa' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080704160003' AS no_kk, 'Milka Rahayu Saputri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5204080111120106' AS no_kk, 'Muhammading' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705100055' AS no_kk, 'Baiq Siti Nassehan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120026' AS no_kk, 'Mahtum' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705190077' AS no_kk, 'Jamilah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412130020' AS no_kk, 'Neli Handayani' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707150013' AS no_kk, 'Bela Maulia' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707150015' AS no_kk, 'Hasifa Aurelia' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707190005' AS no_kk, 'Baiq Mentis' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081209240005' AS no_kk, 'Kamaludin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080709120072' AS no_kk, 'Inaq Gahar' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710070038' AS no_kk, 'Firman Maulidi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710110023' AS no_kk, 'Muhammad Amarullah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710120015' AS no_kk, 'Olinvia Sadin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082801150002' AS no_kk, 'Much. Zulfahmi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120005' AS no_kk, 'Ayu Permita' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120064' AS no_kk, 'Johanah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120077' AS no_kk, 'Muhammad Pauzi Azhar' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080509740003' AS no_kk, 'Anisa Padila' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120099' AS no_kk, 'M. Latipul Hobir' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120034' AS no_kk, 'Widia Agustina' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081906100033' AS no_kk, 'Nadia Ratna Ayu' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120028' AS no_kk, 'Kamaludin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712110018' AS no_kk, 'Winda Yustari' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712110020' AS no_kk, 'Inaq Muksan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080706140001' AS no_kk, 'Inaq Amrullah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120059' AS no_kk, 'Ahmad Ali Ramadhan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120102' AS no_kk, 'Lidia Arniansyah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082204150212' AS no_kk, 'Nurul Ayu Ningsih' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801130020' AS no_kk, 'Ely Febrianingsih' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801130048' AS no_kk, 'Apriliyani' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801150038' AS no_kk, 'Aisyah Adilah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801180009' AS no_kk, 'Anindia Keisha Azzahra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801210007' AS no_kk, 'Nabila Diandra Putri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087112050029' AS no_kk, 'Murya' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802120001' AS no_kk, 'Isbandi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802120029' AS no_kk, 'Rossan Suryana' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802120076' AS no_kk, 'Nasrullah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802130015' AS no_kk, 'Muhammad Jumahir' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802180013' AS no_kk, 'Indah Permata Sari' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203130802180015' AS no_kk, 'Rizky Budiman' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080800312002' AS no_kk, 'Jema' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805120036' AS no_kk, 'Sumrat' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805150034' AS no_kk, 'Rabiah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084502880004' AS no_kk, 'Zio Tanzilal' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901870001' AS no_kk, 'Muhrad' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080806100037' AS no_kk, 'Sofyan Saladin' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080806150002' AS no_kk, 'Dzaky Abdul Hadi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080861800090' AS no_kk, 'Muh. Haeriyadi' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807100063' AS no_kk, 'Yuliana Yamani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807100066' AS no_kk, 'Masdiana' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807100069' AS no_kk, 'Jawariah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080808120023' AS no_kk, 'Desi Liana Sari' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080810070063' AS no_kk, 'Abdul Faris' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120118' AS no_kk, 'Hidayaturrahman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080811110021' AS no_kk, 'Iwan Sadida' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080811110025' AS no_kk, 'Rifki Khairil Iqhwan' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812110002' AS no_kk, 'Qurnava Sa''Adah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120080' AS no_kk, 'Dlya Nabila Safa' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812110048' AS no_kk, 'Dwi Khaerul Ikhsan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812140005' AS no_kk, 'Riski Aditiya' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812140035' AS no_kk, 'Chika Wijayanti' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081601120071' AS no_kk, 'Mahyudin' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901100006' AS no_kk, 'Putri Ahira' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901100010' AS no_kk, 'M. Rizal Abidin' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901130010' AS no_kk, 'Moh. Imam Muslih' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082804230003' AS no_kk, 'Pandu Pranata' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082506240001' AS no_kk, 'Muhammad Fahyat Mutalib' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901150009' AS no_kk, 'Khalipah Majid Anwar' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120050' AS no_kk, 'Al Faqih Hafis Abdillah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080902120040' AS no_kk, 'Sabaruddin Hafis' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080603130012' AS no_kk, 'Moh. Irffan Rosadi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080902180004' AS no_kk, 'Kamariah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080903100010' AS no_kk, 'Haria Raya' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120017' AS no_kk, 'M. Ardian' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120059' AS no_kk, 'Riska Astira' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080211220001' AS no_kk, 'Sopiandi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120064' AS no_kk, 'Adri Paissal' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120071' AS no_kk, 'Algis Ganendra Ardani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081106240007' AS no_kk, 'Muh. Lukman' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120074' AS no_kk, 'Paijah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120078' AS no_kk, 'Haerul Supriyansah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080951200540' AS no_kk, 'Herman' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906140022' AS no_kk, 'Titi Sanjayani Putri Aulia' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609220015' AS no_kk, 'Masri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906150024' AS no_kk, 'Risma Aprilista' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906170005' AS no_kk, 'Baiq Putri Hayatunnufus' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907100016' AS no_kk, 'Jaelani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907100020' AS no_kk, 'Hulaini' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907120008' AS no_kk, 'Suriyani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081108150005' AS no_kk, 'Limbar Gunawan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120099' AS no_kk, 'Johratul Aeni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085101100002' AS no_kk, 'Sahni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907120036' AS no_kk, 'Agil Setiawan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080908140015' AS no_kk, 'Ali Akbar' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080909140006' AS no_kk, 'Asmara' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120092' AS no_kk, 'Andriadi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910130002' AS no_kk, 'M. Julian Hermanto' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082806120044' AS no_kk, 'Supiyandi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606120067' AS no_kk, 'Nursasih' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080912140021' AS no_kk, 'Sri Murtiati' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130010' AS no_kk, 'Inaq Cenin' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130037' AS no_kk, 'Kinarti' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082307000000' AS no_kk, 'Angga Setiawan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112700631' AS no_kk, 'Agus Toni' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001150014' AS no_kk, 'Suharti' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203131112008200' AS no_kk, 'Amir' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081002140006' AS no_kk, 'Ibnu Ali Sukur' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120052' AS no_kk, 'Abdul Rajap' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120069' AS no_kk, 'Adya Un Najah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005120029' AS no_kk, 'Muhammad Junaidi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005120059' AS no_kk, 'Rizki Adtya' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005120062' AS no_kk, 'Perdi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005120064' AS no_kk, 'Sundu' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5205080811110025' AS no_kk, 'Andi Azis' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009120008' AS no_kk, 'Ewin Azwardi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009120039' AS no_kk, 'Rico Adhitya Septiawan' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312140027' AS no_kk, 'Zuhratun Malihah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010110350' AS no_kk, 'Lalu Sofian' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010130050' AS no_kk, 'Supuq' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010140002' AS no_kk, 'Juwita Apriana' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010150003' AS no_kk, 'Nurasiah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203092912110041' AS no_kk, 'Raditia Haerurrizki' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305130006' AS no_kk, 'Sofia Ramadani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080808140002' AS no_kk, 'Muniah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010190010' AS no_kk, 'Muhammad Fathir Maulana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081011150007' AS no_kk, 'Diaz Alvi Fariski' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081011170007' AS no_kk, 'Hairul' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012130004' AS no_kk, 'Wira Jaya' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012130040' AS no_kk, 'Jamiludin Makbul' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120047' AS no_kk, 'Saepul Bahri' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081101170005' AS no_kk, 'Dina Rukmana' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120002' AS no_kk, 'Badrun Alaeka' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102160014' AS no_kk, 'Neli Adrian' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102170001' AS no_kk, 'Muhammad Rido Saputra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102190001' AS no_kk, 'L. Wildani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102190008' AS no_kk, 'Diana' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082003100030' AS no_kk, 'Chairil Nopri Lansura' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081103140010' AS no_kk, 'Nur Lathifa Az-Zahra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081103200002' AS no_kk, 'Supiana' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081104120043' AS no_kk, 'Sapiyah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081104140003' AS no_kk, 'Fira Anjanita Saputri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081105210008' AS no_kk, 'Haerul Haeromi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120013' AS no_kk, 'Nazila Iska Yolanda' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120067' AS no_kk, 'Badri' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107150007' AS no_kk, 'Saeful' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120000' AS no_kk, 'Anisa Hafika' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120005' AS no_kk, 'Devi Amalia' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120013' AS no_kk, 'Fikri Alwi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120129' AS no_kk, 'Irma Refiana' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120025' AS no_kk, 'Baiq Denisa Anindita' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120029' AS no_kk, 'Mu''Minah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120050' AS no_kk, 'Nurati' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082203120022' AS no_kk, 'Fani Azha Maura' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120053' AS no_kk, 'Alaman' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120057' AS no_kk, 'Haerul Azmi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080611200020' AS no_kk, 'Yusril Saputra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510130005' AS no_kk, 'Suci Ramadania' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120060' AS no_kk, 'Dodi Ade Saputra' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120079' AS no_kk, 'Halidi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120085' AS no_kk, 'Hawa' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080306760002' AS no_kk, 'Nuran Azani Adha' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120099' AS no_kk, 'Muhammad Arya Alfatih' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110110003' AS no_kk, 'Eliza Putri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120045' AS no_kk, 'Ratni' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120047' AS no_kk, 'Rohani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120050' AS no_kk, 'Ila Devi Astika' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120054' AS no_kk, 'Haerul' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081604120016' AS no_kk, 'Alifatul Khumaeroh' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081006220002' AS no_kk, 'Seleh' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110130008' AS no_kk, 'Hairudin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120007' AS no_kk, 'Adrean Okta Saputra' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120009' AS no_kk, 'Mahnim' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120010' AS no_kk, 'Tuti Hidayati' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082903220008' AS no_kk, 'Sawaludin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120012' AS no_kk, 'Inaq Nurhasanah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120013' AS no_kk, 'M.Ihsan Hasandi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080803220010' AS no_kk, 'Galih Dika Pratama' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '6403131205080008' AS no_kk, 'Hidayah Maolida' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120004' AS no_kk, 'Rama Septiadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120062' AS no_kk, 'Aisyah Febrina' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081201120055' AS no_kk, 'Hj. Nurbaeti' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081201170006' AS no_kk, 'Muhammad Erka Saputra' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202130045' AS no_kk, 'Nalisa Sistiara' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081908100009' AS no_kk, 'Mq. Haria' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082504120029' AS no_kk, 'Makrah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081203120024' AS no_kk, 'Arsa Al Hafiz' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081203190009' AS no_kk, 'Teguh Trimarta Arsyandi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081203190011' AS no_kk, 'Muhammad Sadam' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204100041' AS no_kk, 'Lalu Anjas Kelana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310120013' AS no_kk, 'Reni Darmayanti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120049' AS no_kk, 'Azra Mandita' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204120043' AS no_kk, 'Masenah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204120050' AS no_kk, 'Elsa Agustiawan Histi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204130015' AS no_kk, 'Rianti' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204130016' AS no_kk, 'Imam Zaky Bayanaka' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204130018' AS no_kk, 'Misniati' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204210005' AS no_kk, 'Rekiawan Lara Sandri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205100062' AS no_kk, 'Aedil Akbar' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205150003' AS no_kk, 'H. Sapi''I' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205150009' AS no_kk, 'M. Ridwan' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081207120036' AS no_kk, 'Nazma Zara Nasabila' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081208100008' AS no_kk, 'Muhamad Aedil' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081208150003' AS no_kk, 'Wanda Zulviana' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081210110009' AS no_kk, 'Muhammad Hasandi Maulana' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081210160006' AS no_kk, 'Akmal Pirmansah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211120039' AS no_kk, 'Rohyatul Aini' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130016' AS no_kk, 'Muslihadi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211120091' AS no_kk, 'Wahyu Arbani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080206220010' AS no_kk, 'Sahni' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710130026' AS no_kk, 'Sulhaini' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082208640001' AS no_kk, 'Ridwan' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212120055' AS no_kk, 'Lalu Supardi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507100051' AS no_kk, 'Asni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082903120017' AS no_kk, 'Arsoni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081213001500' AS no_kk, 'Bungawati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301120001' AS no_kk, 'Baiq Lina Septiana' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301150013' AS no_kk, 'Annisa Sofia Az Zahra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081304100024' AS no_kk, 'Lalu Muhammad Rafael' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120028' AS no_kk, 'Rendy Pratama' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081304170002' AS no_kk, 'Hedi Diana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081304170003' AS no_kk, 'Pratama Samudra Ahmad' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081305140018' AS no_kk, 'Aska Saputra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120045' AS no_kk, 'Niran Puspita Dewi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081305200002' AS no_kk, 'Herawati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012110093' AS no_kk, 'Lila Ray Asnamania' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081307100068' AS no_kk, 'Fathiyah Mariyati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011160001' AS no_kk, 'Saepul' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312138820' AS no_kk, 'Hadawiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081307150024' AS no_kk, 'Maolinda Sosilawati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803190012' AS no_kk, 'Muliasih' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081308120072' AS no_kk, 'Moch. Alwiansyah Prayudha' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120015' AS no_kk, 'Juhasan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120068' AS no_kk, 'Baiq Winanda Djayanthi Supin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112700485' AS no_kk, 'Nur Anisa Sifawati' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130025' AS no_kk, 'Sahlihin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081310120068' AS no_kk, 'Hardiansyah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120011' AS no_kk, 'M. Yusuf' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081210210010' AS no_kk, 'Roy Agustian Saputra' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120014' AS no_kk, 'Dita Aslika' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112890224' AS no_kk, 'Subahandi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120062' AS no_kk, 'Zuliva Yanti' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911110014' AS no_kk, 'Irwandi Saputra' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120083' AS no_kk, 'Repan Darmawansyah' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312138898' AS no_kk, 'Nadila Seftiani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120087' AS no_kk, 'Dian Febrianti' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100042' AS no_kk, 'Wahyu Tri Oktavioni' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120090' AS no_kk, 'Inaq Satiman' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312110135' AS no_kk, 'Abdul Rasyid' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312110138' AS no_kk, 'Marni' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312110146' AS no_kk, 'Nurmini' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312140010' AS no_kk, 'Zalfa Humaira' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401130032' AS no_kk, 'Fikri Wahyudi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210007' AS no_kk, 'Irnawati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210010' AS no_kk, 'Abd. Rahman' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402120010' AS no_kk, 'Muslim' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402120036' AS no_kk, 'Ahmad Dinejad' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402130003' AS no_kk, 'Riska Zulianti' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081403170009' AS no_kk, 'Lita Sari' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081403190007' AS no_kk, 'Wiwin Widuri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081404140011' AS no_kk, 'Nadira Saputri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081406120024' AS no_kk, 'Hosyiar Rahman' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070794' AS no_kk, 'Riza Kahfi Sinin' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081407200010' AS no_kk, 'Keri Karlina' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408120004' AS no_kk, 'Sumarni' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408120039' AS no_kk, 'Juliyandi Arrahim' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408120046' AS no_kk, 'Siti Raohon' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120043' AS no_kk, 'Yulia Erna' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081409200018' AS no_kk, 'Rina Apriana' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081410120062' AS no_kk, 'Yesi Aprilianti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081410120069' AS no_kk, 'Zahra Maulida Rohma' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081410120090' AS no_kk, 'Nadifa Meisya Putri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081410120133' AS no_kk, 'Della Febyaska' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120038' AS no_kk, 'Pathur' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212160003' AS no_kk, 'Alda Uttari' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009170005' AS no_kk, 'Rusmini' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120059' AS no_kk, 'Rohmadani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120061' AS no_kk, 'Dian Setiawan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080701011002' AS no_kk, 'Winda Pebriani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909120062' AS no_kk, 'Handika Saputra' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811140015' AS no_kk, 'Nurul Hasanah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502150015' AS no_kk, 'Muhammad Hary Heriean' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081501150029' AS no_kk, 'Anto' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012000000' AS no_kk, 'L.M Ikhwan Fatoni' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081503140004' AS no_kk, 'Haris' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081503160004' AS no_kk, 'Rohyani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081503180005' AS no_kk, 'Qamaria' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081503180013' AS no_kk, 'Nur' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081504130034' AS no_kk, 'Widya Maya' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081504150012' AS no_kk, 'Tiara Maulidya' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081106150016' AS no_kk, 'Masrodi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081505120052' AS no_kk, 'Dinda Ajuni' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081505120053' AS no_kk, 'Namira Sulistia' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081505180003' AS no_kk, 'Irna' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080101670005' AS no_kk, 'Aisyah Gina Nur Amalina' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081506200024' AS no_kk, 'Edowardi Saputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081508120066' AS no_kk, 'Amelinda' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120004' AS no_kk, 'Nurhayati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081307100110' AS no_kk, 'Jihan Kamilia' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120006' AS no_kk, 'Juliani' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120007' AS no_kk, 'Afdian Suherwin' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120026' AS no_kk, 'M. Mashudi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120027' AS no_kk, 'Wak Suhaemi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082808120073' AS no_kk, 'Hizban Sadiq' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120067' AS no_kk, 'Arzaqi Wisnu Syahfi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081510110005' AS no_kk, 'Bagus Harudiansyah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081510120102' AS no_kk, 'Sidik' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081511130003' AS no_kk, 'Rosada' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081511130005' AS no_kk, 'Muh. Rizal Ajuar' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110047' AS no_kk, 'Niken Anjani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110048' AS no_kk, 'Naera Sulastri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081601120026' AS no_kk, 'Purnawati' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081602100034' AS no_kk, 'Selfiana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081602190001' AS no_kk, 'Fitriana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081604120014' AS no_kk, 'Salma Nabila' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085006630001' AS no_kk, 'Nur Yolanda' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081607120119' AS no_kk, 'Wildan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081609071630' AS no_kk, 'Rosdiati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120054' AS no_kk, 'Nawawi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081610200004' AS no_kk, 'Jahira Anda Ana Maulida' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086330780002' AS no_kk, 'Lusiana Sapitri' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081611200008' AS no_kk, 'M. Nasrul Ananda' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612110049' AS no_kk, 'Muhammad Rizki' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612130014' AS no_kk, 'Hendriyanto' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612130023' AS no_kk, 'Lukman Jayadi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701100012' AS no_kk, 'Azka Rafasya' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701140011' AS no_kk, 'Hafiz Pranata' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120044' AS no_kk, 'Muhammad Khaibar' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112140005' AS no_kk, 'Abdul Hamid' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701150005' AS no_kk, 'Naela Monday Agustina' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701150006' AS no_kk, 'Nakila Saputri' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081702110003' AS no_kk, 'Fiqramadhan' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081703100005' AS no_kk, 'Putri Safina Reisa' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912120038' AS no_kk, 'Sainun' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704100052' AS no_kk, 'Jainudin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130018' AS no_kk, 'Hendra' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130021' AS no_kk, 'Nur''Aeni' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130022' AS no_kk, 'Elsa Safitri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087112670388' AS no_kk, 'Rahman Maulana' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130029' AS no_kk, 'Inaq Rehanun' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130032' AS no_kk, 'Jahra Tulaeni' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130037' AS no_kk, 'Muhammad Subandi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130042' AS no_kk, 'Intan Fitriani' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130045' AS no_kk, 'Inaq Isan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081705130005' AS no_kk, 'Yuda Riski Aditia' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081705160005' AS no_kk, 'Dimas Galih Febrian' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006160006' AS no_kk, 'Kusin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707120026' AS no_kk, 'Elisca Alta Tania' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707190010' AS no_kk, 'Kevin Renaldi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709120039' AS no_kk, 'Amsu Suriandi Arsi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709140005' AS no_kk, 'Sri Wahyuningsih' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203160601120010' AS no_kk, 'Tania' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710120019' AS no_kk, 'M. Rusli' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710120037' AS no_kk, 'A Rahman' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710120042' AS no_kk, 'Aqila Fahima Zalsya' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711110009' AS no_kk, 'Salsabila Shintya Sari' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811170004' AS no_kk, 'M. Alif Ilhamsyah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711110032' AS no_kk, 'Abian Syaqil Ramadhan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810100004' AS no_kk, 'Dira Nopinda' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711120017' AS no_kk, 'Kayla Maulidian Nazma' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711200018' AS no_kk, 'Hapsah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120018' AS no_kk, 'Saepul Hadi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120128' AS no_kk, 'Rehan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712140024' AS no_kk, 'Sriwulan' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081801120060' AS no_kk, 'Muhamad Reza Jaelani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081802140014' AS no_kk, 'Biandra Alfarizi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081802170003' AS no_kk, 'Hamid Hartana' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904130037' AS no_kk, 'Ifnu Riski Ramdani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086805090004' AS no_kk, 'Hardi Saputra' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081803190012' AS no_kk, 'Muhammad Dzaafir Al Fathir' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612110050' AS no_kk, 'Syakina Azzahra' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082010150010' AS no_kk, 'Razendra Zaimar' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081805150033' AS no_kk, 'Inaq Nurdin' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806150003' AS no_kk, 'Selsiyani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812110061' AS no_kk, 'Sahnan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081809170004' AS no_kk, 'Muhammad Toharudin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081501150018' AS no_kk, 'Nikmah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120028' AS no_kk, 'Iwal Jabarut' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081809190016' AS no_kk, 'Wirangga Putrabaya' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810110031' AS no_kk, 'Sukiani' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810110032' AS no_kk, 'Neli Maolidina' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120005' AS no_kk, 'Amaq Sukur' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120007' AS no_kk, 'Juli Auliana' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081603220007' AS no_kk, 'Inaq Minggih' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120009' AS no_kk, 'Inaq Sahuri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120010' AS no_kk, 'Windi Yuli Lastri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120011' AS no_kk, 'Nazuwa Aprilia' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120028' AS no_kk, 'Rahma Anisa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120029' AS no_kk, 'Randi Satrio' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610220007' AS no_kk, 'Rijal Suharenta' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111240004' AS no_kk, 'Novita Yuliana' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120071' AS no_kk, 'Maolinda' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120074' AS no_kk, 'Egis Pratama' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012007800' AS no_kk, 'Salimah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120082' AS no_kk, 'Riski Agustiar' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120134' AS no_kk, 'Asiah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120141' AS no_kk, 'Nonia Purwanti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810140010' AS no_kk, 'M. Ali Napiah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080108220004' AS no_kk, 'Adiba Fatma' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811160003' AS no_kk, 'Husnul Khotimah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811170003' AS no_kk, 'Nazilal Alfarabi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081901150001' AS no_kk, 'Komala' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081901150003' AS no_kk, 'Jumiyati' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120091' AS no_kk, 'Hariawan' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507100048' AS no_kk, 'Rohaeni' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903120062' AS no_kk, 'Rendi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903120067' AS no_kk, 'Arman' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903120071' AS no_kk, 'Nurziatin' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081203830004' AS no_kk, 'Buhari' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903200001' AS no_kk, 'Haeruman' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904120048' AS no_kk, 'Syifa Khairunnisa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904130039' AS no_kk, 'Cika Ramadani Alhusna' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904150000' AS no_kk, 'Indra Ardiansyah Putra' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081905100005' AS no_kk, 'Rizki Habiburrahman' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081905100011' AS no_kk, 'Firman Nurdiansyah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081905150015' AS no_kk, 'Feri Kurniawan Saputra' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080502180006' AS no_kk, 'Sadarudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602160003' AS no_kk, 'Risky Aditia' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112450218' AS no_kk, 'Ramli' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '4203082212140049' AS no_kk, 'Ririn Halwa Hazalfa' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510073377' AS no_kk, 'Siti Marlinawati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909190011' AS no_kk, 'Esti Putri Ayu' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081910110017' AS no_kk, 'Badrian Firmansah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081910110025' AS no_kk, 'Faoziah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081910110031' AS no_kk, 'Dapin Hariadi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112700206' AS no_kk, 'M. Nabil Alfarizy' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081911110006' AS no_kk, 'Latifa Nabila Tanisa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081911120093' AS no_kk, 'Kahpi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912110099' AS no_kk, 'Firmansyah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085606000006' AS no_kk, 'Moh. Jakaria Bin Hasan' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912110102' AS no_kk, 'Rusehan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912120036' AS no_kk, 'Yandri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912120111' AS no_kk, 'Hur' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912120123' AS no_kk, 'Andika Prastiyo' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082508000000' AS no_kk, 'Muhammad Ridwan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912140005' AS no_kk, 'Suriati' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711120023' AS no_kk, 'Sapriadi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080701620002' AS no_kk, 'Samsudin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912140037' AS no_kk, 'Baiq Tanty Widia Ningrum' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082001140001' AS no_kk, 'Mayang Salwati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082702120005' AS no_kk, 'Rina Safira' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082004120004' AS no_kk, 'Sarmia Deli' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5202020103160009' AS no_kk, 'Reza Maulana' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082004210011' AS no_kk, 'Fadila Nur Haliza' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120045' AS no_kk, 'Adrian' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120049' AS no_kk, 'M.amrozi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120050' AS no_kk, 'Randi Nasarudin' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120051' AS no_kk, 'Unzaratul Riskia' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006160009' AS no_kk, 'Juliandi Pratama' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212780002' AS no_kk, 'Reza Japar Parizi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100040' AS no_kk, 'Ulfa Maelani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080702220005' AS no_kk, 'Asia Widia Ningsih' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007110001' AS no_kk, 'Elza Zani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203230008' AS no_kk, 'Isma Alif' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009120153' AS no_kk, 'Bambang Khaerul Wathoni' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120047' AS no_kk, 'Inaq Suparman' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120106' AS no_kk, 'Intan Saputri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111220017' AS no_kk, 'Wahyudi Ramdani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120109' AS no_kk, 'Oby Hamdias' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011140011' AS no_kk, 'Ita Hendri Muafia' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011150008' AS no_kk, 'Randi Saputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082101160003' AS no_kk, 'Muhammad Bayu Suryadi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082101200002' AS no_kk, 'Haerul Wathon' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706220008' AS no_kk, 'Inaq Diok' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '0203082103110010' AS no_kk, 'Abdurahman Basyir' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312220001' AS no_kk, 'Titik Munawaroh' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120017' AS no_kk, 'Hilda Maherani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082104150038' AS no_kk, 'Isdina Mariana' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082104170005' AS no_kk, 'Raden Janitra Aswanda' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082105150024' AS no_kk, 'Susi Kurniati' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120026' AS no_kk, 'Ll. Akbar Harun' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120033' AS no_kk, 'Sahrul' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120037' AS no_kk, 'Sahrina' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120043' AS no_kk, 'Hanifah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106130006' AS no_kk, 'Indra Maolana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082108140008' AS no_kk, 'Zilvia Nuzula' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082110130057' AS no_kk, 'Muhsan' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111110011' AS no_kk, 'Mahnun' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111170010' AS no_kk, 'Nafica Embun Prayuna. S' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082201150002' AS no_kk, 'Abrel Rizki Tri Atmaja' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082201150008' AS no_kk, 'Sahra' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202100021' AS no_kk, 'Najmatun Sholihah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202100026' AS no_kk, 'Waes Bajadain' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202120009' AS no_kk, 'Adly Fairuz' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202120043' AS no_kk, 'M. Asanudin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202120044' AS no_kk, 'Lina Juliati' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202160003' AS no_kk, 'Nartika Suparti' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081106130031' AS no_kk, 'Inaq Ja''Nah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082203100034' AS no_kk, 'Rodiah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082204140017' AS no_kk, 'Lena Dira Istiani' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082204200060' AS no_kk, 'Eka Ayu Lestari' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205100039' AS no_kk, 'Vica Mahdalena' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205110003' AS no_kk, 'Ahmad' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120022' AS no_kk, 'Iqbal Al Idris' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120023' AS no_kk, 'Siti Azura' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120027' AS no_kk, 'Muhamad Ependi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120087' AS no_kk, 'Nova Era Fazira' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205130020' AS no_kk, 'Piana Lestari' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082206150016' AS no_kk, 'Muhamat Haerul Anwar' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080107950605' AS no_kk, 'Zaenal Abidin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082207130001' AS no_kk, 'Marjan' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080804220004' AS no_kk, 'Mahdan' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209120035' AS no_kk, 'Aminah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209120042' AS no_kk, 'Maisa Rani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209200003' AS no_kk, 'Rahmatul Aini' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082210160001' AS no_kk, 'Yuliastri' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082211110048' AS no_kk, 'Doni Alvino' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082211120080' AS no_kk, 'Rahman' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205100048' AS no_kk, 'Salsa Hira' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082211160011' AS no_kk, 'Syaeful Hairi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082010140002' AS no_kk, 'Nurjannah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082212110003' AS no_kk, 'Sumiati' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082212140017' AS no_kk, 'Bahrudin' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '4203082212140039' AS no_kk, 'Muslimin Amir' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082302120045' AS no_kk, 'Auliayana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082303150010' AS no_kk, 'Tini Wahyu Ningsih' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082303210003' AS no_kk, 'Ika Karunia' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304120005' AS no_kk, 'Arsil Nazril' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304120040' AS no_kk, 'Rian Hidayat' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304120057' AS no_kk, 'Inaq Siman' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304180005' AS no_kk, 'Rana Febrisa Pratama' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120033' AS no_kk, 'Inaq Satiah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130023' AS no_kk, 'Mahsin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305170003' AS no_kk, 'Nanda Amelia' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082306100032' AS no_kk, 'Sahnim' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082309120002' AS no_kk, 'Radiah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082309120005' AS no_kk, 'Muliana Sari' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082309160002' AS no_kk, 'Rihin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310120012' AS no_kk, 'Rohindi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120041' AS no_kk, 'Bahtiar Efendi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310120179' AS no_kk, 'Daeng Petta Bolek' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310170001' AS no_kk, 'Salsabila' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120014' AS no_kk, 'Filyan Aryandi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082311120017' AS no_kk, 'Tria Maulida Putri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082311180002' AS no_kk, 'Alifa Humaira Naufalyn' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312110026' AS no_kk, 'Galuh Fatmah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312110030' AS no_kk, 'Mario Naba' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312110051' AS no_kk, 'Sinarep Ruswandi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312110074' AS no_kk, 'Nurjanah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601890001' AS no_kk, 'Rian Sani' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312130019' AS no_kk, 'Epa Payanti' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402120004' AS no_kk, 'Mistuti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404120018' AS no_kk, 'Akhila Febriani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501670002' AS no_kk, 'Alamsyah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130025' AS no_kk, 'Pahmi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130028' AS no_kk, 'Hernawati' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804120056' AS no_kk, 'Aldi Saputra' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804120055' AS no_kk, 'Arningsih' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087112000000' AS no_kk, 'Patmah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406130007' AS no_kk, 'Sepah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406130008' AS no_kk, 'Maryam Alisa Yahsa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406130009' AS no_kk, 'Muhammad Rizka Siregar' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082407120119' AS no_kk, 'Didik Mahadi Saputra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082408160001' AS no_kk, 'Muhammad Guntur' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082408200010' AS no_kk, 'Herlina Widianingsih' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082409120026' AS no_kk, 'Azizah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410120014' AS no_kk, 'Andra Maulidan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082005240006' AS no_kk, 'Dini Novianti' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410120145' AS no_kk, 'Elsa Ayu Putri' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412130021' AS no_kk, 'Sumarni' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081702210005' AS no_kk, 'Heri Swandi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501120004' AS no_kk, 'Baiq Rukyal Aini' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501210001' AS no_kk, 'Tamrin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082502130016' AS no_kk, 'Yuli Andriani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082503190005' AS no_kk, 'Andriani' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912140007' AS no_kk, 'Abu Faranata Agil Hidayatuloh' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082504130028' AS no_kk, 'Jihad Fisabilillah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082504150004' AS no_kk, 'Sulaeman' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082506140007' AS no_kk, 'Jaenap' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507120074' AS no_kk, 'Baiq Rachel Anindita Putri Wahyudi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507150009' AS no_kk, 'Jusmayadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507170021' AS no_kk, 'Zainudin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082509190019' AS no_kk, 'Rina Rosita' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510120037' AS no_kk, 'Nurlaela' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802230006' AS no_kk, 'Jaenudin Sani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510120042' AS no_kk, 'Wari Abial Sanjaya' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510120046' AS no_kk, 'Maulia Farida' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510120049' AS no_kk, 'Irwan Jayadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511110036' AS no_kk, 'Abdul Rahim' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511130022' AS no_kk, 'Pandi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511190012' AS no_kk, 'Juniarti' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602140010' AS no_kk, 'Haerul Adnan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602180002' AS no_kk, 'Bolang' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602180004' AS no_kk, 'Elda Nopitasari' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603120060' AS no_kk, 'Widriani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082608120061' AS no_kk, 'Fanila Haerul Nisa' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907240006' AS no_kk, 'Usnul Hotimah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603120063' AS no_kk, 'Febi Akila' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603190001' AS no_kk, 'Harianto' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082604210001' AS no_kk, 'Ayu Lestari' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605100023' AS no_kk, 'Sakmah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605150016' AS no_kk, 'Saimah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120012' AS no_kk, 'Andi Saputra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606120012' AS no_kk, 'Naura Zilfauza' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082707150012' AS no_kk, 'Raniya Herdah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607100060' AS no_kk, 'Subedah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607120022' AS no_kk, 'Moh. Sultan Putra D' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607120099' AS no_kk, 'Suardi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607190001' AS no_kk, 'Suhaeri' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120124' AS no_kk, 'Imran Haeris' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120138' AS no_kk, 'Alphiyan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080806230006' AS no_kk, 'Baiq Aisma Noer Mariyam' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811000000' AS no_kk, 'Lalu Satria Wira Dani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120140' AS no_kk, 'Widiatun' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120141' AS no_kk, 'Rahmawadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120148' AS no_kk, 'Rohana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610110059' AS no_kk, 'Lalu Burhanudin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610110066' AS no_kk, 'Saeah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130034' AS no_kk, 'Dewi Fazira' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611120033' AS no_kk, 'Aldo Solehandi Sa''Eh' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611130014' AS no_kk, 'Alpandi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082612120020' AS no_kk, 'Vina' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204120045' AS no_kk, 'Nadia Ramdina' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082702130002' AS no_kk, 'Rusdi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082702180008' AS no_kk, 'Elvan Juliadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082702190006' AS no_kk, 'Adifa Arsya' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112750488' AS no_kk, 'Pajri Akbar' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120028' AS no_kk, 'Nurdin' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120048' AS no_kk, 'Muhammad Zarkasih' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703180005' AS no_kk, 'Lalu Muhammad Ibrahim' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082704100002' AS no_kk, 'Alya Khumaeroh' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082704210003' AS no_kk, 'Susilawati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203008270612002' AS no_kk, 'Abdul Hafiz' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706120026' AS no_kk, 'Rifky Andrian Saputra' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5204308220912004' AS no_kk, 'Inaq Serun' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402140010' AS no_kk, 'Ayu Astiani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082707150001' AS no_kk, 'Erna Wati' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082708120091' AS no_kk, 'Abian Saputra' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082710120006' AS no_kk, 'Amirullah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501230005' AS no_kk, 'Nur Hamidah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082711130022' AS no_kk, 'Lismayanti' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712110137' AS no_kk, 'Imam Hudori' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082701212002' AS no_kk, 'Sahudi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712130009' AS no_kk, 'Sumiati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712180001' AS no_kk, 'Arga' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712800120' AS no_kk, 'Siti' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082801150009' AS no_kk, 'Nadifa Ayu Qanita' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082801200003' AS no_kk, 'Kuswaldi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120023' AS no_kk, 'Subedah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802140002' AS no_kk, 'Pina Apriani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802180003' AS no_kk, 'Rusnan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080706230006' AS no_kk, 'Sohdi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802180004' AS no_kk, 'Nika Rohidawati' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120027' AS no_kk, 'M. Samuil' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120029' AS no_kk, 'Herul' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120032' AS no_kk, 'Muhammad Anam Al Ayubby' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009240010' AS no_kk, 'Aolin Qoin Fortuna' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130015' AS no_kk, 'Erik Setiawan' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130022' AS no_kk, 'Arjuna Yuliand Prawira' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT 'BLM ADA KK' AS no_kk, 'Tanwir Sopian' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803180015' AS no_kk, 'Ali Karimi Fathar' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082805120025' AS no_kk, 'Muhammad Pandi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082805120068' AS no_kk, 'M. Sahrul' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081902240008' AS no_kk, 'Tatang Hidayat' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082207000000' AS no_kk, 'Reza Gerinaldi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080107840975' AS no_kk, 'Ahmad Rayan Kadafi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082807100073' AS no_kk, 'Ahmad Pathullah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082808140004' AS no_kk, 'Rapiah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507120024' AS no_kk, 'Ibrahim' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082809120111' AS no_kk, 'Nauval Yazid Rosidi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082809120112' AS no_kk, 'Baiq Zaskia Aulia Rahma' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082805120113' AS no_kk, 'Rahmayana Nabila' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082810140010' AS no_kk, 'Naura Abdilla' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811120028' AS no_kk, 'Muhayanah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811120035' AS no_kk, 'Tantri Abeng Sasaki' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811140002' AS no_kk, 'Annisa Okky Aida' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812110121' AS no_kk, 'Rosma Eka Raetiah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812120022' AS no_kk, 'Nurdiana' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081505120038' AS no_kk, 'Majid Sa''Id' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082902160002' AS no_kk, 'Arman Aidil Wasila' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082903120031' AS no_kk, 'Alifa Saputri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082903180005' AS no_kk, 'Mohamad Rizal' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082905120034' AS no_kk, 'Firly Aulyal Salsani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085507650024' AS no_kk, 'Hamzah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082906120011' AS no_kk, 'Abyan Azhari Rafadhan' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082906150100' AS no_kk, 'Muhammad Sahrul Pahri' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907100059' AS no_kk, 'Alwan Jayadi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907100081' AS no_kk, 'Musanip' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907160002' AS no_kk, 'Afkan Maulana' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907160006' AS no_kk, 'Armo Guntur Pratama' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082908140014' AS no_kk, 'Dika' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811140004' AS no_kk, 'Azzam Khalif Prasetya Harianto' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909120024' AS no_kk, 'Hafizah Az Zahra Shatin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087112550401' AS no_kk, 'Rusmiatun' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120055' AS no_kk, 'Dedi Wardiman' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120059' AS no_kk, 'Inaq Muhammad' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120061' AS no_kk, 'Nanda Saputra' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087112670282' AS no_kk, 'Suknah' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606840002' AS no_kk, 'Muliaton' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120087' AS no_kk, 'Jasrodi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120135' AS no_kk, 'Hasanah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006160010' AS no_kk, 'Sri Ayu Ningsih' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911110017' AS no_kk, 'Ega Ardian' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120011' AS no_kk, 'Umar' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120015' AS no_kk, 'Ria Septiani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909120064' AS no_kk, 'Yudi Sukma Yanto' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130106' AS no_kk, 'Erwindi Kutama' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120023' AS no_kk, 'Iyan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120032' AS no_kk, 'Andri Askarwadi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081207220002' AS no_kk, 'Samsul Bahri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120035' AS no_kk, 'Sahrul' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807240010' AS no_kk, 'Asnah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120052' AS no_kk, 'Resky Almaisa Mansab' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120072' AS no_kk, 'M. Fathan Mi''Raj' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120073' AS no_kk, 'Samsul Rizal' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911140013' AS no_kk, 'Uswatun Hasanah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120106' AS no_kk, 'Marlina Dewi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083001100039' AS no_kk, 'Siti Laeli' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083001120089' AS no_kk, 'Ulul Azmi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083003160008' AS no_kk, 'Ridho Karnadi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083003210006' AS no_kk, 'Marhan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120031' AS no_kk, 'Alifky Maulana Hasan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901180015' AS no_kk, 'Ihsan Sainudin Akmal' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507110005' AS no_kk, 'Muhamad Sabri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083004120045' AS no_kk, 'Nazilatin Fitri' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083004130023' AS no_kk, 'Haerani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083004150017' AS no_kk, 'Suryani' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083005120025' AS no_kk, 'Riski' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083005120027' AS no_kk, 'Lalu Panji Pebriansyah Harlan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083005120040' AS no_kk, 'Rahmat Hidayat' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083006120003' AS no_kk, 'Napilatul Amni Aini' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083006120010' AS no_kk, 'Lalu Haidar Arsalan Baqir' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083007120006' AS no_kk, 'Sanusi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009120007' AS no_kk, 'Titik Rahmawati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009130011' AS no_kk, 'Febrian Aditia Putra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120032' AS no_kk, 'Syafiq Haerul Ihwan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906150022' AS no_kk, 'Misbalili Anti' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120045' AS no_kk, 'M. Alif Baihaqi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120091' AS no_kk, 'Haerul' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120094' AS no_kk, 'Suriadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120106' AS no_kk, 'M. Arjo Zurrohman' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701230014' AS no_kk, 'Ardi Sopian Jayadi' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120109' AS no_kk, 'Mustikmah' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120114' AS no_kk, 'M. Alif Pratama' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120116' AS no_kk, 'Inaq Ceah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081112150001' AS no_kk, 'Zaenudin' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120121' AS no_kk, 'Patahurrahman' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011110005' AS no_kk, 'Nurul Wahida' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011120007' AS no_kk, 'Sahib' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011120049' AS no_kk, 'Rahmawati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011700030' AS no_kk, 'Arya Syabani' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012110027' AS no_kk, 'Sahrum' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012110071' AS no_kk, 'Zidan Rivaldo' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083101120056' AS no_kk, 'Ilham' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083101180003' AS no_kk, 'Rina Ristia' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083103170001' AS no_kk, 'Selemah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107100069' AS no_kk, 'Naya Agus Apriliani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120007' AS no_kk, 'Dendi Alfarizi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120042' AS no_kk, 'Linta Seftiana' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120062' AS no_kk, 'Lalu Askar Saputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120086' AS no_kk, 'Sintia Haerani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080803230007' AS no_kk, 'Noviana Riniasrani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107180009' AS no_kk, 'Azlan Rinjani Yusuf Alfatih' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083108150008' AS no_kk, 'Atteo Joyusha Albaidar' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120035' AS no_kk, 'Suhaebah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120039' AS no_kk, 'Bahrawi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120067' AS no_kk, 'Mas''Ud' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807100052' AS no_kk, 'Sahrul Gunawan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120089' AS no_kk, 'Maesarani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112130013' AS no_kk, 'Senap' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203102904130006' AS no_kk, 'Dodi Irawan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203141304120020' AS no_kk, 'Diah Sari Ningrum' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203172811120005' AS no_kk, 'Hasna Suaria Fathmita' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5208050202180001' AS no_kk, 'Dio Alfarizy' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203813091007300' AS no_kk, 'Marwa Aulia Ramadani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203180004' AS no_kk, 'Dewi Yulianti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080106150001' AS no_kk, 'Sudirman B Murni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081409000000' AS no_kk, 'Supardi Rahman' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203011012003000' AS no_kk, 'Hae Ah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907170002' AS no_kk, 'Muhamad Rusnan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120021' AS no_kk, 'Inaq Masitah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081911150004' AS no_kk, 'Dia Alpiani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081601120069' AS no_kk, 'Mulyadi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080107000000' AS no_kk, 'Saepul Bahri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203 0818 0412M0053' AS no_kk, 'Juliani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082303210001' AS no_kk, 'Saturiah' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130075' AS no_kk, 'Annisa Nadifa' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120041' AS no_kk, 'Jumadil' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203170004' AS no_kk, 'Ari Agustiawan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120033' AS no_kk, 'Rolyan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120038' AS no_kk, 'Rizky Dwi Ardianto' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086809000000' AS no_kk, 'Inaq Kamah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084905000000' AS no_kk, 'Nurhayati' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705120007' AS no_kk, 'Ratna' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081703100036' AS no_kk, 'Hasanudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212140022' AS no_kk, 'Muhammad Daffa Febrian' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130014' AS no_kk, 'Amaq Her' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512000000' AS no_kk, 'Amaq Muliadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086801000000' AS no_kk, 'Risda Yanti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203131112007800' AS no_kk, 'Haerunnizam' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203030113004400' AS no_kk, 'Ahmad Ripa''I' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112000000' AS no_kk, 'Mahrip' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080309120095' AS no_kk, 'Inaq Kartini' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082705000000' AS no_kk, 'Zidan Hermansah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085505000000' AS no_kk, 'Novitasari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080402140023' AS no_kk, 'Sa''Mah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120011' AS no_kk, 'Tina Rosita' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120075' AS no_kk, 'M. Azka Irsyadul Ibad' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120079' AS no_kk, 'Amaq Kinok' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082407120033' AS no_kk, 'Masiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009170004' AS no_kk, 'Siti Aisyah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080112800002' AS no_kk, 'Lalu Sukarlan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080502140013' AS no_kk, 'Dika Diantari' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080503160013' AS no_kk, 'Silvie Aprilia Anggraini' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120013' AS no_kk, 'Agung Wahyudi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120014' AS no_kk, 'Murtini' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120022' AS no_kk, 'Yek Ahmat' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602120073' AS no_kk, 'Haerudin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080305000000' AS no_kk, 'Roni Andri Ake' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081008210005' AS no_kk, 'Dading Qolbiadi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510007222' AS no_kk, 'Yasin Akbar' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082105120043' AS no_kk, 'Suharti' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5202022002081203' AS no_kk, 'Joni Siswadi' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602140011' AS no_kk, 'Rania Dahyatul Handayani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130019' AS no_kk, 'Nurjaen' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086402000000' AS no_kk, 'Nirmala Hidayati' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5205080804000000' AS no_kk, 'Frinandi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710150004' AS no_kk, 'Muhammad Bahtiar' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305160018' AS no_kk, 'Rina Apriani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203060912007100' AS no_kk, 'Hapasiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605150031' AS no_kk, 'Muliani' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070718' AS no_kk, 'Sapardi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810076655' AS no_kk, 'Mariani' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120209' AS no_kk, 'Caco' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705120008' AS no_kk, 'Sudarmi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312140009' AS no_kk, 'Inaq Goden' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080209130003' AS no_kk, 'Muh. Sopian Hidayat' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010160002' AS no_kk, 'Inaq Mahyun' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081303240002' AS no_kk, 'Helva Mariana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712110064' AS no_kk, 'Dafin Adila Pratama' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085705000000' AS no_kk, 'Mahesabrina' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084107000000' AS no_kk, 'Jannatul Jannah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710000000' AS no_kk, 'Irwanto' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080702000000' AS no_kk, 'Sabrun' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084203000000' AS no_kk, 'Nurul Hidayanti' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080810070120' AS no_kk, 'Fitrika Desawalia' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203110712002100' AS no_kk, 'Laude Marniah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203291012005200' AS no_kk, 'Ahyar Rosidi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086311000000' AS no_kk, 'Hapasa Mahreni' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506000000' AS no_kk, 'Elfan Mahrojal' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084802000000' AS no_kk, 'Haerani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209120116' AS no_kk, 'Adam Faiz Al Arkan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082103160010' AS no_kk, 'Muhammad Hanif El Hafizd' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085204000000' AS no_kk, 'Magpiratun Hair' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084106000000' AS no_kk, 'Nita Apriani' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080101920010' AS no_kk, 'Karmiji Tahir' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904130025' AS no_kk, 'Karmila' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203090710001700' AS no_kk, 'Zakaria Baco''' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910140004' AS no_kk, 'Muhammad Roby' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080911120003' AS no_kk, 'Raranti Sara' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112720422' AS no_kk, 'Mahsun' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081002160007' AS no_kk, 'M. Tirta Saputra' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081911120002' AS no_kk, 'Rusli' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312138715' AS no_kk, 'Mariana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603120036' AS no_kk, 'Suhendi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082201190006' AS no_kk, 'Siti Maysarah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086907000000' AS no_kk, 'Vrisila Ariyanti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085804000000' AS no_kk, 'Afrilia Putri Lestari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086503000000' AS no_kk, 'Sartufil Laeli' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301000000' AS no_kk, 'Suhirman Jauhari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084103000000' AS no_kk, 'Muar' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203110912004100' AS no_kk, 'Dirga Maulana Saputra' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512710005' AS no_kk, 'Akta Maulana' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085010000000' AS no_kk, 'Nuriana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084608000000' AS no_kk, 'Naura Azzahro' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081705910003' AS no_kk, 'Haerul Anam' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082401190015' AS no_kk, 'Fariz Maulana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210120044' AS no_kk, 'Surahman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203141112005100' AS no_kk, 'Yuliana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081607190013' AS no_kk, 'Mirnawati' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212130020' AS no_kk, 'Sri Wahyuni' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086701000000' AS no_kk, 'Alin Nasya Febrian' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085001000000' AS no_kk, 'Deny Saputra' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082806000000' AS no_kk, 'Junaedi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411000000' AS no_kk, 'Danu Ilman Hidayat' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203094602000000' AS no_kk, 'Sispiatul Ilma' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805000000' AS no_kk, 'Herman Wirahadi Nirmawan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081608210008' AS no_kk, 'Herman Jaelani' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082504240002' AS no_kk, 'Roni Sahriandi' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120020' AS no_kk, 'Samsul Hadi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120035' AS no_kk, 'Fitriani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080903200012' AS no_kk, 'Maulida Aprilia' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5201012202180006' AS no_kk, 'Hadri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203150410002200' AS no_kk, 'Bayu Saputra' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203280411001300' AS no_kk, 'Abdullah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080604000000' AS no_kk, 'Angga Wardani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612140023' AS no_kk, 'Abu Sopian' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203131112008100' AS no_kk, 'Fathan Abidzar Al-Ghifari' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120035' AS no_kk, 'Sunaria' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120071' AS no_kk, 'Ardan Setiawan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210120105' AS no_kk, 'Muhammad Rosi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402120063' AS no_kk, 'Johar Maligan' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082509120042' AS no_kk, 'Lalu Moh. Firman Azhari' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081014000900' AS no_kk, 'Darmatasia' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081404200004' AS no_kk, 'Nur''Aeni' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120053' AS no_kk, 'Abdul Muthalib' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203151015000300' AS no_kk, 'Amalia Quraini' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203140812004100' AS no_kk, 'Heriyadi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081405110044' AS no_kk, 'Rabiah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084503000000' AS no_kk, 'Sumiati Aris' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084107070348' AS no_kk, 'Ilham' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120079' AS no_kk, 'Basri' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203130715000500' AS no_kk, 'Faris Haidarrahman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080704000000' AS no_kk, 'Putra Aprian' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083006000000' AS no_kk, 'M. Saleh' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080112200003' AS no_kk, 'Hariadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '0801130000050000' AS no_kk, 'Mahrip' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512210001' AS no_kk, 'Aisya Fatmawati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602190016' AS no_kk, 'Armi Yunita' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805150035' AS no_kk, 'Adriana Wahyu Nisa' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120046' AS no_kk, 'Herman Apandi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081609130018' AS no_kk, 'Halimah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704120023' AS no_kk, 'Supriadi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402190007' AS no_kk, 'Sahnim' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704100028' AS no_kk, 'Ramnah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130036' AS no_kk, 'Misnah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081802170002' AS no_kk, 'Acih' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080703000000' AS no_kk, 'Adnan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810100003' AS no_kk, 'Habariah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710240004' AS no_kk, 'Andi Saputra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '8203081810130007' AS no_kk, 'Puspa Aspirani Putri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901000000' AS no_kk, 'Hamdani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081905160008' AS no_kk, 'Jufri' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801150015' AS no_kk, 'Haeril Anwar' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086008000000' AS no_kk, 'Setiara' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086606000000' AS no_kk, 'Juni Astuti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082200715000' AS no_kk, 'Sumiati' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5202083110120091' AS no_kk, 'Deni Sahran Wardani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082112170011' AS no_kk, 'Marlina' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082502210004' AS no_kk, 'Supiat' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203220512003200' AS no_kk, 'Suriati' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009000000' AS no_kk, 'Rahmat' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082912000000' AS no_kk, 'Faesal Anwar' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082301130032' AS no_kk, 'Raeni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312170006' AS no_kk, 'Suhirman Jaya' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085210690001' AS no_kk, 'Ade Bagus Febriadin' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203022204240006' AS no_kk, 'Amaq Epol' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082407120095' AS no_kk, 'Mila Safana' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120120' AS no_kk, 'Salman Alfarizi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082210120050' AS no_kk, 'Risma Cahyati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806120012' AS no_kk, 'Ansori' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203020413001700' AS no_kk, 'Asiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082509130018' AS no_kk, 'Nursiah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083004140002' AS no_kk, 'Sariah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082509190021' AS no_kk, 'Anwar' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203260612001800' AS no_kk, 'Ernawati' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082505000000' AS no_kk, 'Lalu Buhari Muslim' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611120030' AS no_kk, 'Nazila Wahida' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085110000000' AS no_kk, 'Ayasha Oktora' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086101000000' AS no_kk, 'Yosita Amelia' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086209000000' AS no_kk, 'Baiq Harpaini' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081905000000' AS no_kk, 'Moh. Jamil' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904120050' AS no_kk, 'Kaharudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082612110019' AS no_kk, 'Dina Agustina' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087007000000' AS no_kk, 'Julia Haerun Nisa Safitri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120071' AS no_kk, 'Satria' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120036' AS no_kk, 'Husni Wati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081082130041' AS no_kk, 'Zulmayadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084412000000' AS no_kk, 'Sumiati' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120030' AS no_kk, 'Tina' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012140015' AS no_kk, 'Tindustiani' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082809170008' AS no_kk, 'Ijtihadul Ihsan' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120007' AS no_kk, 'Inaq Rusmini' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082903180003' AS no_kk, 'Sairah' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610200008' AS no_kk, 'Susanti' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202000000' AS no_kk, 'Riski Maolidan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086308000000' AS no_kk, 'Tia Ulandari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082908160001' AS no_kk, 'Supriadi Harianto' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911110013' AS no_kk, 'Arsila Rahmayanti' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120108' AS no_kk, 'Gilang Al Rahman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084904000000' AS no_kk, 'Reni Apriana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203076711000000' AS no_kk, 'Nurhasanah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080706000000' AS no_kk, 'Arjunaedi Saputra' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011120033' AS no_kk, 'Masitah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082504140003' AS no_kk, 'Siti Nurhayani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082409190003' AS no_kk, 'Muhammad Uzakil Buyan' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084204000000' AS no_kk, 'Hasti Minanti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084101000000' AS no_kk, 'Sumiati' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080101000000' AS no_kk, 'Hasbullah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120040' AS no_kk, 'Nurminah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111000000' AS no_kk, 'Sopian Azhari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080902720001' AS no_kk, 'Yuliana' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082206150011' AS no_kk, 'Putri Febrianti' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501120080' AS no_kk, 'Rusdi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203086605000000' AS no_kk, 'Maelani Rahmawati' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704000000' AS no_kk, 'Lukman Hadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203084312000000' AS no_kk, 'Rahimin' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120018' AS no_kk, 'Saparudin Rayub' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909150004' AS no_kk, 'Ariyandani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080702230003' AS no_kk, 'Rahman' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '3510170507180001' AS no_kk, 'Icang Nurdiansyah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130026' AS no_kk, 'Inaq Mel' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507150010' AS no_kk, 'Japar' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203088612220001' AS no_kk, 'Gunawan Hadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080306140004' AS no_kk, 'Inaq Bolang' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081405120021' AS no_kk, 'Bi''Ah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120229' AS no_kk, 'Inaq Amenah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312140035' AS no_kk, 'Musmujiono' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120024' AS no_kk, 'Sidin' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609230001' AS no_kk, 'Pahrul Anhar' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081302200008' AS no_kk, 'Supriadi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410070257' AS no_kk, 'Hisbulloh' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5271042710140003' AS no_kk, 'Suherman' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT 'Istri' AS no_kk, '"Yuli Amelia Kustanti' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081609000000' AS no_kk, 'Junaidi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082905120076' AS no_kk, 'Bahudin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203143112000000' AS no_kk, 'Feri Sam Devi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203142408000000' AS no_kk, 'M.Riki Saputra' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082005110033' AS no_kk, 'Sahdan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709140003' AS no_kk, 'I.Minah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083401000000' AS no_kk, 'Duruk' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080503120004' AS no_kk, 'Mahani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507120002' AS no_kk, 'Mak Sati' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010130036' AS no_kk, 'M.Nasir' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081002120028' AS no_kk, 'Juni Hardi' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT 'B.R0000000000000' AS no_kk, 'Sabarudin' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120006' AS no_kk, 'Amirah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203162805240001' AS no_kk, 'Jamalia' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081004230003' AS no_kk, 'Harianti' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203182701180004' AS no_kk, 'Heriadi Purnama' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203085502000000' AS no_kk, 'Elka Mardianti' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911140012' AS no_kk, 'Novia Sabrina' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409100010' AS no_kk, 'A. Baeah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120008' AS no_kk, 'Mulyadi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111230003' AS no_kk, 'Yusriadi' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5204080504190004' AS no_kk, 'Azharudin' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203091406240002' AS no_kk, 'Haeranah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205160005' AS no_kk, 'Joni Efendi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083008120072' AS no_kk, 'Anhar' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082612120019' AS no_kk, 'Hilman' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081800412005' AS no_kk, 'M. Saleh' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082311120018' AS no_kk, 'Husaeni' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203088505100016' AS no_kk, 'Putra Jaya Kesuma' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120012' AS no_kk, 'Zuliati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120051' AS no_kk, 'Ll. Suhendi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120012' AS no_kk, 'Sakka' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304120067' AS no_kk, 'Alyan Aftar Sulaeman' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081705190003' AS no_kk, 'Lalu Rizal Fahmi' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120018' AS no_kk, 'Yuna Sukma Putri' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082505230017' AS no_kk, 'Mardianti' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082405210005' AS no_kk, 'Marisa Allesha' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109230007' AS no_kk, 'Vira Egitia Yuliarti' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081705230008' AS no_kk, 'Eka Safitri' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080406210007' AS no_kk, 'Ariyan Syaqil' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082709210004' AS no_kk, 'Lola Agustina' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120106' AS no_kk, 'Muhamad Rizky Ardian' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010180006' AS no_kk, 'Elsa Nofiana' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205230003' AS no_kk, 'Haerisa' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210170005' AS no_kk, 'Yeni Kafisya' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404150020' AS no_kk, 'Yama Alkiran' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203161911240001' AS no_kk, 'Sutri' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009120032' AS no_kk, 'Hanin Feishiika Efendi' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080202145997' AS no_kk, 'Salman' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080303140020' AS no_kk, 'Asiyah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409100022' AS no_kk, 'Abd. Taha' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312139148' AS no_kk, 'Sulmah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412130008' AS no_kk, 'Patmah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130005' AS no_kk, 'Rabiah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203021012004600' AS no_kk, 'Mahru' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203180912007900' AS no_kk, 'Hamdil' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312138161' AS no_kk, 'Yuliana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712120047' AS no_kk, 'Rumi Khalik D' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120036' AS no_kk, 'Hana Astuti' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312138252' AS no_kk, 'Majiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909140011' AS no_kk, 'Basuki' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130008' AS no_kk, 'Iysmayanti' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212130011' AS no_kk, 'Anwar Ramli' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080104140020' AS no_kk, 'Hj. Sadarah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081808900004' AS no_kk, 'Hendra Yudi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081601100001' AS no_kk, 'Inam Safi''I' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909120032' AS no_kk, 'Agung Dwi Riski Apria' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082904200010' AS no_kk, 'Mukminah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120095' AS no_kk, 'Srifuji Lestari' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082503000000' AS no_kk, 'Wq. Gapar' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203087172000000' AS no_kk, 'Andara Aula Halimatul.r' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '3206222905170002' AS no_kk, 'Tahany Syakira' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5201090404130001' AS no_kk, 'Abiy Ahmad Messi Aydin Thohari' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203050910130025' AS no_kk, 'Ll. Haeri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203070402130010' AS no_kk, 'Wagirin' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080102120022' AS no_kk, 'Muhammad Dedi Irawan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080103120005' AS no_kk, 'Amelia Febrianti' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080104210012' AS no_kk, 'Rahmah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080105120006' AS no_kk, 'Shelina Dwi Al Bahri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080106150002' AS no_kk, 'Jupriadi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080107120003' AS no_kk, 'Abil Rizkian' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080107190006' AS no_kk, 'Haikal' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080108120017' AS no_kk, 'Andini Lestari' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080108180004' AS no_kk, 'Zulkarnaen' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080108180009' AS no_kk, 'Galang Julian Jayadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110120030' AS no_kk, 'Suparlan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110120117' AS no_kk, 'Jaenuddin' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110120118' AS no_kk, 'Sukaena' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110130007' AS no_kk, 'Daham' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110130015' AS no_kk, 'H. Karhi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110140006' AS no_kk, 'Muhammad Risman' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080110180015' AS no_kk, 'Akbar Saputra' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120031' AS no_kk, 'Munirah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120037' AS no_kk, 'Yuhana Lestari' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120038' AS no_kk, 'Zilfan Hadi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120042' AS no_kk, 'Inaq Hartono' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120043' AS no_kk, 'Muhamad Tatan Suyatman' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120067' AS no_kk, 'Muh. Zunaedi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120070' AS no_kk, 'Saipul Basri' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120102' AS no_kk, 'Rohida' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111170005' AS no_kk, 'Mariana' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080112110059' AS no_kk, 'Lofia' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080112140006' AS no_kk, 'Inaq Nasrun' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080112140039' AS no_kk, 'Ilham Wahyudi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080112150001' AS no_kk, 'Zaena Amelia Dita' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201120034' AS no_kk, 'Bq. Maulida Shilviati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130001' AS no_kk, 'Ruba''' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130046' AS no_kk, 'Dg. Arsad' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130055' AS no_kk, 'Nurdin' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130076' AS no_kk, 'Rakiyya Nadiva Saputri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080201130111' AS no_kk, 'Novriyanto' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080202150007' AS no_kk, 'Muhayani' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080202210010' AS no_kk, 'Jannatul Faizah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203120003' AS no_kk, 'Syukur. S' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203160006' AS no_kk, 'Randi Afrilian' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080203180007' AS no_kk, 'Ida Royani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120032' AS no_kk, 'Zabar Rahman' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120035' AS no_kk, 'Muhammad Abdul Rasid' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120037' AS no_kk, 'Ridwan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120041' AS no_kk, 'Muh. Abdul Razak' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120053' AS no_kk, 'Aripin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204120086' AS no_kk, 'Aris Sandi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204190016' AS no_kk, 'Ma''Iah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080204200002' AS no_kk, 'Ruhyanti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080206170003' AS no_kk, 'Farihami' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207120003' AS no_kk, 'Samsul' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207180008' AS no_kk, 'Samini' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080207180011' AS no_kk, 'Abdul Ersan Khalik Iqdam' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208120014' AS no_kk, 'Upak' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208160015' AS no_kk, 'Abel Siren Natasya' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208180001' AS no_kk, 'Hesti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080208190003' AS no_kk, 'Noval Khairul Ikhwan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080209140012' AS no_kk, 'M. Zafir Maulidan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080209160001' AS no_kk, 'Rudy Syarif' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210120046' AS no_kk, 'Nahrul Hayat' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210130028' AS no_kk, 'Jelita Septiana' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210130038' AS no_kk, 'M. Rizal Indra Saputra' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080210190018' AS no_kk, 'Ahmad Al Fhareza Ramadan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080211200016' AS no_kk, 'Aisah' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212140017' AS no_kk, 'Nasri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212140025' AS no_kk, 'Alfina Rahma' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080212160007' AS no_kk, 'Muhsi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130005' AS no_kk, 'Andi Abdul Asis' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130018' AS no_kk, 'M. Yunus' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130026' AS no_kk, 'Reni Rossida' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130035' AS no_kk, 'Saimah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130036' AS no_kk, 'Basri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130038' AS no_kk, 'Aqila Azzahra' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130043' AS no_kk, 'Sumanan Sa''Id' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080301130044' AS no_kk, 'Syakira Binar Ramadhani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080302140007' AS no_kk, 'Raimah' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080302150007' AS no_kk, 'Ramdani' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080302150030' AS no_kk, 'Iin Dawati' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080303150010' AS no_kk, 'Selah' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120008' AS no_kk, 'Nurminah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120038' AS no_kk, 'Widia Ayu Wardani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120040' AS no_kk, 'Hadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120043' AS no_kk, 'Marliana Dewi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304120049' AS no_kk, 'Saknah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080304140002' AS no_kk, 'Sulaeman' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080306150018' AS no_kk, 'Arisah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080306150020' AS no_kk, 'Inaq Enah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080307120015' AS no_kk, 'Aditya Naufal Dary Abyyu' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080307130010' AS no_kk, 'Mirna Wati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080308170004' AS no_kk, 'M. Rizal' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080309160001' AS no_kk, 'Sadina Talefta' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080309160002' AS no_kk, 'Zia Anida Ayu' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080309200010' AS no_kk, 'Sendi Marjaya' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310130003' AS no_kk, 'Surjana Arlian' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310160011' AS no_kk, 'Suhardi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310190020' AS no_kk, 'Zohraeni' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080310190037' AS no_kk, 'Suriani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080311120001' AS no_kk, 'Asmu''I' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080311200001' AS no_kk, 'Whanda Gustiana' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080311200018' AS no_kk, 'Sahabudin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312120036' AS no_kk, 'Roby Febian' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312140017' AS no_kk, 'M. Suryanto' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080312200010' AS no_kk, 'Ozzal Bhuyan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080401210008' AS no_kk, 'Muhammad Azizan Asfa' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403150002' AS no_kk, 'Anisa Juni Arika' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403150016' AS no_kk, 'Muhamad Fahrul Gunawan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403210001' AS no_kk, 'Zahraeni' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080403210007' AS no_kk, 'Siti Aisyah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120072' AS no_kk, 'Erwin Tiok' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404120076' AS no_kk, 'Sak''Mah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404130001' AS no_kk, 'Rohani' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404140007' AS no_kk, 'Mardin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404160004' AS no_kk, 'Rohaida' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404160006' AS no_kk, 'Haerana' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080404180008' AS no_kk, 'Wulandari' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080405180008' AS no_kk, 'Haerani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080405200006' AS no_kk, 'Suwandi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080405200007' AS no_kk, 'Haesum' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080406200018' AS no_kk, 'L. Wiranata Kusuma' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080407120049' AS no_kk, 'Mila Wahyuni' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080407120054' AS no_kk, 'Ririn Oktarini' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408100028' AS no_kk, 'Elvan Maulana Yusuf' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408140016' AS no_kk, 'Rahma Sapitri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408140017' AS no_kk, 'Fitriyah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080408140022' AS no_kk, 'Ardian Diwanesa' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409100023' AS no_kk, 'Azril Al Fatih' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409100050' AS no_kk, 'Hurun ''in' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409120056' AS no_kk, 'Malina Sari' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409150005' AS no_kk, 'Darmawan' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080409190006' AS no_kk, 'Muhammad April' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410120057' AS no_kk, 'M. Zaky Aly Sabana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410120115' AS no_kk, 'Hamdani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080410120163' AS no_kk, 'Mariani' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412120058' AS no_kk, 'Ami Okto Ardi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412120061' AS no_kk, 'Syarafuddin' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412120068' AS no_kk, 'Bq. Hidayatul Karmila' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412120114' AS no_kk, 'Nahar' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412130007' AS no_kk, 'Ichal Syaputra' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080412170009' AS no_kk, 'Judin' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501100011' AS no_kk, 'Fariz Naufal Hadi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501120025' AS no_kk, 'Erwin Maulana' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501150071' AS no_kk, 'Caimah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080501150072' AS no_kk, 'Yeni Wulandari Bt Dahmur Moi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080502150012' AS no_kk, 'Elizawati' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080502150014' AS no_kk, 'Rohani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080502160005' AS no_kk, 'Ida Farida' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080503120016' AS no_kk, 'Bapak Kar' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080503200014' AS no_kk, 'Arjuna' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504120025' AS no_kk, 'Haeriah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504180008' AS no_kk, 'Isah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080504210013' AS no_kk, 'Indri Arenta' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505100032' AS no_kk, 'Eko Pramana Putra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505180001' AS no_kk, 'Rusmawati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505180002' AS no_kk, 'Senep' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505180003' AS no_kk, 'Senep' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505180004' AS no_kk, 'Rawinah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505180005' AS no_kk, 'Sain' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505180006' AS no_kk, 'Siman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505200009' AS no_kk, 'Sapurah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080505210031' AS no_kk, 'Hamidi Khairil Amri' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506200002' AS no_kk, 'Dedi Iskandar' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080506200003' AS no_kk, 'Muknim' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507100028' AS no_kk, 'Subhan' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507120039' AS no_kk, 'Muhammad Haiqal Alfina Shammakh' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507140003' AS no_kk, 'Nafsiah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080507140009' AS no_kk, 'Fujiah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080508150009' AS no_kk, 'Fatmah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080508160003' AS no_kk, 'Siti Amainah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080508200003' AS no_kk, 'Ely Susanti' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080509180007' AS no_kk, 'Hadasia' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510070133' AS no_kk, 'Sule' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510070962' AS no_kk, 'Rimah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510072044' AS no_kk, 'Jumadel' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510072273' AS no_kk, 'Haidar Lutfi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510072951' AS no_kk, 'Baiq Karunia Saputri' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510073229' AS no_kk, 'Shinta Aulia Nindi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510073289' AS no_kk, 'Azizah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510073411' AS no_kk, 'Halimatussakdiyah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510110012' AS no_kk, 'Wasa Budin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080511140009' AS no_kk, 'Arman Toni' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080511200012' AS no_kk, 'Aini Puspita' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120151' AS no_kk, 'Sulpaiyah' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120158' AS no_kk, 'Dedi Suprian' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120159' AS no_kk, 'Abd. Rahim' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512120165' AS no_kk, 'Arjuna Rahman Manunggara' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080512140012' AS no_kk, 'Erlyta Talita Zahra' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601150018' AS no_kk, 'Rafamu' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601150020' AS no_kk, 'Miati' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601150022' AS no_kk, 'Yasin' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601150028' AS no_kk, 'Sarman' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080601150040' AS no_kk, 'Muhammad Hilal' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602120057' AS no_kk, 'Perdian Syah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602130006' AS no_kk, 'Muhamad Malik Al Patin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602170004' AS no_kk, 'Nadira Azka Putri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602170007' AS no_kk, 'Ridho Arfan Nazril P.' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602180001' AS no_kk, 'Inaq Jumaiyah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080602190010' AS no_kk, 'Alfira Fitri Astuti' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080603150004' AS no_kk, 'Raudatul Nazwa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080603170001' AS no_kk, 'Irma Julita' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080603190009' AS no_kk, 'Muhammad Rais' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080606180009' AS no_kk, 'Rafita' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080607180006' AS no_kk, 'Siti Hadijah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080608120054' AS no_kk, 'Nazwari Saputri' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080608190002' AS no_kk, 'Kamaludin' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609100035' AS no_kk, 'Pidia Lestari' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609100038' AS no_kk, 'Khaerel Anwar' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609120026' AS no_kk, 'Muhammad Aqhil Alvian Ali' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080609120096' AS no_kk, 'Suratman' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070152' AS no_kk, 'Bella Fujiwati Artini' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070299' AS no_kk, 'Bayu Iniesta Permadani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070804' AS no_kk, 'Mariama' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610070938' AS no_kk, 'Reza Hasyim' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120207' AS no_kk, 'M. G. Atta Putra' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120210' AS no_kk, 'M. Imam Al Mazid' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610120212' AS no_kk, 'Meldi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080611170004' AS no_kk, 'Agus Budiato' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612120087' AS no_kk, 'Rusidi' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612120088' AS no_kk, 'Sayuti' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080612170006' AS no_kk, 'Muhammad Hairil Adam' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080701190005' AS no_kk, 'Lydia Ririn Sendyane' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080703160005' AS no_kk, 'Sahar' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080703180012' AS no_kk, 'Erna Septiana' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080704200005' AS no_kk, 'Clara Dini Sapitri' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080704210007' AS no_kk, 'Muji Hastuti' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705100006' AS no_kk, 'Sirna Ariyawan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705100070' AS no_kk, 'Pandak' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705120005' AS no_kk, 'Saharudin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705150010' AS no_kk, 'Rudi Susianto' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705180001' AS no_kk, 'Nisa Ardila' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705180010' AS no_kk, 'Junaidi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080705210001' AS no_kk, 'Lalan Suherlan' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707120011' AS no_kk, 'Amaq Ais' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080707190004' AS no_kk, 'Nuh' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080709120029' AS no_kk, 'Lalu Muhamad' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080709120078' AS no_kk, 'Sasmita Hamida' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080709150008' AS no_kk, 'Muhammad Islal' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710110021' AS no_kk, 'Afra Naila Arkarna' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710120059' AS no_kk, 'Allisa Choira' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710130123' AS no_kk, 'Ahmat Haeri' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080710170006' AS no_kk, 'M. Samsul Arifin' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120003' AS no_kk, 'Ma''Rah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120009' AS no_kk, 'Mahsun' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120075' AS no_kk, 'Abdul Malik' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120081' AS no_kk, 'M. Faisal Ramli' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080711120107' AS no_kk, 'Mela Rosa' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712110006' AS no_kk, 'Ida Sopyani' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712110007' AS no_kk, 'Jumadil' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712110059' AS no_kk, 'Kurniadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120040' AS no_kk, 'Wahyudi Zulkarnain' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120055' AS no_kk, 'Isnawati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120057' AS no_kk, 'Indrawati' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120058' AS no_kk, 'Muhamamd Jamil' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120061' AS no_kk, 'Wahyudi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120076' AS no_kk, 'Inaq Ari' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120107' AS no_kk, 'Luthfiah Syahid' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712120109' AS no_kk, 'Tiara Indah Nursa''Adah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712150002' AS no_kk, 'Zulkarnaen' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712200003' AS no_kk, 'Inaq Mar' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080712200006' AS no_kk, 'Mislah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801150039' AS no_kk, 'Ahmad Wahyu Iqbal Alfaro' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802120078' AS no_kk, 'Sahrol' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080802180015' AS no_kk, 'Azka Raffasya' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080803130003' AS no_kk, 'Muhammad Zaeni' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080803210012' AS no_kk, 'Sul Akbar' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080804190004' AS no_kk, 'Muhammad Alino Alka Hanu' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080804200006' AS no_kk, 'Dewi Yulianti' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805130014' AS no_kk, 'M. Hasan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805140004' AS no_kk, 'Hamizan Al Fareza' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805150019' AS no_kk, 'Junaedi' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080805150036' AS no_kk, 'Marfina Saputri' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080806180009' AS no_kk, 'Ridwan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807140011' AS no_kk, 'Azril Alfarizky' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080807190005' AS no_kk, 'Rumasih' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080808150002' AS no_kk, 'Syafiq Fathur Rahman' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080808160006' AS no_kk, 'Pusfita' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080809140011' AS no_kk, 'Fatmah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080809200005' AS no_kk, 'Mariadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080810130030' AS no_kk, 'Novi Ariska' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080810140009' AS no_kk, 'Razita Nafizah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080810200007' AS no_kk, 'Lisdian Vitaloka' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080811110023' AS no_kk, 'Makmur' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812110013' AS no_kk, 'Alkina Adhani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812140045' AS no_kk, 'Yandi Suhendra' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080812140049' AS no_kk, 'Muhammad Abdul Nabil' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901130040' AS no_kk, 'Tri Semara Sahbandi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901150006' AS no_kk, 'Dandi Noviandi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080901200011' AS no_kk, 'Hasri H' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080902120049' AS no_kk, 'Siti Hadijah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080902150020' AS no_kk, 'Sahrul Hadi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080903100019' AS no_kk, 'M. Ainul Yaqin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080903120005' AS no_kk, 'Mustakim' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080903180003' AS no_kk, 'Arta Nabil' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080903180004' AS no_kk, 'Zian Arta Saputra' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904120009' AS no_kk, 'Mila Handayani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904180011' AS no_kk, 'Dika Pratama' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080904210007' AS no_kk, 'Muhammad Uzakil Bhuyan' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080905120004' AS no_kk, 'Ahmad Alfareza Rhamadan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080905120050' AS no_kk, 'Safri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080905120075' AS no_kk, 'Rusni' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080905150003' AS no_kk, 'Haerudin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906150030' AS no_kk, 'Mella Auliya' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906160005' AS no_kk, 'Fahmi Mu''Thi Attahir' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906160006' AS no_kk, 'Khairul Ana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080906160008' AS no_kk, 'Diviya Humaira' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907100017' AS no_kk, 'Aska Diarahman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080907120028' AS no_kk, 'Lisman' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080908100005' AS no_kk, 'Akhmad Badri' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080908140016' AS no_kk, 'Ena' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080908140017' AS no_kk, 'Galih Dika Pratama' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080909140005' AS no_kk, 'Fatimah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080909200003' AS no_kk, 'Fitriyah Zaetul Jannah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080909200005' AS no_kk, 'Mariamah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910130021' AS no_kk, 'Nanik Susanti' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910130032' AS no_kk, 'Saepudin' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910170006' AS no_kk, 'Halifah Safitri' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910180001' AS no_kk, 'Hartini' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080910180013' AS no_kk, 'Sudirman' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080911200011' AS no_kk, 'Lailatul Dimi Almiranti' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080912130002' AS no_kk, 'Juliadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080912140024' AS no_kk, 'Risma Auliya Putri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130035' AS no_kk, 'Fitri Riyanti' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130057' AS no_kk, 'Ratna' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130082' AS no_kk, 'Bapak Liana' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130103' AS no_kk, 'Lilik' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001130109' AS no_kk, 'Dina Septia Sari' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081001190007' AS no_kk, 'Muhamad Arkhan Alkaromi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081002150002' AS no_kk, 'Sahuriah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081002210005' AS no_kk, 'Halida Isna Ningsih' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081003200014' AS no_kk, 'Restina' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081003210013' AS no_kk, 'Muliadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005120021' AS no_kk, 'Tiara' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005120027' AS no_kk, 'Juliani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005160007' AS no_kk, 'Azim Siddiq Arrafif' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005190001' AS no_kk, 'Renata Putri Maulani' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081005210008' AS no_kk, 'Baiq Miranda' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081006140020' AS no_kk, 'Misnawati' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081006150005' AS no_kk, 'El Khais Hanafi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081007170005' AS no_kk, 'Marhan' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081007190008' AS no_kk, 'Apriwi Hastiwi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081008160005' AS no_kk, 'Rehanah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081008170006' AS no_kk, 'Aklema Almahyra Putri' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009120040' AS no_kk, 'Mak Duruk' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009120041' AS no_kk, 'Nuridah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009120045' AS no_kk, 'Devi Harniati' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009130018' AS no_kk, 'Sugianto' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081009190011' AS no_kk, 'Okhan Gibran Yahya' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010140014' AS no_kk, 'Muhammad Faisal' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010190006' AS no_kk, 'Moh. Zikri Ramadhan' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010190008' AS no_kk, 'Fardan Nabiyyil' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081010190009' AS no_kk, 'Suherlianik' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081011140009' AS no_kk, 'Muhammad Rosi Anwir' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081011200014' AS no_kk, 'Roy Hartony' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012130033' AS no_kk, 'Saparuddin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012140011' AS no_kk, 'Inaq Asmu''I' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012140023' AS no_kk, 'Nadhira Zaruriya' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012140027' AS no_kk, 'Handayani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012140050' AS no_kk, 'Sandi Saputra' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012150006' AS no_kk, 'Salsa Bila' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012190007' AS no_kk, 'Handayani' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081101190009' AS no_kk, 'Fitria Salsabilla' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081101210014' AS no_kk, 'Amat' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102100030' AS no_kk, 'Siti Zulaeha' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102140023' AS no_kk, 'Rinasih' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102150025' AS no_kk, 'Marjannah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081102210006' AS no_kk, 'Nurul Hidayati' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081103190003' AS no_kk, 'Duruk' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081104120035' AS no_kk, 'Daeng Hasan' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081104160002' AS no_kk, 'Muhammad Sepinhari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081104190009' AS no_kk, 'Moh. Hazwan Bin Daud' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081105150004' AS no_kk, 'Faoziah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081105200007' AS no_kk, 'Hernawati' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081106130032' AS no_kk, 'Indun Paraila' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081106190001' AS no_kk, 'M.Rizal' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120001' AS no_kk, 'Nursam' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120019' AS no_kk, 'Maskanah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120021' AS no_kk, 'Khalisa Agustina Aulia' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120035' AS no_kk, 'Zaskia Abqori''Ah Azahra' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081107120041' AS no_kk, 'Alfika Widya Amalia Rachmi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081108140010' AS no_kk, 'La Ardimas Ismaputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081108160001' AS no_kk, 'Papuk Min' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120008' AS no_kk, 'Moh. Taufik' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120041' AS no_kk, 'Arfan Saputra' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120054' AS no_kk, 'Zulhaela' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120059' AS no_kk, 'Nurbaeti' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120061' AS no_kk, 'Nesa Juana' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120084' AS no_kk, 'Mulyadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120086' AS no_kk, 'Randi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120097' AS no_kk, 'Patahi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081109120098' AS no_kk, 'Baiq Salsabila Atika Wijaya' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120058' AS no_kk, 'Malika Aulani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110120102' AS no_kk, 'Nazifa Musdiana' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081110130002' AS no_kk, 'Waq Gaffar' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111120011' AS no_kk, 'Saidi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081111190015' AS no_kk, 'Sa''Diah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081112120095' AS no_kk, 'Rendi Holikulbayan' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081112130010' AS no_kk, 'Nasrudin' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081112140005' AS no_kk, 'Ihsan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081112190006' AS no_kk, 'Deki Ahmad Muhlisin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081201150014' AS no_kk, 'M. Izmuel Hady' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081201150023' AS no_kk, 'Adzkia Qiandra Sulaiman' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202130004' AS no_kk, 'M. Abdul Sumata' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202140009' AS no_kk, 'Rama Yudha' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202160008' AS no_kk, 'Wahid' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081202190002' AS no_kk, 'Dodi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081203120013' AS no_kk, 'Dini Haerunnisa' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081203120014' AS no_kk, 'Amaq Jumaiyah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204100045' AS no_kk, 'Sudirman' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204120005' AS no_kk, 'Risma Baizura' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204120033' AS no_kk, 'Masri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081204140003' AS no_kk, 'M. Alfian' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205150019' AS no_kk, 'Raisya Adila Kurniawan' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081205150021' AS no_kk, 'Evi Asrianti' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081208140010' AS no_kk, 'Mustakim' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081208190004' AS no_kk, 'Baiq Rahma Yani' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081208190010' AS no_kk, 'Sahtum' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081210180004' AS no_kk, 'Lidya Arlini' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081210200006' AS no_kk, 'Sholihin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211120011' AS no_kk, 'Napisah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211120045' AS no_kk, 'Subandi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211120093' AS no_kk, 'Nikmatul Maola' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211140012' AS no_kk, 'Inaq Nuridah' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211150004' AS no_kk, 'Almuttaqin' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081211190002' AS no_kk, 'Ridho Hambali' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212120004' AS no_kk, 'Asrah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212120092' AS no_kk, 'Sal Sabila' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212130001' AS no_kk, 'Reniyati' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212130015' AS no_kk, 'Riskawati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081212180015' AS no_kk, 'Andri Adi Juliansah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301120007' AS no_kk, 'Sahabudin' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301120011' AS no_kk, 'Hamdah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301150018' AS no_kk, 'Nurhatimah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301200004' AS no_kk, 'Tamma Uni' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081301200015' AS no_kk, 'Dewi Indah Widiawati' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081302140003' AS no_kk, 'Nurfadillah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081302190004' AS no_kk, 'Andi Indra Azhari' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081303140015' AS no_kk, 'Muhammad Al Fahri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081303140017' AS no_kk, 'Yuanisa Harriani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081304150005' AS no_kk, 'Dwiki' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081304150006' AS no_kk, 'Rubiyah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081304150007' AS no_kk, 'Canun' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081305140013' AS no_kk, 'Adelia Putri Diana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081305150001' AS no_kk, 'Si''Ar Bilal Akbar' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081305160001' AS no_kk, 'Viki Ardanu' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081305190002' AS no_kk, 'Mariam' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081306200006' AS no_kk, 'Nia Ramadani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081307150025' AS no_kk, 'Yayan Kurniawan Syah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081307180001' AS no_kk, 'Agung Hidayat' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120024' AS no_kk, 'Iwan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120060' AS no_kk, 'Yudi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120071' AS no_kk, 'Nadiya Rismanandari' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120073' AS no_kk, 'Julyana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309120086' AS no_kk, 'Sibianul Muhtar' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309170004' AS no_kk, 'Supardi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081309190004' AS no_kk, 'Husaeni' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081310110046' AS no_kk, 'Arsyadana Faiturrahman' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081310120005' AS no_kk, 'Baiq Erlin Septriana' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120013' AS no_kk, 'Rio Efendi' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120017' AS no_kk, 'Habariah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120039' AS no_kk, 'Amaq Sahudin' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120053' AS no_kk, 'Amaq Ruslan' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120058' AS no_kk, 'Napasa Asipa Rizki' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120078' AS no_kk, 'Azzam Khalif Putra' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120079' AS no_kk, 'Nurul Reza Sopiana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120081' AS no_kk, 'El Jundi Gibran Ar-Rasyid' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120082' AS no_kk, 'Nurshida Bin H. Said' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120084' AS no_kk, 'Wardatul Hayani' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120085' AS no_kk, 'Ramdani' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311120089' AS no_kk, 'Anisa Fitri Abidah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311130020' AS no_kk, 'Jasman' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312110101' AS no_kk, 'Fitriani' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081312140007' AS no_kk, 'Sumiati' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401130041' AS no_kk, 'Abiel Zain' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401130082' AS no_kk, 'Usiandi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401150016' AS no_kk, 'Sayuni Setiawan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401150021' AS no_kk, 'Riska' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401200001' AS no_kk, 'Sitti Rahmani' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210001' AS no_kk, 'Abdul Hapid' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210003' AS no_kk, 'Mahnim' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210005' AS no_kk, 'Sahabudin' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210006' AS no_kk, 'Tedi Hartadi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210008' AS no_kk, 'Mirjan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210009' AS no_kk, 'Rusni' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210011' AS no_kk, 'Risnawati' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210012' AS no_kk, 'Ahmad Junaedi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402120001' AS no_kk, 'Alpan Gibran' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402120009' AS no_kk, 'Lukman Hakim' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402150012' AS no_kk, 'Rahmi Saputra' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402180006' AS no_kk, 'Keisna Yumna Kartini' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402190014' AS no_kk, 'Dian P' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081402190015' AS no_kk, 'Wahyu' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081403160001' AS no_kk, 'Inaq Sumerah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081404210007' AS no_kk, 'Suharni' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081405190001' AS no_kk, 'Rosyan Al Fajani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081405190011' AS no_kk, 'Huswatun Hasanah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081406160004' AS no_kk, 'Nur Samsu' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081407140010' AS no_kk, 'Risman Aditiya Maulana' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081407200007' AS no_kk, 'Agus' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408140015' AS no_kk, 'Milka Sabrina Putri' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408180002' AS no_kk, 'Ibrahim' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408180005' AS no_kk, 'Baharuddin' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408200002' AS no_kk, 'Ahmadi Jaya' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081409180005' AS no_kk, 'Bilal Atallah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081409200001' AS no_kk, 'Buang Supriadi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081410120102' AS no_kk, 'M. Aula Anafis' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120049' AS no_kk, 'Husniawati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120077' AS no_kk, 'Asiah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411120086' AS no_kk, 'Mahnim' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081411160004' AS no_kk, 'Aqila Aprilia Putri' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081412110023' AS no_kk, 'Rauyatul Fitri' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081412160004' AS no_kk, 'Andi Novi Suryawati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081501150012' AS no_kk, 'Muhamad Fikriadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502120011' AS no_kk, 'Amar Dhani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502120019' AS no_kk, 'Siti Rani Reda' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502160002' AS no_kk, 'Sulmah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502190003' AS no_kk, 'L. M. Rizki Teguh Muslim' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502190009' AS no_kk, 'Dini Prasetiati Aisah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081502210009' AS no_kk, 'Isah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081503180006' AS no_kk, 'Zahiratun Aqila' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081503180007' AS no_kk, 'Asiah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081504190002' AS no_kk, 'Hamma' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081504190003' AS no_kk, 'Apriyawan' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081504200006' AS no_kk, 'Melinda Astuti' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081505120014' AS no_kk, 'Bayu Kurniawan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081506150009' AS no_kk, 'Salwa Abila' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081506150021' AS no_kk, 'Razik Maulana Ar-Rafan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081506170004' AS no_kk, 'Lalu Muhammad Rafasya Alfath' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081506200005' AS no_kk, 'Ruhun' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081507140003' AS no_kk, 'Asmaul Rufaezi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081507200003' AS no_kk, 'Anggi Saputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081508120048' AS no_kk, 'Jufriadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081508130008' AS no_kk, 'Ahmad Yani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081508140005' AS no_kk, 'Mariati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081508160003' AS no_kk, 'Rehanun' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081508180006' AS no_kk, 'Dewi Chantika' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509120073' AS no_kk, 'Inaq Sahirudin' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081509200001' AS no_kk, 'Andin Annasya Ramadhani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081510120016' AS no_kk, 'Juandi Satria Bayu' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081510190013' AS no_kk, 'Anggi Salsuangi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081511110011' AS no_kk, 'Rohyati' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081511110015' AS no_kk, 'Alisa Jasmin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081511170005' AS no_kk, 'Kaysa Rizki Ilhami' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081511180006' AS no_kk, 'Salman Al Farisi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110042' AS no_kk, 'Hasnah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110049' AS no_kk, 'Juniarta' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110067' AS no_kk, 'Reni Usnawati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110102' AS no_kk, 'Pendi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081512110105' AS no_kk, 'Hendra' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081601190003' AS no_kk, 'Miranti' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081602150018' AS no_kk, 'Ismi Wardani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081603180001' AS no_kk, 'Suci Darmawanda' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081604140003' AS no_kk, 'Saqila Nahla' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081604150002' AS no_kk, 'Hanapi Badli' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081605120021' AS no_kk, 'Wira Sari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081605120045' AS no_kk, 'Ratna Sari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081606200005' AS no_kk, 'Julia Atika' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081607120085' AS no_kk, 'Alzea Nayla Mafaza' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081607160007' AS no_kk, 'Jihad' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081607190001' AS no_kk, 'Muh. Nabil Riski' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081609160001' AS no_kk, 'Risma' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081610120007' AS no_kk, 'Tama Ardiatma' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081610120021' AS no_kk, 'Fatan Al Hadi Maulana' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081610140022' AS no_kk, 'Burhanudin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081611110005' AS no_kk, 'Muhammad Ahzan' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081611110006' AS no_kk, 'Saidah Sapitri' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612130008' AS no_kk, 'Sa''Ah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612140049' AS no_kk, 'Sulastri' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081612140061' AS no_kk, 'Fahri Husaeni' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701140012' AS no_kk, 'Amaq Sahrudin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701140015' AS no_kk, 'Zikri Rosi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081701150007' AS no_kk, 'Arwin Mikrin' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081703100044' AS no_kk, 'Albi Dwi Pradifta' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081703160013' AS no_kk, 'Alika Nayla Putri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704120025' AS no_kk, 'Khaerin Afriza' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130024' AS no_kk, 'Sandri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130027' AS no_kk, 'Muh. Yani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130031' AS no_kk, 'Yasih' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130035' AS no_kk, 'Na''Im' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081704130039' AS no_kk, 'Alvin Zaidar Al Vandi' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081706140010' AS no_kk, 'Iq Ijah' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081706200008' AS no_kk, 'Salmin' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081707120026' AS no_kk, 'Dwi Holita Apriandini' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081707180004' AS no_kk, 'Nada Winarti Eliza' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081707190010' AS no_kk, 'Umi''Atul Khaeri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709120047' AS no_kk, 'Muhammad Rafi Aditia' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709120059' AS no_kk, 'M. Haafidz Azzam Sahid Firdaus' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709130008' AS no_kk, 'Muazin' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081709140009' AS no_kk, 'Elvania' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710120043' AS no_kk, 'Irene Silviana Erpa' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710120057' AS no_kk, 'Danil Nazwa' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081710130027' AS no_kk, 'Sardin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711110001' AS no_kk, 'Marjan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711120010' AS no_kk, 'Sakdiah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711120013' AS no_kk, 'Hairil' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711120015' AS no_kk, 'Irwan Rahmat Akbar' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711120016' AS no_kk, 'Sumiati' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711140013' AS no_kk, 'Hajjah Hasnah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711140027' AS no_kk, 'Winda Saputri' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711140038' AS no_kk, 'Rina Apriani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081711200003' AS no_kk, 'Arpin Hendriawan' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120030' AS no_kk, 'Lahaming' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120114' AS no_kk, 'Husen' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120115' AS no_kk, 'Tirta Sukmajati' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120123' AS no_kk, 'Diah Ayu Lestari' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120127' AS no_kk, 'Mihran' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712120137' AS no_kk, 'Moh. Adi Ariansyah' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712130017' AS no_kk, 'Muhamad Sultan Gibran' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712140007' AS no_kk, 'Siti Hatia' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712140017' AS no_kk, 'Ridsal Putra Piman Pratama' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712140019' AS no_kk, 'Sahrul Hadi' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712140035' AS no_kk, 'Nuraini' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712150003' AS no_kk, 'Huan Sukma Prasetyo' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081712190002' AS no_kk, 'Rohani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081802130028' AS no_kk, 'Winarti' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081802130050' AS no_kk, 'Marnah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081803100021' AS no_kk, 'Ely Zuhaiva' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081803140010' AS no_kk, 'Supriadi' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804120011' AS no_kk, 'Hendri Saputra' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804120053' AS no_kk, 'Siti Maulina' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804150007' AS no_kk, 'Hevi Yuli Asri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804160009' AS no_kk, 'Moh. Meika Artha' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081804160011' AS no_kk, 'Lalu Marjan' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081805150032' AS no_kk, 'Rahmad Ilahi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806120011' AS no_kk, 'Nur Yolanda' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806120017' AS no_kk, 'Annisa Dwi Alifia' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806120027' AS no_kk, 'Juliyana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081806200009' AS no_kk, 'Eva Sunita Dewi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081807130019' AS no_kk, 'L. M. Dzaky Almeer' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081807180012' AS no_kk, 'Vincent Ang' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081808170006' AS no_kk, 'Alip Shakiel Syabani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081809120079' AS no_kk, 'Jawiyah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081809190013' AS no_kk, 'Hartini' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081809190015' AS no_kk, 'Zohira Amalia' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120006' AS no_kk, 'Amaq Haeni' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120008' AS no_kk, 'Amaq Sahuri' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120055' AS no_kk, 'Patini' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810120080' AS no_kk, 'Mawardi' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810130004' AS no_kk, 'Salbiah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811110007' AS no_kk, 'Robian Paradi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811130032' AS no_kk, 'M. Sulpan Bahtiar' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811140016' AS no_kk, 'Hafis Sebastian Purnama' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811190001' AS no_kk, 'Gampita Purnama Sari' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081811190009' AS no_kk, 'Imok' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081812140028' AS no_kk, 'Nila' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081812150003' AS no_kk, 'Arumi Khalika Dzahin' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081901180003' AS no_kk, 'Yahya Saputra' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081901210002' AS no_kk, 'Afiatun Nuzulullaeli' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081901210007' AS no_kk, 'Mahli' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081902140011' AS no_kk, 'Ahmad Aprian' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081902190001' AS no_kk, 'Faris Maulana' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903120064' AS no_kk, 'Amaq Andi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903150007' AS no_kk, 'Hairudin' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081903190003' AS no_kk, 'Misbah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904120052' AS no_kk, 'Inaq Epi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904130011' AS no_kk, 'Nadia' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081904210014' AS no_kk, 'Siska Anggraeni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081907120017' AS no_kk, 'Najwa Sahira' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081907180004' AS no_kk, 'Nur Hasanah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081908100004' AS no_kk, 'Juan Andriano' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081908140008' AS no_kk, 'Muhammad Nabil Al Muzakir' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081908200006' AS no_kk, 'Satriadi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909140004' AS no_kk, 'Indah Yani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909140005' AS no_kk, 'Rauhun' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909140018' AS no_kk, 'Agil Almubin' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909170005' AS no_kk, 'Aguskan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081909190017' AS no_kk, 'Rida Hidayatulloh' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081910110049' AS no_kk, 'Ramdani Apriadi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081910170003' AS no_kk, 'Arshy Arika Putri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081911120020' AS no_kk, 'M. Randi Saputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081911150007' AS no_kk, 'Hamid Asy Syaqyramadan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912130003' AS no_kk, 'Abd Kasim' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912130012' AS no_kk, 'Sahnim' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912140006' AS no_kk, 'Siswadi' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912150009' AS no_kk, 'Ria Juniati' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912160005' AS no_kk, 'Syarifuddin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081912160006' AS no_kk, 'Kamaria' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082001140006' AS no_kk, 'Jihat' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082002130006' AS no_kk, 'Muhammad Sami Ul Rizki Bin Md. Mosher Rahoman' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082003150029' AS no_kk, 'Kamarudin' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082004120001' AS no_kk, 'Doni Rohadin Maulana' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082004180009' AS no_kk, 'Muhammad Jidan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120037' AS no_kk, 'Rahma Pratiwi Lestari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120046' AS no_kk, 'Inaq Sul' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006120053' AS no_kk, 'Harun Arrasit' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082006150004' AS no_kk, 'Aril' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100037' AS no_kk, 'Silfa Rindiani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100054' AS no_kk, 'M. Riski' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100069' AS no_kk, 'Alhilal Saputra' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007100074' AS no_kk, 'Anisa' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007150002' AS no_kk, 'Zahara Natul Jannah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082007160006' AS no_kk, 'Aska Anggara' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT 'Kepala Keluarga' AS no_kk, '"I Gede Indra Apriyana' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009120062' AS no_kk, 'Ali' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009120116' AS no_kk, 'Inaq Fit' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009120120' AS no_kk, 'Halimah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009120121' AS no_kk, 'Mantasiah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082009120150' AS no_kk, 'M. Rido Akbar' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082010110034' AS no_kk, 'Ade Rosadi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120008' AS no_kk, 'Lili Windari' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120036' AS no_kk, 'Ihsan' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120045' AS no_kk, 'Inaq Bedah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011120097' AS no_kk, 'Muhamat Reza Afandi' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011190002' AS no_kk, 'Cenorawati' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082011200009' AS no_kk, 'Rizky Fadilla' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082012120077' AS no_kk, 'Jamilah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082012120078' AS no_kk, 'Yulianti' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082012120079' AS no_kk, 'Dwi Agustini' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082012140020' AS no_kk, 'Sannang Tia' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082012140037' AS no_kk, 'Muslihin' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082101130027' AS no_kk, 'Sri Banun' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082101190001' AS no_kk, 'Siti Qona''Ah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082102120025' AS no_kk, 'Radiah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082102130010' AS no_kk, 'Fitriani' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082102130011' AS no_kk, 'Asan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082102130014' AS no_kk, 'Reza Aditya Prayoga Saputra' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082103110010' AS no_kk, 'M. Safari' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082103120016' AS no_kk, 'Yuliati' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082103170001' AS no_kk, 'Sintia Yasmin' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082103180011' AS no_kk, 'Alifya Nafisha' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082103190013' AS no_kk, 'Albar' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082104150007' AS no_kk, 'Selpina Seran' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082104160009' AS no_kk, 'Rendi Aditiya Pratama' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082104200016' AS no_kk, 'Mufia Variza Azzahrah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082105120058' AS no_kk, 'Bukri' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106100009' AS no_kk, 'Pang Japar' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120001' AS no_kk, 'Rehan' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120012' AS no_kk, 'Herman Jayadi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120014' AS no_kk, 'Ezlin Ramadani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120018' AS no_kk, 'M. Arif Husen' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082106120035' AS no_kk, 'Amaq Rihin' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082107100003' AS no_kk, 'Aisyah Aqila Alpiah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082107100026' AS no_kk, 'Yuliana Astuti' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082108130005' AS no_kk, 'Baim' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082109160006' AS no_kk, 'Rifky Zulityas' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082110120013' AS no_kk, 'Fatima Halwa' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082110120028' AS no_kk, 'Muhammad Ilham' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082110190005' AS no_kk, 'Sahtum' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111120003' AS no_kk, 'Alif Al Fatan' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111120056' AS no_kk, 'Lalu Nursandi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082111190007' AS no_kk, 'Anci Septidianus' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082112120012' AS no_kk, 'Sahiri' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082112120014' AS no_kk, 'Zunaidi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082201150012' AS no_kk, 'Azry Nulhadi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202120063' AS no_kk, 'Fahrurrozi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082202180012' AS no_kk, 'Faqih Syakib Firmansyah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081606720002' AS no_kk, 'Masyhur' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082203120032' AS no_kk, 'Caco' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082203120033' AS no_kk, 'Ramdani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082203120036' AS no_kk, 'Muhammad Syafiq Riza Isrofill' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082203160005' AS no_kk, 'Mohammad Azzam Khalif Saputra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082204150004' AS no_kk, 'Marwan' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120025' AS no_kk, 'Sanuding' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120032' AS no_kk, 'Abd. Samil' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205120060' AS no_kk, 'Usniati' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082205170012' AS no_kk, 'Samsul Hadi' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082206180007' AS no_kk, 'Nisa Safitri' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082207150005' AS no_kk, 'Agung Prastiwi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209120055' AS no_kk, 'Rodi Hartono' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209120097' AS no_kk, 'Suherni' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082209120123' AS no_kk, 'Annisa' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082210120021' AS no_kk, 'Seni Wati' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082210120055' AS no_kk, 'Aulia Darrusiva' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082210140019' AS no_kk, 'Mahyudin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082211130004' AS no_kk, 'Budi Purnawirawan' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082211130011' AS no_kk, 'Jaenudin' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082211160004' AS no_kk, 'Mustiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082212140021' AS no_kk, 'Anafa Zitmi Ilmi' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082212140022' AS no_kk, 'Uzol' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082212140025' AS no_kk, 'Inaq Sul' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082301140003' AS no_kk, 'Erwin Sahabudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082301140014' AS no_kk, 'Ahmadi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082301150005' AS no_kk, 'Amaq Hanun' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082301190002' AS no_kk, 'Suryati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082301200009' AS no_kk, 'Inaq Marno' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082302120036' AS no_kk, 'Nikmatul Maola' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082302160002' AS no_kk, 'Iqro'' Maulana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082302180004' AS no_kk, 'Muhammad Juan Winata' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304120039' AS no_kk, 'Senah' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304200012' AS no_kk, 'Fergian Sumantri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082304200015' AS no_kk, 'Muslim Mustofa' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120009' AS no_kk, 'Parijah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305120057' AS no_kk, 'Putri Malu' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305150017' AS no_kk, 'M. Al - Kahidir' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082305160006' AS no_kk, 'Eli Mania Handayani' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082307100011' AS no_kk, 'Muhamad Ridwan' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082307130002' AS no_kk, 'Selvi Rosiyada Yanti' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082307140007' AS no_kk, 'Alwi Rizahar Ramadana' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082307180009' AS no_kk, 'Muslimatul Oktavia Ra' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082308120035' AS no_kk, 'Mafila Apriana' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082308130006' AS no_kk, 'Jihan Raudatul Rahman' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082308160013' AS no_kk, 'Raisa Saluh' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082308170004' AS no_kk, 'Putri Anjani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310120080' AS no_kk, 'Riadtul Fardani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310120178' AS no_kk, 'Rahman Dika' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310130030' AS no_kk, 'Runiah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310130033' AS no_kk, 'Sulhim' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310130036' AS no_kk, 'Sopian' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082310180003' AS no_kk, 'Mahru' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082311120015' AS no_kk, 'Nurcahaya' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082311160004' AS no_kk, 'Amenah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312110052' AS no_kk, 'Panji Qodri Wijaya' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312130021' AS no_kk, 'Supardi' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082312140020' AS no_kk, 'Sumarni' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082401120024' AS no_kk, 'Dirga Aimar Hadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082401150006' AS no_kk, 'Inun' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082401190001' AS no_kk, 'M. Taufiq' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402120013' AS no_kk, 'Khairul Nizam' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402120023' AS no_kk, 'Moh. Ali' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402140012' AS no_kk, 'Fibriani' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402160015' AS no_kk, 'Rahman' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082402200003' AS no_kk, 'Samsul Hadi' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130005' AS no_kk, 'Amaq Nahlim' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130007' AS no_kk, 'Bapak Aton' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130009' AS no_kk, 'Ramli' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130017' AS no_kk, 'Inaq Sihram' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130019' AS no_kk, 'Inaq Amenah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404130021' AS no_kk, 'Tuti Alawiyah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082404150027' AS no_kk, 'Jumadi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406100019' AS no_kk, 'Iwan Sufianto' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406130010' AS no_kk, 'Mikailla Alifa Zahra' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406150030' AS no_kk, 'Satriana' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082406200002' AS no_kk, 'Dayu Ratnayanti' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082407120041' AS no_kk, 'Inaq Epul' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082407120163' AS no_kk, 'Rio Saputra' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082408100005' AS no_kk, 'Titik Eka' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082408120037' AS no_kk, 'Hakiki' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410110006' AS no_kk, 'Muhammad Ismul Azham' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410110091' AS no_kk, 'Istiqomah Putri Anas' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410120085' AS no_kk, 'Cici Hidayati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410120143' AS no_kk, 'Lira Junita' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410120144' AS no_kk, 'Inaq Salbiah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082410140010' AS no_kk, 'Susianti' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082411200007' AS no_kk, 'Krisnawati' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412110028' AS no_kk, 'Rifha Syakila Maulida' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412110069' AS no_kk, 'Eva Risky Oktaviani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412130007' AS no_kk, 'Muna Aulia' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412130009' AS no_kk, 'Heti Ariyanti' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082412140011' AS no_kk, 'Febriandika Pratama' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501100011' AS no_kk, 'Inaq Modeng' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501120028' AS no_kk, 'Haerul Anwar' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501120034' AS no_kk, 'Marlina' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501120102' AS no_kk, 'Yulianti' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501130002' AS no_kk, 'Rodianto' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501190002' AS no_kk, 'Ayu Septiarini Ahlia' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082502140015' AS no_kk, 'Dedi Mawardi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082503130007' AS no_kk, 'Daeng Sugi Purwanto' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082503130018' AS no_kk, 'Muhamad Lukman Ashan' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082503130024' AS no_kk, 'Syarif Hidayatulloh' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082503190007' AS no_kk, 'Ali Ramdani' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082504130016' AS no_kk, 'Miranti' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082505160005' AS no_kk, 'Firzi Khaeral Bayani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507120005' AS no_kk, 'Mila Bijana Sari' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082507170015' AS no_kk, 'Idayati' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510120045' AS no_kk, 'Fahmi Sidik' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082510180009' AS no_kk, 'Fitrianti' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511130013' AS no_kk, 'Antik' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511130015' AS no_kk, 'Sukar' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511130023' AS no_kk, 'Rima Astiani' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082511200007' AS no_kk, 'Mh. Nazam Kurniyawan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082601160011' AS no_kk, 'Adeeva Nisa Firmansyah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602130009' AS no_kk, 'Nurul Wahida' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602180011' AS no_kk, 'Mariom' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602180012' AS no_kk, 'Epita Zahirin' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602200009' AS no_kk, 'Zahra Titania Ermil' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603120018' AS no_kk, 'Heru Harianto' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603120042' AS no_kk, 'Amaq Suku' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603120061' AS no_kk, 'Amaq Irpan' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603150005' AS no_kk, 'Irli' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603150006' AS no_kk, 'Rudi' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082603150008' AS no_kk, 'Muhammad Arya Ammar' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082604130016' AS no_kk, 'Baiq Suci Harianto' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082604180003' AS no_kk, 'Nursamat' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605100011' AS no_kk, 'Ammar Faiz Abdillah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605100022' AS no_kk, 'M. Ali Ramdani' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605150036' AS no_kk, 'Yani Tri Ramadhani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605150039' AS no_kk, 'Hernawati' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082605150040' AS no_kk, 'Inaq Mahyudin' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606120018' AS no_kk, 'Munirul Arifin' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606120047' AS no_kk, 'Arsin Al Ghifari' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606120048' AS no_kk, 'Yusuf Wijaya' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606120090' AS no_kk, 'Muhammad Raffi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082606180009' AS no_kk, 'Suhaeba' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607100056' AS no_kk, 'Masni' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607120017' AS no_kk, 'Muhammad Ilham Hatta Al Fatir' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082607180008' AS no_kk, 'Alvin Opandio Maulana' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120028' AS no_kk, 'Rizal Ardiyansah' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120139' AS no_kk, 'Baiq Lasmining Puri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609120147' AS no_kk, 'Mukmin' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082609180003' AS no_kk, 'Jauza'' Hilya Nuha' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610110052' AS no_kk, 'Abdurrahman' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610110053' AS no_kk, 'Junaedi' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610110087' AS no_kk, 'Sakmah' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610150004' AS no_kk, 'Shakila Shidqi Wahyudi' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610150009' AS no_kk, 'Samsul Bahri' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082610200004' AS no_kk, 'M. Salihun' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611120044' AS no_kk, 'Daffa Ibnu Hafiz' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611150003' AS no_kk, 'Khaerul Azmi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611150015' AS no_kk, 'Lifaldi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611190007' AS no_kk, 'Mida Sandrina Putri' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611190008' AS no_kk, 'Sisila Wati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082611200011' AS no_kk, 'Indah Sari' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082612110021' AS no_kk, 'Mili Pratiwi' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082612110022' AS no_kk, 'Syafa Al Fida' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082612120006' AS no_kk, 'Fitria Sifa''Ul Husna' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082701120083' AS no_kk, 'Atika Putri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082701120086' AS no_kk, 'Riski Wulandari' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082701120101' AS no_kk, 'Pakih Ramdani' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082702190015' AS no_kk, 'Herawati' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703120041' AS no_kk, 'Ida Juniarti' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703150006' AS no_kk, 'Hendra Wibowo' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082703170002' AS no_kk, 'Marwa Syaqila Azzahra' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082704150001' AS no_kk, 'Ramli Pangaribuan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082704210008' AS no_kk, 'M. Alfin' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082705190004' AS no_kk, 'Andi Bariq Maulana' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706120012' AS no_kk, 'Zilfi Andriyani' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706120038' AS no_kk, 'Masiah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706120043' AS no_kk, 'Wa'' Maini' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706160004' AS no_kk, 'Muslimin' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706180004' AS no_kk, 'Hasia' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706180006' AS no_kk, 'Fitriah' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082708120072' AS no_kk, 'Aura Aulia Ramadani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082708140001' AS no_kk, 'Jihad Akbar' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082709140014' AS no_kk, 'Ayaz Fahlefi Ahmad' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082710140003' AS no_kk, 'Heri Budi Hartono' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082710140031' AS no_kk, 'Mahnim' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082710150003' AS no_kk, 'Eka Irawan' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082710170006' AS no_kk, 'Al Amrul Ikhsan' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082711120003' AS no_kk, 'Usnul Aeni' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082711120018' AS no_kk, 'Baiq Aoliana' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082711120021' AS no_kk, 'Nuri Suryanti' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082711140013' AS no_kk, 'Nurany Atqia Riski' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082711140015' AS no_kk, 'Mariam Wulandari' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712110075' AS no_kk, 'Hecha Miyana Wulandari Putri' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712110099' AS no_kk, 'Haerul Sakban' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712110110' AS no_kk, 'Baiq Susanti Maelani' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712120012' AS no_kk, 'Supiana' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712120050' AS no_kk, 'Isma Agustina' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082712130018' AS no_kk, 'Solatiah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082801150019' AS no_kk, 'Banyu Biru Afsindir' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082801210012' AS no_kk, 'Muhammad Imam Al Mazid' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802130015' AS no_kk, 'Joni' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082802150010' AS no_kk, 'M. Rizky Aditia' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803120040' AS no_kk, 'Milda' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130006' AS no_kk, 'Rizal Kurniawan' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803130021' AS no_kk, 'Jalaludin Jaen' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803150006' AS no_kk, 'Inaq Muludiah' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082803180013' AS no_kk, 'Uswatun Hasanah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082804160006' AS no_kk, 'Nuraedang' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082804160007' AS no_kk, 'Elfan Juniarta Saputra' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082804160008' AS no_kk, 'Surhapipi' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082804210013' AS no_kk, 'Suhardi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082804210023' AS no_kk, 'Siska Mirniawati' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082805150001' AS no_kk, 'Inak Haenik' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082805160003' AS no_kk, 'Afghan El-Harbie Baraja' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082806120052' AS no_kk, 'Aidil Azhari' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082806130004' AS no_kk, 'Herudanu Warta' AS kepala_nama, 'Sasak RT 006' AS alamat, 'Sasak' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082807150010' AS no_kk, 'Naela Octavia Haerani' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082807200012' AS no_kk, 'Sulistiawati' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082808150006' AS no_kk, 'Teduh Assyuro' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082808190007' AS no_kk, 'Faoziah' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082809180013' AS no_kk, 'Evi Asrianti' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082810130036' AS no_kk, 'Samsul Bahri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082810130042' AS no_kk, 'Rohani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082810130043' AS no_kk, 'Suryani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082810130045' AS no_kk, 'Husain' AS kepala_nama, 'Dames RT 002' AS alamat, 'Dames' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811140005' AS no_kk, 'Ciok' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811180006' AS no_kk, 'Siti Asmahyati' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082811190001' AS no_kk, 'Haerunnas' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812110130' AS no_kk, 'Harmoko' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812110153' AS no_kk, 'Abidzar Muhammad Zibril' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812120013' AS no_kk, 'Tirta Ardiansah' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082812120019' AS no_kk, 'Yanti Hartini' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082901140002' AS no_kk, 'Muniah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082901140003' AS no_kk, 'Muhamat Pirman Maolana' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082903120014' AS no_kk, 'Lalu Mansyur' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082904140001' AS no_kk, 'Muhammad Iqkroq Ierwandi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082904140004' AS no_kk, 'M.Hafiz Maulana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082904190004' AS no_kk, 'Beckham Dwi Rangga' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082904200005' AS no_kk, 'Erwin Afandi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082905120070' AS no_kk, 'Sahrul Hidayat' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082905150020' AS no_kk, 'Rian Novandhi' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082906120001' AS no_kk, 'Komala Sari' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082906150005' AS no_kk, 'Malik Ghufran Wibowo' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082906180003' AS no_kk, 'Inaq Sahuri' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907100061' AS no_kk, 'Widia Safitri' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082907160005' AS no_kk, 'Randy Kurniawan Saputra' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082908120083' AS no_kk, 'Rusmiati' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082908120104' AS no_kk, 'Aniska' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082908140001' AS no_kk, 'Ll. Muhammad Azzan Akbar' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909120027' AS no_kk, 'Khumairoh Tyas Syifa' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082909120110' AS no_kk, 'Yami Yulianti' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120052' AS no_kk, 'Bq. Rohenah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120065' AS no_kk, 'Samsiah' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120072' AS no_kk, 'M. Azzam Athallah' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120076' AS no_kk, 'Adinda Juni Astuti' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120078' AS no_kk, 'Nadira Humaira' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120084' AS no_kk, 'Anggi Ilham Maulida' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120098' AS no_kk, 'Muhammad Azimi' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120131' AS no_kk, 'Subaedah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120141' AS no_kk, 'Zora Al Fazira' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910120145' AS no_kk, 'M. Faiz Arkan' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910140002' AS no_kk, 'Akmaliqi' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082910140017' AS no_kk, 'Sri Musdalifah' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911110018' AS no_kk, 'Nova Naela' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911110024' AS no_kk, 'Salifa Suuja Aslika' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120017' AS no_kk, 'Bimo Riawan' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120019' AS no_kk, 'Nurul Hidayah' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911120038' AS no_kk, 'Nursim' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082911160004' AS no_kk, 'Aliffa Meylani Wijaya' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082912110029' AS no_kk, 'Hariyadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082912140009' AS no_kk, 'Nafika Nabila Putri' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082912140052' AS no_kk, 'Sahriadi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083001120072' AS no_kk, 'Mustafa' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083001130006' AS no_kk, 'Marvin Hendriawan Saputra' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083001170001' AS no_kk, 'Muzakir Nizam Azim' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083001170002' AS no_kk, 'Inara Ayudia Putri' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083003160007' AS no_kk, 'Siti Aolia' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083004140009' AS no_kk, 'Sudirman' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083005120042' AS no_kk, 'Abdul Fatih Mubarok' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083005130019' AS no_kk, 'Amaq Munasib' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083006140016' AS no_kk, 'Dian Apriani' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083007120037' AS no_kk, 'Muhimma' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083007180002' AS no_kk, 'Baiq Faiha Okta Kamizuki' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009140010' AS no_kk, 'Andi Nuraini Safitri' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009140014' AS no_kk, 'Muh. Fauzi' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009140015' AS no_kk, 'Pina Aolia' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009140016' AS no_kk, 'Nuramin' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009140018' AS no_kk, 'Nursamat' AS kepala_nama, 'Dames RT 003' AS alamat, 'Dames' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083009150002' AS no_kk, 'Adelia Nisa Ardani' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120029' AS no_kk, 'Alvia Ramadani' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120038' AS no_kk, 'Haeri Juliadi' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120039' AS no_kk, 'Riko Hari Akbar' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120040' AS no_kk, 'Rahim' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120086' AS no_kk, 'Radiah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120088' AS no_kk, 'Inaq Janah' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120102' AS no_kk, 'Inaq Mustahik' AS kepala_nama, 'Brangtapen Asri RT 006' AS alamat, 'Brangtapen Asri' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120103' AS no_kk, 'Sunaah' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120104' AS no_kk, 'Issuhaemi' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120107' AS no_kk, 'Munipah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120111' AS no_kk, 'Maknah' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010120112' AS no_kk, 'Darmasih' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010130029' AS no_kk, 'Hamdi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010130030' AS no_kk, 'Hamzan' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083010130031' AS no_kk, 'Lukman' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011120056' AS no_kk, 'Imran Irawan' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083011200024' AS no_kk, 'Sultan Maulana' AS kepala_nama, 'Brangtapen Asri RT 002' AS alamat, 'Brangtapen Asri' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012140006' AS no_kk, 'Muliana' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012140010' AS no_kk, 'Sumiati' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012140011' AS no_kk, 'Murtini' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012140013' AS no_kk, 'Nurul Aini' AS kepala_nama, 'Sasak RT 005' AS alamat, 'Sasak' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083012190004' AS no_kk, 'Wirajaya' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083101120016' AS no_kk, 'Febrian Maolana' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083101120035' AS no_kk, 'Bariah' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083101120045' AS no_kk, 'M. Yusuf Khairul Ihsan' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083103100032' AS no_kk, 'Fayruz Salman Al Farizi' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083103200005' AS no_kk, 'Hariyono' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083103210007' AS no_kk, 'Petrus Pati Bukan' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120005' AS no_kk, 'Asiah' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120077' AS no_kk, 'Saula Widya Ahmad' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107120090' AS no_kk, 'Asmiludin' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083107130023' AS no_kk, 'Saenah' AS kepala_nama, 'Dames RT 001' AS alamat, 'Dames' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083108120052' AS no_kk, 'Nuriah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083108120054' AS no_kk, 'Hajrah Wati' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120033' AS no_kk, 'Pispita' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120042' AS no_kk, 'Inaq Mariah' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120048' AS no_kk, 'Halimah' AS kepala_nama, 'Mandar RT 005' AS alamat, 'Mandar' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120049' AS no_kk, 'Yunita Utami' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120054' AS no_kk, 'Akbar Hakim' AS kepala_nama, 'Sasak RT 003' AS alamat, 'Sasak' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120059' AS no_kk, 'Iqrar Akbar Pratama' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120066' AS no_kk, 'Inaq Hadirin' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120072' AS no_kk, 'Sahabudin' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120074' AS no_kk, 'Bq. Sabariah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120079' AS no_kk, 'Faozan' AS kepala_nama, 'Mandar RT 001' AS alamat, 'Mandar' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120080' AS no_kk, 'Herman' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120082' AS no_kk, 'Amrullah' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120083' AS no_kk, 'Hasrul Hamdi' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120088' AS no_kk, 'Nurminah' AS kepala_nama, 'Sasak RT 004' AS alamat, 'Sasak' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083110120091' AS no_kk, 'Winda Sari' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112140007' AS no_kk, 'Dendrik' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083112180003' AS no_kk, 'Rizki Fadila' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203091409200004' AS no_kk, 'Sarinah' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203162803110004' AS no_kk, 'Janatunnaim' AS kepala_nama, 'Brangtapen Asri RT 005' AS alamat, 'Brangtapen Asri' AS dusun, '005' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203170306200005' AS no_kk, 'Bq. Nila Nurma Yusliana' AS kepala_nama, 'Brangtapen Asri RT 004' AS alamat, 'Brangtapen Asri' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5204172010150008' AS no_kk, 'Hadia' AS kepala_nama, 'Sasak RT 002' AS alamat, 'Sasak' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5204172102180001' AS no_kk, 'Alif Wardana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5207020810190003' AS no_kk, 'Novita Sari' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5207032708103867' AS no_kk, 'Viqry Zulkarnaen Putra' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5207080910150005' AS no_kk, 'Nathan Pribadi Nugraha' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '6473021009140001' AS no_kk, 'Muhammad Akbar Maulana' AS kepala_nama, 'Mandar RT 002' AS alamat, 'Mandar' AS dusun, '002' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7301030912090002' AS no_kk, 'Patta Solong' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310011005070024' AS no_kk, 'Jumadi' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310011005070082' AS no_kk, 'Nur Hayati' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310011005070096' AS no_kk, 'Rosneli' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310011105070097' AS no_kk, 'Haikal' AS kepala_nama, 'Brangtapen Asri RT 003' AS alamat, 'Brangtapen Asri' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310011707070004' AS no_kk, 'Muhammad Hilal' AS kepala_nama, 'Mandar RT 004' AS alamat, 'Mandar' AS dusun, '004' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310011907070003' AS no_kk, 'Rahing' AS kepala_nama, 'Mandar RT 006' AS alamat, 'Mandar' AS dusun, '006' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310012604160001' AS no_kk, 'Gasani Aisa' AS kepala_nama, 'Mandar RT 003' AS alamat, 'Mandar' AS dusun, '003' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7310012805080010' AS no_kk, 'M. Azka' AS kepala_nama, 'Brangtapen Asri RT 001' AS alamat, 'Brangtapen Asri' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '7404110306200007' AS no_kk, 'Harniati' AS kepala_nama, 'Sasak RT 001' AS alamat, 'Sasak' AS dusun, '001' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080111120099' AS no_kk, 'ELMIYATI' AS kepala_nama, 'Seruni Barat RT 4.0' AS alamat, 'Seruni Barat' AS dusun, '4.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080510160002' AS no_kk, 'JOHRI FIRDAUS' AS kepala_nama, 'Seruni Barat RT 2.0' AS alamat, 'Seruni Barat' AS dusun, '2.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080610160008' AS no_kk, 'SUHARTI' AS kepala_nama, 'Seruni Barat RT 2.0' AS alamat, 'Seruni Barat' AS dusun, '2.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203080801200005' AS no_kk, 'HERLINA' AS kepala_nama, 'Seruni Barat RT 3.0' AS alamat, 'Seruni Barat' AS dusun, '3.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081012150003' AS no_kk, 'HARIATUL AENI' AS kepala_nama, 'Mumbul Utara RT 2.0' AS alamat, 'Mumbul Utara' AS dusun, '2.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081311140002' AS no_kk, 'SAHNUN' AS kepala_nama, 'Seruni Timur RT 3.0' AS alamat, 'Seruni Timur' AS dusun, '3.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081401210004' AS no_kk, 'FITRI HANDAYANI' AS kepala_nama, 'Seruni Barat RT 2.0' AS alamat, 'Seruni Barat' AS dusun, '2.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081408120048' AS no_kk, 'JAELANI' AS kepala_nama, 'Seruni Barat RT 1.0' AS alamat, 'Seruni Barat' AS dusun, '1.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081810130007' AS no_kk, 'PUSPA ASPIRANI PUTRI' AS kepala_nama, 'Seruni Timur RT 3.0' AS alamat, 'Seruni Timur' AS dusun, '3.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203081812180008' AS no_kk, 'EPA FEBRIANI' AS kepala_nama, 'Mumbul Utara RT 1.0' AS alamat, 'Mumbul Utara' AS dusun, '1.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082102130009' AS no_kk, 'MUHAMMAD ALPIN' AS kepala_nama, 'Seruni Barat RT 4.0' AS alamat, 'Seruni Barat' AS dusun, '4.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082112110047' AS no_kk, 'SUMARNI' AS kepala_nama, 'Seruni Barat RT 3.0' AS alamat, 'Seruni Barat' AS dusun, '3.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082311180007' AS no_kk, 'SULASTRI' AS kepala_nama, 'Seruni Barat RT 2.0' AS alamat, 'Seruni Barat' AS dusun, '2.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082501120056' AS no_kk, 'AISYAH FEBRINA' AS kepala_nama, 'Seruni Barat RT 3.0' AS alamat, 'Seruni Barat' AS dusun, '3.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082602180003' AS no_kk, 'ELI DIANASARI' AS kepala_nama, 'Mumbul Selatan RT 1.0' AS alamat, 'Mumbul Selatan' AS dusun, '1.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082702190003' AS no_kk, 'SEHA' AS kepala_nama, 'Mumbul Utara RT 1.0' AS alamat, 'Mumbul Utara' AS dusun, '1.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203082706180003' AS no_kk, 'JUMADIL' AS kepala_nama, 'Mumbul Selatan RT 5.0' AS alamat, 'Mumbul Selatan' AS dusun, '5.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083004180008' AS no_kk, 'PATIMAH' AS kepala_nama, 'Mumbul Selatan RT 1.0' AS alamat, 'Mumbul Selatan' AS dusun, '1.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  UNION ALL
  SELECT '5203083103150019' AS no_kk, 'RARANTI SARA' AS kepala_nama, 'Mumbul Utara RT 4.0' AS alamat, 'Mumbul Utara' AS dusun, '4.0' AS rt, NULL::text AS rw, NULL::text AS catatan
  ) AS t(no_kk, kepala_nama, alamat, dusun, rt, rw, catatan)
  ON CONFLICT (no_kk) DO NOTHING;
END $$;
