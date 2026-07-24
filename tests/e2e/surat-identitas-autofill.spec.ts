import { test, expect } from './fixtures';

/**
 * E2E tests for Surat Ajuan Identity Autofill feature.
 * Tests the NIK-based autofill flow: lookup trigger, badge, CTA, clear.
 */

test.describe('Surat Ajuan - Identity Autofill', () => {
  // Store the active listener so the sync afterEach can remove it.
  const activeListeners = new WeakMap<any, any>();

  test.afterEach(({ page }) => {
    const listener = activeListeners.get(page);
    if (listener) {
      page.off('console', listener);
      activeListeners.delete(page);
    }
  });

  /**
   * Navigate to a surat ajuan form.
   * The katalog page loads cards from Supabase and may show an error page
   * intermittently in dev. Retries up to 2 times on error.
   */
  async function openSuratForm(page: any, baseURL: string, retries = 2) {
    await page.goto(`${baseURL}/layanan/surat`);
    await page.waitForLoadState('networkidle');

    // Handle intermittent error page from Supabase/RLS in dev
    for (let attempt = 0; attempt <= retries; attempt++) {
      const errorBtn = page.getByRole('button', { name: /Muat Ulang Halaman/i });
      if (await errorBtn.isVisible().catch(() => false)) {
        if (attempt < retries) {
          await errorBtn.click();
          await page.waitForLoadState('networkidle');
          continue;
        }
      }

      // Wait for the "Ajukan Sekarang" link to appear in the surat katalog
      try {
        await page.getByRole('link', { name: /Ajukan Sekarang/i }).first().click({ timeout: 10000 });
        await page.waitForLoadState('networkidle');
        await page.waitForTimeout(3000);
        return;
      } catch {
        if (attempt < retries) {
          await page.reload();
          await page.waitForLoadState('networkidle');
          continue;
        }
        throw new Error('Could not navigate to surat form after retries');
      }
    }
  }

  test('form shows empty identity fields by default', async ({ page, baseURL }) => {
    const listener = (msg: any) => {
      if (msg.type() === 'error') {
        const t = msg.text();
        if (t.includes('Supabase') || t.includes('RLS') || t.includes('fetch')) { /* dev noise */ }
      }
    };
    page.on('console', listener);
    activeListeners.set(page, listener);

    await openSuratForm(page, baseURL!);

    // NIK field should be empty and editable
    const nikInput = page.getByPlaceholder('16 digit NIK');
    await expect(nikInput).toBeVisible({ timeout: 10000 });
    await expect(nikInput).toHaveValue('');

    // TTL field should be present (read-only, placeholder shown)
    const ttlField = page.locator('[data-testid="field-ttl"]');
    await expect(ttlField).toBeVisible({ timeout: 5000 });
    await expect(ttlField).toHaveAttribute('readonly', '');
  });

  test('typing non-16-digit NIK does not trigger lookup', async ({ page, baseURL }) => {
    const listener = (msg: any) => {
      if (msg.type() === 'error') {
        const t = msg.text();
        if (t.includes('Supabase') || t.includes('RLS') || t.includes('fetch')) { /* dev noise */ }
      }
    };
    page.on('console', listener);
    activeListeners.set(page, listener);

    await openSuratForm(page, baseURL!);

    const nikInput = page.getByPlaceholder('16 digit NIK');
    await expect(nikInput).toBeVisible({ timeout: 10000 });

    // Type partial NIK — no loading spinner should appear
    await nikInput.fill('12345');
    await page.waitForTimeout(800);

    // No spinning loader should be visible
    await expect(page.locator('[class*="animate-spin"]')).not.toBeVisible();
  });

  test('full 16-digit NIK triggers lookup (found or not found)', async ({ page, baseURL }) => {
    const listener = (msg: any) => {
      if (msg.type() === 'error') {
        const t = msg.text();
        if (t.includes('Supabase') || t.includes('RLS') || t.includes('fetch')) { /* dev noise */ }
      }
    };
    page.on('console', listener);
    activeListeners.set(page, listener);

    await openSuratForm(page, baseURL!);

    const nikInput = page.getByPlaceholder('16 digit NIK');
    await expect(nikInput).toBeVisible({ timeout: 10000 });

    // Fill a 16-digit NIK — real or fake, lookup should trigger
    await nikInput.fill('1234567890123456');

    // Wait for debounce (500ms) + network + render
    await page.waitForTimeout(2500);

    // Either the verified badge OR the "NIK tidak ditemukan" CTA must be visible.
    const badgeVisible = await page.locator('[data-testid="badge-verified"]').isVisible();
    const notFoundVisible = await page.locator('[data-testid="cta-not-found"]').isVisible();
    expect(badgeVisible || notFoundVisible).toBeTruthy();
  });

  test('clearing NIK resets verified badge and CTA', async ({ page, baseURL }) => {
    const listener = (msg: any) => {
      if (msg.type() === 'error') {
        const t = msg.text();
        if (t.includes('Supabase') || t.includes('RLS') || t.includes('fetch')) { /* dev noise */ }
      }
    };
    page.on('console', listener);
    activeListeners.set(page, listener);

    await openSuratForm(page, baseURL!);

    const nikInput = page.getByPlaceholder('16 digit NIK');
    await expect(nikInput).toBeVisible({ timeout: 10000 });

    // Type a NIK and wait for lookup
    await nikInput.fill('1234567890123456');
    await page.waitForTimeout(2500);

    // Clear NIK field
    await nikInput.clear();
    await page.waitForTimeout(500);

    // Both verified badge and "not found" CTA should be gone.
    await expect(page.locator('[data-testid="badge-verified"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="cta-not-found"]')).not.toBeVisible();
  });

  test('form submission: submit button visible and form is fillable', async ({ page, baseURL }) => {
    const listener = (msg: any) => {
      if (msg.type() === 'error') {
        const t = msg.text();
        if (t.includes('Supabase') || t.includes('RLS') || t.includes('fetch')) { /* dev noise */ }
      }
    };
    page.on('console', listener);
    activeListeners.set(page, listener);

    await openSuratForm(page, baseURL!);

    const nikInput = page.getByPlaceholder('16 digit NIK');
    await expect(nikInput).toBeVisible({ timeout: 10000 });

    // Try autofill with 16-digit NIK
    await nikInput.fill('1234567890123456');
    await page.waitForTimeout(2500);

    // If NIK was found (verified badge), fields are pre-filled.
    // If not found, manually fill required fields.
    const badgeVisible = await page.locator('[data-testid="badge-verified"]').isVisible();

    if (!badgeVisible) {
      // Fill nama manually (required)
      const namaInput = page.getByPlaceholder('Nama sesuai KTP');
      if (await namaInput.isVisible()) {
        await namaInput.fill('Test Warga');
      }
    }

    // Fill keperluan (required textarea)
    const keperluanArea = page.locator('textarea[placeholder*="Ceritakan"]');
    if (await keperluanArea.isVisible()) {
      await keperluanArea.fill('Surat keterangan domisili untuk keperluan administrasi kartu keluarga.');
    }

    // Verify submit button is present
    const submitBtn = page.getByRole('button', { name: /Kirim Pengajuan/i });
    await expect(submitBtn).toBeVisible();
  });
});
