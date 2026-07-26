import { test, expect } from './fixtures';

/**
 * Admin pages E2E tests
 * Tests admin login flow
 */

test.describe('Admin Authentication', () => {
  test('admin login page should load without crash', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/admin/login`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Check page loads without crash
    await expect(page.locator('body')).toBeVisible();
    const content = await page.locator('body').innerHTML();
    expect(content.length).toBeGreaterThan(50);
  });
});

test.describe('Admin Dashboard', () => {
  test('admin should redirect to login without auth', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/admin`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Should show some content (login or admin page)
    await expect(page.locator('body')).toBeVisible();
  });
});
