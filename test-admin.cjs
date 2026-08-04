const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 500 });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  page.on('console', msg => console.log('PAGE LOG:', msg.text()));
  page.on('pageerror', err => console.log('PAGE ERROR:', err.message));

  console.log('Logging in as Admin...');
  await page.goto('http://localhost:8080/admin/login');
  await page.waitForLoadState('networkidle');
  
  await page.fill('input[type="text"]', '5203083004880003');
  await page.fill('input[type="password"]', 'Serunimumbul88'); // Assuming admin123 is the password
  await page.click('button:has-text("Masuk")');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);

  console.log('Navigating to Surat Ajuan Admin...');
  await page.goto('http://localhost:8080/admin/surat-ajuan');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3000);

  console.log('Checking for Lihat buttons...');
  const buttons = page.locator('button').filter({ hasText: /Lihat|Detail/i });
  const count = await buttons.count();
  console.log(`Found ${count} "Lihat" buttons`);

  if (count > 0) {
    console.log('Clicking first Lihat button...');
    await buttons.first().click();
    await page.waitForTimeout(2000);
    
    // Check if modal opened
    console.log('Modal opened?');
    const terbitkanBtn = page.locator('button').filter({ hasText: /Terbitkan Surat/i });
    console.log(`Found "Terbitkan Surat" buttons: ${await terbitkanBtn.count()}`);
  }

  await browser.close();
})();
