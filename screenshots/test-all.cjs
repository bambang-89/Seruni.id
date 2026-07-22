const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  const pages = [
    { name: '01-homepage', url: 'http://localhost:3000' },
    { name: '02-login', url: 'http://localhost:3000/login' },
    { name: '03-statistik', url: 'http://localhost:3000/statistik/penduduk' },
    { name: '04-layanan-surat', url: 'http://localhost:3000/layanan/surat' },
    { name: '05-partisipasi-voting', url: 'http://localhost:3000/partisipasi/voting' },
    { name: '06-profil-desa', url: 'http://localhost:3000/profil-desa' },
    { name: '07-status-idm', url: 'http://localhost:3000/status-idm' },
    { name: '08-layanan-pbb', url: 'http://localhost:3000/layanan/pbb' },
  ];

  console.log('Testing pages...\n');

  for (const p of pages) {
    try {
      await page.goto(p.url, { waitUntil: 'networkidle', timeout: 15000 });
      await page.waitForTimeout(1000);

      // Check for Chinese/Russian text
      const bodyText = await page.textContent('body');
      const hasChinese = /[一-鿿]/.test(bodyText);
      const hasRussian = /[Ѐ-ӿ]/.test(bodyText);

      const status = hasChinese ? 'CHINESE!' : hasRussian ? 'RUSSIAN!' : 'OK';

      console.log(status + ' ' + p.name + ': ' + p.url);

      // Take screenshot
      await page.screenshot({ path: 'screenshots/' + p.name + '.png', fullPage: false });

    } catch (err) {
      console.log('ERROR ' + p.name + ': ' + err.message);
    }
  }

  await browser.close();
  console.log('\nTesting complete!');
})();
