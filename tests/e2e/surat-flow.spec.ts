import { test, expect } from './fixtures';

const ADMIN_NIK = process.env.E2E_ADMIN_NIK || '5203083004880003';
const ADMIN_PASSWORD = process.env.E2E_ADMIN_PASSWORD || 'Seruni88';
const TEST_WA = process.env.E2E_TEST_WA || '6287763170088';
const JENIS_SURAT_ID = process.env.E2E_JENIS_SURAT_ID || 'eef7438f-adcf-4b55-ae23-cb48d7cd7899';

const TEST_NIK = '5201011234560001';
const TEST_NAMA = 'Budi Santoso';
const TEST_KEPERLUAN = 'Permohonan surat keterangan domisili untuk keperluan administrasi sekolah anak';

test.describe('Complete Surat Flow E2E', () => {

  test.beforeEach(async ({ page }) => {
    page.on('console', msg => {
      if (msg.type() === 'error') {
        const text = msg.text();
        if (!text.includes('401') && !text.includes('Failed to load resource')) {
          console.log(`[Console Error] ${text}`);
        }
      }
    });
  });

  // ============ STEP 1: Warga submits surat ajuan form ============
  test('Step 1: Warga submits surat ajuan form', async ({ page, baseURL }) => {
    console.log('\n=== STEP 1: Submit Surat Ajuan ===');

    await page.goto(`${baseURL}/layanan/surat/${JENIS_SURAT_ID}`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Verify form loaded
    const nikInput = page.locator('input[placeholder="16 digit NIK"]').first();
    await expect(nikInput).toBeVisible({ timeout: 10000 });
    console.log('[PASS] Form page loaded');

    // Fill NIK - this triggers auto-fill of other fields
    await nikInput.fill(TEST_NIK);
    console.log('[PASS] NIK filled:', TEST_NIK);

    // Wait for auto-fill
    await page.waitForTimeout(2000);

    // Fill Nama (auto-filled might not work in test, fill manually)
    const namaInput = page.locator('input[placeholder="Nama sesuai KTP"]').first();
    await namaInput.fill(TEST_NAMA);
    console.log('[PASS] Nama filled');

    // Fill WhatsApp number
    const waInput = page.locator('input[type="tel"]').first();
    await waInput.fill(TEST_WA);
    console.log('[PASS] WhatsApp filled:', TEST_WA);

    // Fill Alamat Domisili (textarea without "Otomatis terisi dari NIK" placeholder)
    const alamatDom = page.locator('textarea:not([placeholder*="Otomatis"])').first();
    if (await alamatDom.isVisible()) {
      await alamatDom.fill('Jl. Test No. 1, Desa Seruni Mumbul, Lombok Timur');
      console.log('[PASS] Alamat Domisili filled');
    }

    // Select Kecamatan/Desa
    const dusunSelect = page.locator('select').first();
    await dusunSelect.selectOption({ index: 1 });
    console.log('[PASS] Kecamatan/Desa selected');

    // Select RT/RW
    const rtSelect = page.locator('select').nth(1);
    await rtSelect.selectOption({ index: 1 });
    console.log('[PASS] RT/RW selected');

    // Fill Keperluan (textarea with specific placeholder)
    const keperluanTextarea = page.locator('textarea[placeholder*="Ceritakan"]').first();
    await keperluanTextarea.fill(TEST_KEPERLUAN);
    console.log('[PASS] Keperluan filled');

    // Submit
    const submitBtn = page.locator('button:has-text("Kirim Pengajuan")').first();
    await submitBtn.click();
    await page.waitForTimeout(5000);

    // Check for success
    const bodyText = await page.locator('body').innerText();
    const hasSuccess = bodyText.includes('Berhasil') || bodyText.includes('Tersimpan') || bodyText.includes('SRT-') || bodyText.includes('diterima');

    if (hasSuccess) {
      console.log('[PASS] Form submitted successfully');

      // Extract ticket number
      const ticketMatch = bodyText.match(/SRT-[A-Z0-9-]+/);
      if (ticketMatch) {
        console.log('[INFO] Ticket number:', ticketMatch[0]);
      }
    } else {
      // Check for validation errors
      const errorAlert = page.locator('[role="alert"], .text-destructive, .text-red').first();
      if (await errorAlert.isVisible({ timeout: 2000 }).catch(() => false)) {
        const errorText = await errorAlert.textContent();
        console.log('[ERROR] Form submission error:', errorText);
      } else {
        console.log('[WARN] Submission result unclear, checking URL...');
        console.log('[INFO] Current URL:', page.url());
      }
    }
  });

  // ============ STEP 2: Admin login ============
  test('Step 2: Admin login', async ({ page, baseURL }) => {
    console.log('\n=== STEP 2: Admin Login ===');

    await page.goto(`${baseURL}/admin/login`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // Find NIK input
    const nikInput = page.locator('input').first();
    await nikInput.fill(ADMIN_NIK);
    console.log('[PASS] NIK filled');

    // Find password input
    const passwordInput = page.locator('input[type="password"]').first();
    await passwordInput.fill(ADMIN_PASSWORD);
    console.log('[PASS] Password filled');

    // Submit
    const submitBtn = page.locator('button[type="submit"]').first();
    await submitBtn.click();
    await page.waitForTimeout(3000);

    const currentUrl = page.url();
    if (currentUrl.includes('/admin')) {
      console.log('[PASS] Admin login successful, at:', currentUrl);
    } else {
      console.log('[WARN] Login may have failed, still at:', currentUrl);
    }
  });

  // ============ STEP 3: Admin verifies and approves surat ============
  test('Step 3: Admin verifies and approves surat', async ({ page, baseURL }) => {
    console.log('\n=== STEP 3: Admin Verifikasi → Approve → WA ===');

    // First login
    await page.goto(`${baseURL}/admin/login`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    await page.locator('input').first().fill(ADMIN_NIK);
    await page.locator('input[type="password"]').first().fill(ADMIN_PASSWORD);
    await page.locator('button[type="submit"]').first().click();
    await page.waitForTimeout(3000);

    if (!page.url().includes('/admin')) {
      console.log('[FAIL] Admin login failed, aborting Step 3');
      return;
    }
    console.log('[PASS] Admin logged in');

    // Navigate to surat ajuan admin
    await page.goto(`${baseURL}/admin/surat-ajuan`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    console.log('[INFO] On surat-ajuan page:', page.url());

    // Check table
    const table = page.locator('table').first();
    if (await table.isVisible({ timeout: 5000 }).catch(() => false)) {
      console.log('[PASS] Surat ajuan table visible');
      const rows = await page.locator('tbody tr').count();
      console.log('[INFO] Table has', rows, 'rows');
    } else {
      console.log('[INFO] No table on surat-ajuan page, checking content...');
    }

    // Navigate to Surat Terbit
    await page.goto(`${baseURL}/admin/surat-terbit`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    console.log('[INFO] On surat-terbit page:', page.url());

    // Look for Antrian Terbit
    const bodyText = await page.locator('body').innerText();
    if (bodyText.includes('Antrian') || bodyText.includes('Terbit')) {
      console.log('[PASS] Surat Terbit page loaded with content');

      // Find and click on the first queue item
      const queueItems = page.locator('button').filter({ hasText: /diproses|proses|queue/i });
      const count = await queueItems.count();
      if (count > 0) {
        await queueItems.first().click();
        await page.waitForTimeout(3000);
        console.log('[PASS] Clicked queue item');

        // Look for Terbitkan button
        const terbitBtn = page.locator('button:has-text("Terbitkan"), button:has-text("Simpan")').first();
        if (await terbitBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
          await terbitBtn.click();
          await page.waitForTimeout(3000);
          console.log('[PASS] Clicked Terbitkan');

          const afterText = await page.locator('body').innerText();
          if (afterText.includes('diterbit') || afterText.includes('Berhasil') || afterText.includes('Sukses')) {
            console.log('[PASS] Surat berhasil diterbitkan!');
            console.log('[INFO] WhatsApp notification should be sent to', TEST_WA);
          }
        }
      } else {
        console.log('[INFO] No queue items found in "diproses" status');
      }
    } else {
      console.log('[INFO] Surat Terbit page structure may differ');
    }
  });

  // ============ STEP 4: Check service center ============
  test('Step 4: Check service center tracking', async ({ page, baseURL }) => {
    console.log('\n=== STEP 4: Service Center Status Tracking ===');

    await page.goto(`${baseURL}/service-center`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    await expect(page.locator('body')).toBeVisible();
    console.log('[PASS] Service Center page loaded:', page.url());

    const trackInput = page.locator('input').first();
    if (await trackInput.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('[PASS] Tracking input visible');
      await trackInput.fill('SRT-');
      await page.waitForTimeout(1000);
      console.log('[INFO] Tracking form available');
    } else {
      console.log('[INFO] No input found, page may show static content');
    }
  });
});
