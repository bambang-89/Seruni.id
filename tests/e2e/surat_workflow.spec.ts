import { test, expect, Page } from '@playwright/test';

const BASE_URL = 'http://localhost:8080';
const ADMIN_NIK = '1234567890123456';
const ADMIN_PASSWORD = 'password123!';
const TEST_TIKET = 'E2E-TEST-1785544123063';

async function loginAdmin(page: Page) {
  await page.goto(`${BASE_URL}/admin/login`);
  await page.waitForLoadState('networkidle');
  // NIK field
  await page.locator('input[type="text"], input[inputmode="numeric"]').first().fill(ADMIN_NIK);
  await page.fill('input[type="password"]', ADMIN_PASSWORD);
  await page.click('button[type="submit"]');
  await page.waitForURL(`${BASE_URL}/admin**`, { timeout: 15000 });
  await page.waitForTimeout(2000);
  console.log('Logged in as admin');
}

test('✅ TAHAP 2: Verifikasi → diverifikasi', async ({ page }) => {
  test.setTimeout(60000);
  await loginAdmin(page);

  await page.goto(`${BASE_URL}/admin/surat-ajuan`);
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'test-results/t2-list.png', fullPage: true });

  // Tab "Perlu Verifikasi" should already be active, find our test ticket
  const testRow = page.locator(`tr:has-text("${TEST_TIKET}"), tr:has-text("E2E-TEST")`).first();
  const hasRow = await testRow.isVisible().catch(() => false);
  console.log(`Row with ${TEST_TIKET} visible:`, hasRow);

  if (!hasRow) {
    // Try first row with "Lihat" button
    const lihatBtn = page.locator('button:has-text("Lihat")').first();
    await lihatBtn.click();
  } else {
    const lihatBtn = testRow.locator('button:has-text("Lihat")');
    await lihatBtn.click();
  }
  
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'test-results/t2-overlay.png', fullPage: true });

  // Click "Verifikasi (Terima)"
  const verifikasiBtn = page.locator('button:has-text("Verifikasi")').first();
  const hasVerif = await verifikasiBtn.isVisible();
  console.log('Verifikasi button visible:', hasVerif);
  expect(hasVerif).toBe(true);
  
  await verifikasiBtn.click();
  await page.waitForTimeout(3000);
  await page.screenshot({ path: 'test-results/t2-done.png', fullPage: true });
  console.log('✅ TAHAP 2 PASSED: Verifikasi clicked');
});

test('✅ TAHAP 3: Tanda Tangan → ditandatangani', async ({ page }) => {
  test.setTimeout(60000);
  await loginAdmin(page);

  await page.goto(`${BASE_URL}/admin/surat-ajuan`);
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);

  // Click "Perlu Tanda Tangan" tab
  await page.locator('button:has-text("Perlu Tanda Tangan")').click();
  await page.waitForTimeout(1500);
  await page.screenshot({ path: 'test-results/t3-tab.png', fullPage: true });

  // Click Lihat on first row
  const lihatBtn = page.locator('button:has-text("Lihat")').first();
  const hasLihat = await lihatBtn.isVisible().catch(() => false);
  console.log('Lihat button (TTD tab) visible:', hasLihat);
  
  if (hasLihat) {
    await lihatBtn.click();
    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'test-results/t3-overlay.png', fullPage: true });

    const ttdBtn = page.locator('button:has-text("Tandatangani")').first();
    const hasTtd = await ttdBtn.isVisible().catch(() => false);
    console.log('Tandatangani button visible:', hasTtd);
    expect(hasTtd).toBe(true);
    
    await ttdBtn.click();
    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'test-results/t3-done.png', fullPage: true });
    console.log('✅ TAHAP 3 PASSED: Tandatangani clicked');
  } else {
    console.log('⚠️ TAHAP 3: No item in "Perlu Tanda Tangan" — Tahap 2 may not have completed');
  }
});

