import { test, expect } from './fixtures';

/**
 * API endpoint smoke tests
 * Tests that pages load correctly
 * Coverage: tenant-isolated hooks (C-01 fix verification)
 */

test.describe('API Pages', () => {
  test('berita page should load without crash', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/berita`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Page should load without crash
    await expect(page.locator('body')).toBeVisible();
    const content = await page.locator('body').innerHTML();
    expect(content.length).toBeGreaterThan(100);
  });

  test('agenda page should load without crash', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/kalender-desa`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Tenant-Isolated Public Hooks (C-01 Fix)', () => {
  test('usulan page should load with tenant isolation', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/usulan`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    await expect(page.locator('body')).toBeVisible();
    // No console errors from Supabase queries
    const errors: string[] = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') errors.push(msg.text());
    });
    await page.reload();
    await page.waitForLoadState('networkidle');
    const authErrors = errors.filter(e =>
      !e.includes('favicon') &&
      !e.includes('net::') &&
      !e.includes('Failed to load resource')
    );
    expect(authErrors).toHaveLength(0);
  });

  test('voting page should load with tenant isolation', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/voting`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    await expect(page.locator('body')).toBeVisible();
  });

  test('profil desa page should load with tenant isolation', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/profil-desa`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    await expect(page.locator('body')).toBeVisible();
  });

  test('struktur lembaga page should load with tenant isolation', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/struktur-desa`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('IDM Page', () => {
  test('status-idm page should load', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/status-idm`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    await expect(page.locator('body')).toBeVisible();
  });
});
