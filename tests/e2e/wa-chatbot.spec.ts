import { test, expect } from './fixtures';

/**
 * WA Chatbot E2E tests
 * Tests WA widget and subscription page
 */

test.describe('WA Chatbot', () => {
  test('homepage should render without WA widget crashing', async ({ page, baseURL }) => {
    await page.goto(baseURL!);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Check page loads without crash (WA widget is optional)
    await expect(page.locator('body')).toBeVisible();
  });

  test('langganan-wa page should load without crash', async ({ page, baseURL }) => {
    await page.goto(`${baseURL}/langganan-wa`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Check page loads
    await expect(page.locator('body')).toBeVisible();
  });
});
