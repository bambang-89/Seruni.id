import { test, expect } from './fixtures';

/**
 * API endpoint smoke tests
 * Tests that pages load correctly
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

test.describe('IDM Page', () => {
  test('status-idm page should load', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/status-idm`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    await expect(page.locator('body')).toBeVisible();
  });
});
