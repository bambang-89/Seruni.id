import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log("Navigating to /layanan/surat");
  await page.goto('http://localhost:8080/layanan/surat');
  
  console.log("Waiting for list...");
  await page.waitForSelector('text=Ajukan Sekarang');
  
  console.log("Clicking first 'Ajukan Sekarang'...");
  await page.click('text=Ajukan Sekarang');
  
  console.log("Waiting for form to load...");
  await page.waitForSelector('[data-testid="field-nik"]');
  
  console.log("Filling form...");
  await page.fill('[data-testid="field-nik"]', '5203083004880003');
  
  // Wait for name to be auto-filled if identitas exists
  await page.waitForTimeout(2000);
  
  console.log("Filling WhatsApp...");
  const waField = await page.$('[data-testid="field-whatsapp"]');
  if (waField) {
      const isReadonly = await waField.getAttribute('readonly');
      if (isReadonly === null) {
        await page.fill('[data-testid="field-whatsapp"]', '087763170088');
      }
  }

  // Fill any other text fields required
  const textareas = await page.$$('textarea');
  for (const textarea of textareas) {
      const isReadonly = await textarea.getAttribute('readonly');
      if (isReadonly === null) {
          await textarea.fill('Test input untuk keperluan surat');
      }
  }
  
  const textInputs = await page.$$('input[type="text"]:not([readonly])');
  for (const input of textInputs) {
      const id = await input.getAttribute('data-testid');
      if (id !== 'field-nik') {
          await input.fill('Test input');
      }
  }

  const numberInputs = await page.$$('input[type="number"]:not([readonly])');
  for (const input of numberInputs) {
      await input.fill('123');
  }

  const checkboxes = await page.$$('input[type="checkbox"]');
  for (const checkbox of checkboxes) {
      await checkbox.check();
  }

  const selects = await page.$$('select');
  for (const select of selects) {
      // select the second option (first is usually empty placeholder)
      const options = await select.$$('option');
      if (options.length > 1) {
          const value = await options[1].getAttribute('value');
          if (value) await select.selectOption(value);
      }
  }
  
  await page.screenshot({ path: 'surat_before_submit.png', fullPage: true });

  console.log("Clicking submit...");
  const submitButton = await page.$('button[type="submit"]');
  if (submitButton) {
    await submitButton.click();
    console.log("Submitted!");
  } else {
    console.log("Could not find submit button.");
  }
  
  await page.waitForTimeout(3000);
  
  console.log("Capturing screenshot of result...");
  await page.screenshot({ path: 'surat_result.png', fullPage: true });
  
  console.log("Done.");
  await browser.close();
})();
