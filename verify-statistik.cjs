const { chromium } = require("@playwright/test");
const path = require("path");

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 800 });

  await page.goto("http://localhost:8080/statistik/penduduk");
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(4000);

  await page.screenshot({ path: path.join(__dirname, "audit-screenshots", "statistik-fixed.png"), fullPage: false });

  const body = await page.locator("body").innerText();
  const hasZeros = body.includes("0 Total Jiwa");
  console.log(`Body length: ${body.length}`);
  console.log(`Shows "0 Total Jiwa": ${hasZeros}`);
  // Extract key numbers
  const match = body.match(/(\d[\d,]*) Total Jiwa/);
  if (match) console.log(`Total Jiwa found: ${match[1]}`);
  const jtMatch = body.match(/(\d[\d,]*) Kepala Keluarga/);
  if (jtMatch) console.log(`KK found: ${jtMatch[1]}`);
  const lmMatch = body.match(/(\d[\d,]*) Laki-Laki/);
  if (lmMatch) console.log(`Laki-laki found: ${lmMatch[1]}`);

  await browser.close();
})();
