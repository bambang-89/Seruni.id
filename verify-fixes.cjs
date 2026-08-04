const { chromium } = require("@playwright/test");
const fs = require("fs");
const path = require("path");

const OUT_DIR = path.join(__dirname, "audit-screenshots");

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  const BASE = "http://localhost:8080";
  // Login first
  await page.goto(`${BASE}/admin/login`);
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(2000);

  const nikInput = page.locator("input").first();
  const passInput = page.locator("input[type='password']").first();
  const submitBtn = page.locator("button[type='submit']").first();
  if (await nikInput.isVisible()) {
    await nikInput.fill("5203083004880003");
    await passInput.fill("Seruni88");
    await submitBtn.click();
    await page.waitForTimeout(3000);
  }
  console.log("Logged in:", page.url());

  const pages = [
    { name: "admin-site-fixed", url: "/admin/site" },
    { name: "admin-workflow-fixed", url: "/admin/workflow" },
    { name: "admin-partisipasi-fixed", url: "/admin/partisipasi" },
  ];

  for (const p of pages) {
    await page.goto(`${BASE}${p.url}`);
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(3000);

    await page.screenshot({ path: path.join(OUT_DIR, `${p.name}.png`), fullPage: false });

    const body = await page.locator("body").innerText();
    const blank = body.trim().length < 50;
    const has404 = body.includes("404") && body.includes("Not Found");
    const title = await page.title();
    console.log(`${blank || has404 ? "FAIL" : "OK"}   ${p.name} (${title}) - body length: ${body.trim().length}`);
  }

  await browser.close();
})();
