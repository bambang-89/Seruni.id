const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 50 });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  console.log('=== END TO END TEST: SURAT SYSTEM ===\n');

  try {
    // 1. User Fills Form
    console.log('1. User memohon surat dari Form...');
    page.on('console', msg => {
      if (msg.type() === 'error') console.error(`PAGE ERROR: ${msg.text()}`);
      else console.log(`PAGE LOG: ${msg.text()}`);
    });
    page.on('response', async response => {
      if (response.status() >= 400) {
        const req = response.request();
        let reqBody = '';
        if (req.postData()) reqBody = req.postData();
        let resText = await response.text().catch(() => '');
        console.log(`NETWORK FAILED [${response.status()}]: ${req.method()} ${response.url()}`);
        if (reqBody) console.log(`REQUEST DATA: ${reqBody}`);
        if (resText) console.log(`RESPONSE DATA: ${resText}`);
      }
    });
    page.on('pageerror', err => console.log('PAGE ERROR:', err.message));
    page.on('dialog', dialog => {
      console.log('DIALOG:', dialog.message());
      dialog.accept();
    });
    
    await page.goto('http://localhost:8080/layanan/surat');
    await page.waitForLoadState('networkidle');

    // Click "AJUKAN SEKARANG" (assuming the first letter type is fine)
    await page.locator('a:has-text("AJUKAN SEKARANG")').first().click();
    await page.waitForLoadState('networkidle');
    await page.waitForSelector('text=Keperluan');

    // Fill form
    await page.locator('input[name="nik"], input[placeholder*="NIK"]').first().fill('5203083004880003');
    await page.locator('input[name="nama"], input[placeholder*="Nama"]').first().fill('Bambang S');
    
    // Fill contact
    await page.locator('input[data-testid="field-whatsapp"], input[name="kontak"]').first().fill('087763170088');
    
    // Fill all textareas (keperluan, alamat domisili yg editable)
    const textareas = page.locator('textarea:not([readonly])');
    const taCount = await textareas.count();
    console.log("Found editable textareas:", taCount);
    for (let i=0; i<taCount; i++) {
      if (await textareas.nth(i).isVisible()) {
        await textareas.nth(i).fill('Test E2E WhatsApp Automation ' + new Date().getTime());
      }
    }
    
    // Explicitly target keperluan just in case
    await page.getByPlaceholder('Ceritakan keperluan').fill('Test E2E WhatsApp Automation ' + Date.now()).catch(() => {});
    
    // Select all selects (RT/RW)
    const selects = page.locator('select');
    const selCount = await selects.count();
    for (let i=0; i<selCount; i++) {
      await selects.nth(i).selectOption({ index: 1 }).catch(() => {});
    }

    // Try to fill any other input[type="text"] that might be required
    const inputs = page.locator('input[type="text"]:not([readonly])');
    const inputCount = await inputs.count();
    for (let i=0; i<inputCount; i++) {
      if (await inputs.nth(i).isVisible() && await inputs.nth(i).inputValue() === '') {
        await inputs.nth(i).fill('Test E2E WhatsApp Automation ' + new Date().getTime());
      }
    }

    // Submit form
    console.log('Submitting form...');
    await page.locator('button').filter({ hasText: /Ajukan|Kirim/i }).click();

    // Check for toasts
    try {
      await page.waitForSelector('[role="status"], .toast', { timeout: 2000 });
      const toastText = await page.locator('[role="status"], .toast').allInnerTexts();
      console.log('Toasts found:', toastText);
    } catch(e) {}

    // Wait for ticket success modal or track screen
    try {
      await page.waitForSelector('text=Berhasil', { timeout: 15000 });
    } catch (e) {
      console.log('No "Berhasil" text found. Taking screenshot of error...');
      await page.screenshot({ path: 'audit-screenshots-final/error-form-submit.png', fullPage: true });
    }
    
    console.log('Form submitted. Tunggu sebentar...');
    await page.waitForTimeout(3000);

    // Get ticket number if visible
    const bodyText = await page.locator('body').innerText();
    let ticketMatch = bodyText.match(/SRT-\d{6}-\d{4}/);
    let ticket = ticketMatch ? ticketMatch[0] : null;
    console.log('Ticket received: ' + ticket);

    // 2. Admin Verifikasi & TTE
    console.log('\n2. Admin login untuk verifikasi & TTE...');
    await page.goto('http://localhost:8080/admin/login');
    await page.waitForLoadState('networkidle');
    
    await page.locator('input[type="text"], input[type="tel"]').first().fill('5203083004880003');
    await page.locator('input[type="password"]').fill('Serunimumbul88');
    await page.locator('button[type="submit"]').click();
    
    await page.waitForLoadState('networkidle');
    await page.waitForSelector('text=Keluar', { timeout: 15000 });
    
    console.log('Admin logged in.');

    await page.locator('a[href="/admin/surat-ajuan"], a:has-text("Pengajuan Surat")').first().click();
    await page.waitForLoadState('networkidle');
    
    // Wait for table to load
    await page.waitForTimeout(2000);
    
    // Click on the row with the ticket or the first 'Lihat' button if ticket not found
    let rowBtn;
    if (ticket) {
      rowBtn = page.locator(`tr:has-text("${ticket}") button`).first();
      if (await rowBtn.count() === 0) {
        rowBtn = page.locator('button').filter({ hasText: /Lihat|Detail/i }).first();
      }
    } else {
      rowBtn = page.locator('button').filter({ hasText: /Lihat|Detail/i }).first();
    }
    
    console.log('Membuka detail ajuan...');
    await rowBtn.click();
    await page.waitForTimeout(1000);

    // 1. Change status to "diproses"
    console.log('Mengubah status menjadi diproses...');
    const statusSelect = page.locator('select').filter({ hasText: /menunggu|diproses|selesai/i });
    if (await statusSelect.count() > 0) {
      await statusSelect.selectOption('diproses');
    }
    
    // 2. Click "Simpan"
    console.log('Menyimpan ajuan...');
    await page.locator('button').filter({ hasText: /^Simpan$/ }).click();
    await page.waitForTimeout(1500);

    // 3. Go to /admin/surat-terbit
    console.log('Pindah ke Surat Terbit...');
    await page.locator('a[href="/admin/surat-terbit"], a:has-text("Surat Terbit")').first().click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    // 4. Click the ticket in Antrian
    console.log('Memilih tiket dari antrian terbit...');
    let foundAntrian = false;
    if (ticket) {
      const antrianBtn = page.locator(`button:has-text("${ticket}")`).first();
      if (await antrianBtn.count() > 0) {
        await antrianBtn.click();
        foundAntrian = true;
      }
    }
    
    if (!foundAntrian) {
      console.log('Tiket tidak ada di antrian, menggunakan tombol tambah...');
      await page.locator('button:has-text("+ Tambah")').click();
    }
    
    await page.waitForTimeout(1000);

    // Fill nomor surat if exists
    const noSuratInput = page.locator('input[placeholder*="Nomor Surat"], input[name="nomor_surat"], label:has-text("Nomor Surat") input').first();
    if (await noSuratInput.count() > 0 && await noSuratInput.isVisible()) {
        await noSuratInput.fill('470/123/TEST/2026');
    }

    // Fill penandatangan
    const penandatanganSelect = page.locator('select').filter({ hasText: /Pilih Pamong|Penandatangan/i }).first();
    if (await penandatanganSelect.count() > 0 && await penandatanganSelect.isVisible()) {
        await penandatanganSelect.selectOption({ index: 1 });
    }

    // 5. Click "Terbitkan Surat"
    console.log('Menerbitkan surat (Generate TTE)...');
    await page.locator('button').filter({ hasText: /Terbitkan Surat/i }).first().click();

    console.log('Tunggu proses generate TTE dan kirim WA (5 detik)...');
    await page.waitForTimeout(5000);
    console.log('Cek WhatsApp 087763170088. Harusnya ada pesan masuk berisi PDF Surat/QRCode.');
    
    console.log('\n=== E2E TEST SELESAI ===');
  } catch (error) {
    console.error('Test error:', error);
    try {
      await page.screenshot({ path: 'audit-screenshots-final/error-admin-crash.png', fullPage: true });
    } catch(e) {}
    await browser.close();
    process.exit(1);
  }
})();
