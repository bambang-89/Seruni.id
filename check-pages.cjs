const { chromium } = require("@playwright/test");

const ADMIN_PAGES = [
  { name: "Admin Dashboard", url: "/admin" },
  { name: "Admin Surat Ajuan", url: "/admin/surat-ajuan" },
  { name: "Admin Surat Terbit", url: "/admin/surat-terbit" },
  { name: "Admin Penduduk", url: "/admin/penduduk" },
  { name: "Admin Jenis Surat", url: "/admin/jenis-surat" },
  { name: "Admin Partisipasi", url: "/admin/partisipasi" },
  { name: "Admin Aduan", url: "/admin/aduan" },
];

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Login first
  await page.goto("http://localhost:8080/admin/login");
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
  console.log("Logged in, URL:", page.url());

  let passCount = 0;
  let failCount = 0;

  for (const p of ADMIN_PAGES) {
    const errors = [];

    const errHandler = (msg) => {
      const t = msg.text();
      // Ignore Supabase auth errors
      if (t.includes("401") || t.includes("403") || t.includes("Failed to load resource")) return;
      errors.push(t);
    };
    page.on("console", (msg) => { if (msg.type() === "error") errHandler(msg); });
    page.on("pageerror", (err) => errors.push(err.message));

    await page.goto(`http://localhost:8080${p.url}`);
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(3000);

    const body = await page.locator("body").innerText();
    const has404 = body.includes("404") && body.includes("Not Found");
    const hasAppError = body.includes("Application error") || body.includes("Something went wrong");
    const hasBlank = body.trim().length < 50;

    const title = await page.title();
    let status = "OK";
    if (has404 || hasAppError) { status = "FAIL"; failCount++; }
    else if (hasBlank) { status = "WARN (blank)"; failCount++; }
    else if (errors.length > 0) { status = `WARN (${errors.length} err)`; }
    else { passCount++; }

    console.log(`${status.padEnd(12)} ${p.name.padEnd(25)} ${title}`);

    page.removeAllListeners("console");
    page.removeAllListeners("pageerror");
  }

  await browser.close();
  console.log(`\n${passCount} OK, ${failCount} with issues`);
})();
