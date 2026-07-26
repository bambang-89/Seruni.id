import { test as base, expect } from '@playwright/test';
import type { Page, Locator } from '@playwright/test';

// Extended test fixture with custom helpers
export class SeruniTestHelper {
  constructor(
    public readonly page: Page,
    public readonly baseURL: string
  ) {}

  // Navigate to a path
  async go(path: string): Promise<void> {
    await this.page.goto(`${this.baseURL}${path}`);
    await this.page.waitForLoadState('networkidle');
  }

  // Login as admin
  async loginAsAdmin(email: string, password: string): Promise<void> {
    await this.go('/admin/login');
    await this.page.fill('input[type="email"]', email);
    await this.page.fill('input[type="password"]', password);
    await this.page.click('button[type="submit"]');
    await this.page.waitForURL(/\/admin$/);
  }

  // Check page has no console errors
  async noConsoleErrors(): Promise<void> {
    const errors: string[] = [];
    this.page.on('console', (msg) => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });
    await this.page.reload();
    expect(errors.filter(e => !e.includes('favicon'))).toHaveLength(0);
  }

  // Wait for table to load
  async waitForTable(): Promise<Locator> {
    return this.page.locator('table, [role="table"], .table-container');
  }

  // Fill a form field by label
  async fillField(label: string, value: string): Promise<void> {
    await this.page.fill(`label:text("${label}") ~ input, label:text("${label}") ~ textarea, label:text-is("${label}") ~ input, [placeholder*="${label}"], input[name="${label.toLowerCase()}"]`, value);
  }

  // Click a button by text
  async clickButton(text: string): Promise<void> {
    await this.page.click(`button:has-text("${text}"), a:has-text("${text}")`);
  }

  // Check element visible
  async see(text: string): Promise<Locator> {
    return this.page.locator(`text=${text}`).first();
  }

  // Navigate admin sidebar
  async adminNav(menuText: string): Promise<void> {
    await this.page.click(`nav a:has-text("${menuText}"), aside a:has-text("${menuText}"), [class*="sidebar"] a:has-text("${menuText}")`);
    await this.page.waitForLoadState('networkidle');
  }
}

// Custom fixture
export const test = base.extend<{ helper: SeruniTestHelper }>({
  helper: async ({ page, baseURL }, use) => {
    const helper = new SeruniTestHelper(page, baseURL!);
    await use(helper);
  },
});

// Re-export everything from @playwright/test
export { expect, Page, Locator };