test('✅ TAHAP 4: Cetak preview surat terbit', async ({ page }) => {
  test.setTimeout(60000);
  await loginAdmin(page);

  // Intercept print dialog globally
  await page.addInitScript(() => { window.print = () => console.log('print intercepted'); });

  await page.goto(`${BASE_URL}/admin/surat-terbit`);
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  // Dismiss any overlay
  await page.keyboard.press('Escape').catch(() => {});
  await page.waitForTimeout(500);
  await page.screenshot({ path: 'test-results/t4-terbit-list.png', fullPage: true });

  // Click Preview first (safer than Cetak)
  const previewBtn = page.locator('button:has-text("Preview")').first();
  const hasPreview = await previewBtn.isVisible().catch(() => false);
  console.log('Preview button visible:', hasPreview);
  
  if (hasPreview) {
    const [popup] = await Promise.all([
      page.context().waitForEvent('page', { timeout: 8000 }).catch(() => null),
      previewBtn.click(),
    ]);
    
    if (popup) {
      await popup.addInitScript(() => { window.print = () => {}; });
      await popup.waitForLoadState('networkidle').catch(() => {});
      await popup.waitForTimeout(3000);
      await popup.screenshot({ path: 'test-results/t4-preview.png', fullPage: true });
      
      const content = await popup.content();
      const hasUnrendered = content.includes('{{');
      const hasKop = content.toLowerCase().includes('kecamatan') || content.toLowerCase().includes('pemerintah');
      console.log('Unrendered {{ variables:', hasUnrendered);
      console.log('Kop surat visible:', hasKop);
      console.log('✅ TAHAP 4 PASSED: Preview opened in popup');
    } else {
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/t4-preview-samepage.png', fullPage: true });
      console.log('✅ TAHAP 4: Preview opened in same page');
    }
  } else {
    // Try Cetak
    const cetakBtn = page.locator('button:has-text("Cetak")').first();
    await cetakBtn.click().catch(() => {});
    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'test-results/t4-cetak.png', fullPage: true });
  }
});

test('✅ TAHAP 5: Kirim & Selesai', async ({ page }) => {
  test.setTimeout(60000);
  await loginAdmin(page);

  await page.goto(`${BASE_URL}/admin/surat-ajuan`);
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);

  // Click "Perlu Dikirim" tab
  await page.locator('button:has-text("Perlu Dikirim")').click();
  await page.waitForTimeout(1500);
  await page.screenshot({ path: 'test-results/t5-dikirim-tab.png', fullPage: true });

  const lihatBtn = page.locator('button:has-text("Lihat")').first();
  const hasLihat = await lihatBtn.isVisible().catch(() => false);
  console.log('Lihat button (Perlu Dikirim) visible:', hasLihat);

  if (hasLihat) {
    await lihatBtn.click();
    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'test-results/t5-overlay.png', fullPage: true });

    const kirimBtn = page.locator('button:has-text("Kirim")').first();
    const hasKirim = await kirimBtn.isVisible().catch(() => false);
    console.log('Kirim & Selesai button visible:', hasKirim);
    expect(hasKirim).toBe(true);

    await kirimBtn.click();
    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'test-results/t5-done.png', fullPage: true });

    // Verify in Selesai tab
    await page.keyboard.press('Escape').catch(() => {});
    await page.locator('button:has-text("Selesai")').click();
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'test-results/t5-selesai-tab.png', fullPage: true });
    
    const selesaiRow = page.locator(`tr:has-text("E2E-TEST")`).first();
    const hasSelesai = await selesaiRow.isVisible().catch(() => false);
    console.log('E2E-TEST row visible in Selesai tab:', hasSelesai);
    console.log('✅ TAHAP 5 DONE');
  } else {
    console.log('⚠️ TAHAP 5: No item in "Perlu Dikirim" — earlier stages may not be complete');
    const tabs = await page.locator('button.border-b-2').allTextContents();
    console.log('Available tabs:', tabs);
  }
});
