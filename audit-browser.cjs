const { chromium } = require('playwright');

async function auditWebsite() {
  console.log('🚀 Starting browser audit...\n');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  const errors = [];
  const consoleMessages = [];

  // Capture console messages
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleMessages.push({ type: 'error', text: msg.text() });
    }
  });

  // Capture page errors
  page.on('pageerror', err => {
    errors.push(err.message);
  });

  // Capture failed requests
  const failedRequests = [];
  page.on('requestfailed', request => {
    failedRequests.push({
      url: request.url(),
      failure: request.failure()?.errorText
    });
  });

  try {
    console.log('📍 Opening: https://seruni-id-project.vercel.app\n');
    await page.goto('https://seruni-id-project.vercel.app', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    console.log('⏳ Waiting for page to stabilize...\n');
    await page.waitForTimeout(3000);

    // Get page title
    const title = await page.title();
    console.log('📄 Page Title:', title);

    // Check if page has content
    const bodyText = await page.locator('body').textContent();
    const hasContent = bodyText && bodyText.trim().length > 50;
    console.log('✅ Page has content:', hasContent);

    // Get network requests
    console.log('\n--- Failed Requests ---');
    if (failedRequests.length === 0) {
      console.log('✅ No failed requests');
    } else {
      failedRequests.forEach(req => {
        console.log(`❌ ${req.url}`);
        console.log(`   Error: ${req.failure}`);
      });
    }

    // Get console errors
    console.log('\n--- Console Errors ---');
    if (consoleMessages.length === 0) {
      console.log('✅ No console errors');
    } else {
      consoleMessages.forEach(msg => {
        console.log(`❌ ${msg.text}`);
      });
    }

    // Get page errors
    console.log('\n--- Page Errors ---');
    if (errors.length === 0) {
      console.log('✅ No page errors');
    } else {
      errors.forEach(err => {
        console.log(`❌ ${err}`);
      });
    }

    // Take screenshot
    console.log('\n📸 Taking screenshot...');
    await page.screenshot({ path: 'screenshot.png', fullPage: true });
    console.log('Screenshot saved: screenshot.png');

    // Get visible text sample
    console.log('\n--- Page Content Sample ---');
    const visibleText = await page.locator('body').textContent();
    console.log(visibleText?.substring(0, 500));

  } catch (err) {
    console.error('❌ Navigation error:', err.message);
  }

  await browser.close();
  console.log('\n✅ Audit complete');
}

auditWebsite();
