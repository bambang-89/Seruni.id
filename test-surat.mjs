import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();

  page.on('console', msg => console.log('BROWSER:', msg.text()));

  try {
    console.log("Navigating to /layanan/surat");
    await page.goto('http://localhost:8080/layanan/surat');
    
    console.log("Waiting for list...");
    await page.waitForSelector('text=Ajukan Sekarang', { timeout: 10000 });
    
    console.log("Clicking first 'Ajukan Sekarang'...");
    const btn = await page.$('text=Ajukan Sekarang');
    await btn.click();
    
    console.log("Waiting for form to load...");
    await page.waitForSelector('form', { timeout: 10000 });
    
    console.log("Filling form with specific valid data...");
    
    await page.fill('[data-testid="field-nik"]', '5203083004880003');
    await page.waitForTimeout(1000); // Wait for NIK check to populate fields if any

    const inputs = await page.$$('input');
    for (const input of inputs) {
      const isEditable = await input.isEditable();
      if (!isEditable) continue;
      
      const type = await input.getAttribute('type');
      if (type === 'file' || type === 'radio' || type === 'checkbox') continue;
      
      const testId = await input.getAttribute('data-testid');
      if (testId === 'field-nik') continue;
      if (testId === 'field-whatsapp') {
        await input.fill('087763170088');
        continue;
      }
      
      await input.fill('1234567890'); // Default fill for numbers/text
    }

    const textareas = await page.$$('textarea');
    for (const ta of textareas) {
      const isEditable = await ta.isEditable();
      if (!isEditable) continue;
      await ta.fill('Test input untuk keperluan surat');
    }

    const selects = await page.$$('select');
    for (const select of selects) {
      const isEditable = await select.isEnabled();
      if (!isEditable) continue;
      const options = await select.$$eval('option', opts => opts.map(o => o.value).filter(v => v));
      if (options.length > 0) {
        await select.selectOption(options[0]);
      }
    }

    const submitButton = await page.$('button[type="submit"]');
    if (submitButton) {
      await submitButton.click();
      console.log("Submitted!");
    } else {
      console.log("Could not find submit button.");
    }

    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'surat_result_6.png' });
    const text = await page.evaluate(() => document.body.innerText);
    console.log("PAGE TEXT AFTER SUBMIT:", text.substring(0, 1000));
  } catch (err) {
    console.error("TEST SCRIPT ERROR:", err);
    await page.screenshot({ path: 'surat_result_error.png' });
  } finally {
    await browser.close();
  }
})();
