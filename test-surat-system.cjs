const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  console.log('=== SURAT SYSTEM LIVE TEST ===\n');

  // 1. Browse letter types
  console.log('--- Test 1: Layanan Surat page ---');
  await page.goto('http://localhost:8080/layanan/surat');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=AJUKAN SEKARANG', { timeout: 15000 }).catch(() => {});
  const suratBody = await page.locator('body').innerText();
  const letterCount = (suratBody.match(/AJUKAN SEKARANG/g) || []).length;
  const hasSearch = suratBody.includes('Cari');
  console.log('Letter types found: ' + letterCount);
  console.log('Has search: ' + hasSearch);
  console.log('Has SK Domisili: ' + suratBody.includes('Domisili'));
  console.log('Has SK Usaha: ' + suratBody.includes('Usaha'));
  console.log('Status: ' + (letterCount > 50 ? 'PASS' : 'FAIL'));
  await page.screenshot({ path: 'audit-screenshots-final/surat-list.png', fullPage: false });

  // 2. Click on first AJUKAN button to go to form
  console.log('\n--- Test 2: Letter form page ---');
  const ajukanButtons = page.locator('a:has-text("AJUKAN SEKARANG")');
  const btnCount = await ajukanButtons.count();
  if (btnCount > 0) {
    await ajukanButtons.first().click();
    await page.waitForLoadState('networkidle');
    await page.waitForSelector('text=Keperluan', { timeout: 15000 }).catch(() => {});
    const formUrl = page.url();
    const formBody = await page.locator('body').innerText();
    const hasNama = formBody.includes('Nama') || formBody.includes('nama');
    const hasNIK = formBody.includes('NIK') || formBody.includes('nik');
    const hasKeperluan = formBody.includes('Keperluan') || formBody.includes('keperluan');
    const hasSubmit = formBody.includes('Ajukan') || formBody.includes('Kirim') || formBody.includes('KIRIM');
    console.log('Form URL: ' + formUrl);
    console.log('Has Nama field: ' + hasNama);
    console.log('Has NIK field: ' + hasNIK);
    console.log('Has Keperluan: ' + hasKeperluan);
    console.log('Has Submit: ' + hasSubmit);
    console.log('Status: ' + (hasNIK && hasSubmit ? 'PASS' : 'FAIL'));
    await page.screenshot({ path: 'audit-screenshots-final/surat-form.png', fullPage: false });
  } else {
    console.log('No AJUKAN buttons found - checking page content...');
    console.log(suratBody.substring(0, 500));
  }

  // 3. Service Center - Lacak Surat tab
  console.log('\n--- Test 3: Service Center - Lacak Surat tab ---');
  await page.goto('http://localhost:8080/service-center');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=Lacak Surat', { timeout: 15000 }).catch(() => {});
  const scBody = await page.locator('body').innerText();
  const hasLacakSurat = scBody.includes('Lacak Surat');
  console.log('Has Lacak Surat tab: ' + hasLacakSurat);

  // Click Lacak Surat tab
  const lacakTab = page.locator('button:has-text("Lacak Surat")');
  const tabCount = await lacakTab.count();
  console.log('Lacak Surat tab elements found: ' + tabCount);
  if (tabCount > 0) {
    await lacakTab.first().click();
    await page.waitForTimeout(2000);
    const lacakBody = await page.locator('body').innerText();
    const hasNomorTiket = lacakBody.includes('Nomor') || lacakBody.includes('Tiket') || lacakBody.includes('nomor') || lacakBody.includes('tiket');
    const inputCount = await page.locator('input').count();
    console.log('Has nomor tiket input: ' + (inputCount > 0));
    console.log('Status: ' + (inputCount > 0 && hasNomorTiket ? 'PASS' : 'FAIL'));
    await page.screenshot({ path: 'audit-screenshots-final/surat-lacak.png', fullPage: false });
  } else {
    // Maybe it's a link instead
    const lacakLink = page.locator('a:has-text("Lacak Surat")');
    if (await lacakLink.count() > 0) {
      console.log('Found as link, clicking...');
      await lacakLink.first().click();
      await page.waitForTimeout(2000);
      const lacakBody = await page.locator('body').innerText();
      const inputCount = await page.locator('input').count();
      console.log('Has input: ' + (inputCount > 0));
      await page.screenshot({ path: 'audit-screenshots-final/surat-lacak.png', fullPage: false });
    }
  }

  // 4. Track with real ticket
  console.log('\n--- Test 4: Track letter with ticket SRT-202607-0010 ---');
  await page.goto('http://localhost:8080/service-center');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=Lacak Surat', { timeout: 15000 }).catch(() => {});
  const lacakTab2 = page.locator('button:has-text("Lacak Surat")');
  if (await lacakTab2.count() > 0) {
    await lacakTab2.click();
    await page.waitForTimeout(2000);
  }

  // Find and fill the ticket input
  const inputs = page.locator('input[type="text"], input:not([type="hidden"])');
  const inputCount = await inputs.count();
  console.log('Input fields visible: ' + inputCount);

  if (inputCount > 0) {
    const firstInput = inputs.first();
    if (await firstInput.isVisible()) {
      await firstInput.fill('SRT-202607-0010');
      console.log('Filled ticket number');

      // Find submit button
      const submitBtn = page.locator('button').filter({ hasText: /Lacak|Cari|Telusuri/i });
      const submitCount = await submitBtn.count();
      console.log('Submit buttons found: ' + submitCount);

      if (submitCount > 0) {
        await submitBtn.first().click();
        await page.waitForTimeout(5000);
        const trackBody = await page.locator('body').innerText();
        const found = trackBody.includes('Ditemukan') || trackBody.includes('ditemukan') || trackBody.includes('SURAT KETERANGAN');
        const statusBadge = trackBody.includes('menunggu') || trackBody.includes('Diproses') || trackBody.includes('berlaku') || trackBody.includes('ditolak');
        const hasTicket = trackBody.includes('SRT-202607-0010');
        const hasNomorSurat = trackBody.includes('470/') || trackBody.includes('nomor') || trackBody.includes('Nomor Surat');
        console.log('Track - Found message: ' + found);
        console.log('Track - Has status badge: ' + statusBadge);
        console.log('Track - Has ticket SRT-202607-0010: ' + hasTicket);
        console.log('Track - Has nomor surat: ' + hasNomorSurat);
        console.log('Status: ' + (found || statusBadge || hasTicket ? 'PASS' : 'FAIL'));
        console.log('Track body tail:\n' + trackBody.slice(-400).trim());
        await page.screenshot({ path: 'audit-screenshots-final/surat-track-result.png', fullPage: false });
      } else {
        // Try pressing Enter
        await firstInput.press('Enter');
        await page.waitForTimeout(5000);
        const trackBody = await page.locator('body').innerText();
        const found = trackBody.includes('Ditemukan') || trackBody.includes('ditemukan');
        console.log('Track (Enter key) - Found: ' + found);
        console.log('Status: ' + (found ? 'PASS' : 'FAIL'));
        await page.screenshot({ path: 'audit-screenshots-final/surat-track-result.png', fullPage: false });
      }
    }
  } else {
    console.log('No input fields found on Lacak Surat tab');
    const allInputs = await page.locator('input').count();
    console.log('Total inputs on page: ' + allInputs);
  }

  // 5. Admin: Surat Ajuan
  console.log('\n--- Test 5: Admin - Surat Ajuan ---');
  await page.goto('http://localhost:8080/admin/login');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  await page.locator('input').first().fill('5203083004880003');
  await page.locator('input[type="password"]').first().fill('Seruni88');
  await page.locator('button[type="submit"]').first().click();
  await page.waitForTimeout(3000);
  await page.goto('http://localhost:8080/admin/surat-ajuan');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=Tiket', { timeout: 15000 }).catch(() => {});
  const ajuanBody = await page.locator('body').innerText();
  const hasTable = ajuanBody.includes('Tiket') || ajuanBody.includes('No. Tiket');
  const hasRows = ajuanBody.includes('SRT-202607');
  const hasStatus = ajuanBody.includes('menunggu') || ajuanBody.includes('diproses');
  console.log('Admin Surat Ajuan - Has table: ' + hasTable);
  console.log('Admin Surat Ajuan - Has ticket rows: ' + hasRows);
  console.log('Admin Surat Ajuan - Has status: ' + hasStatus);
  console.log('Status: ' + (hasTable && hasRows ? 'PASS' : 'FAIL'));
  await page.screenshot({ path: 'audit-screenshots-final/surat-admin-ajuan.png', fullPage: false });

  // 6. Admin: Surat Terbit
  console.log('\n--- Test 6: Admin - Surat Terbit ---');
  await page.goto('http://localhost:8080/admin/surat-terbit');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=ANTRIAN', { timeout: 15000 }).catch(() => {});
  const terbitBody = await page.locator('body').innerText();
  const hasAntrian = terbitBody.includes('ANTRIAN') || terbitBody.includes('antrian');
  const hasNomorSurat = terbitBody.includes('470/') || terbitBody.includes('nomor_surat') || terbitBody.includes('Nomor Surat');
  const hasStatusBadge = terbitBody.includes('berlaku') || terbitBody.includes('ditolak');
  console.log('Admin Surat Terbit - Has antrian: ' + hasAntrian);
  console.log('Admin Surat Terbit - Has nomor surat: ' + hasNomorSurat);
  console.log('Admin Surat Terbit - Has status badge: ' + hasStatusBadge);
  console.log('Status: ' + ((hasAntrian || hasNomorSurat) ? 'PASS' : 'FAIL'));
  await page.screenshot({ path: 'audit-screenshots-final/surat-admin-terbit.png', fullPage: false });

  // 7. Admin: Jenis Surat
  console.log('\n--- Test 7: Admin - Jenis Surat ---');
  await page.goto('http://localhost:8080/admin/jenis-surat');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=Jenis Surat', { timeout: 15000 }).catch(() => {});
  const jenisBody = await page.locator('body').innerText();
  const hasJenisTable = jenisBody.includes('474.0') || jenisBody.includes('Surat Keterangan') || jenisBody.includes('Jenis Surat');
  const codeMatches = jenisBody.match(/\d{3}[.,]\d/g) || [];
  console.log('Admin Jenis Surat - Has letter types: ' + hasJenisTable);
  console.log('Admin Jenis Surat - Code count: ' + codeMatches.length);
  console.log('Status: ' + (codeMatches.length > 5 ? 'PASS' : 'FAIL'));
  await page.screenshot({ path: 'audit-screenshots-final/surat-admin-jenis.png', fullPage: false });

  // 8. Check Verifikasi page
  console.log('\n--- Test 8: Verifikasi Dokumen page ---');
  await page.goto('http://localhost:8080/verifikasi');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('text=Verifikasi', { timeout: 15000 }).catch(() => {});
  const verifBody = await page.locator('body').innerText();
  const hasVerif = verifBody.includes('Verifikasi') || verifBody.includes('verifikasi');
  const hasKode = verifBody.includes('Kode') || verifBody.includes('kode') || verifBody.includes('QR');
  console.log('Verifikasi page - Has verifikasi: ' + hasVerif);
  console.log('Verifikasi page - Has kode/qr: ' + hasKode);
  console.log('Status: ' + (hasVerif ? 'PASS' : 'FAIL'));
  await page.screenshot({ path: 'audit-screenshots-final/surat-verifikasi.png', fullPage: false });

  console.log('\n=== ALL SURAT SYSTEM TESTS COMPLETE ===');

  await browser.close();
})();
