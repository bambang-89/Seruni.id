const { chromium } = require("@playwright/test");
const fs = require("fs");
const path = require("path");

const OUT_DIR = path.join(__dirname, "audit-screenshots");
if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

const PUBLIC_PAGES = [
  { name: "home", url: "/" },
  { name: "profil-desa", url: "/profil-desa" },
  { name: "struktur", url: "/struktur" },
  { name: "wilayah", url: "/wilayah" },
  { name: "lembaga", url: "/lembaga" },
  { name: "layanan", url: "/layanan" },
  { name: "layanan-surat", url: "/layanan/surat" },
  { name: "service-center", url: "/service-center" },
  { name: "berita", url: "/berita" },
  { name: "galeri", url: "/galeri" },
  { name: "pengumuman", url: "/pengumuman" },
  { name: "kalender", url: "/kalender" },
  { name: "statistik", url: "/statistik/penduduk" },
  { name: "pembangunan", url: "/pembangunan" },
  { name: "potensi", url: "/potensi" },
  { name: "keuangan", url: "/keuangan" },
  { name: "bansos", url: "/bansos" },
  { name: "pbb", url: "/layanan/pbb" },
  { name: "langganan-wa", url: "/langganan-wa" },
  { name: "peta", url: "/peta" },
];

const ADMIN_PAGES = [
  { name: "admin-login", url: "/admin/login" },
  { name: "admin-dashboard", url: "/admin" },
  { name: "admin-surat-ajuan", url: "/admin/surat-ajuan" },
  { name: "admin-surat-terbit", url: "/admin/surat-terbit" },
  { name: "admin-penduduk", url: "/admin/penduduk" },
  { name: "admin-jenis-surat", url: "/admin/jenis-surat" },
  { name: "admin-partisipasi", url: "/admin/partisipasi" },
  { name: "admin-aduan", url: "/admin/aduan" },
  { name: "admin-site", url: "/admin/site" },
  { name: "admin-workflow", url: "/admin/workflow" },
];

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  const results = [];

  // Login to admin first
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

  // Capture all public pages
  console.log("\n=== PUBLIC PAGES ===");
  for (const p of PUBLIC_PAGES) {
    const errs = [];
    page.on("pageerror", (e) => errs.push(e.message));

    await page.goto(`http://localhost:8080${p.url}`);
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(2000);

    await page.screenshot({ path: path.join(OUT_DIR, `${p.name}.png`), fullPage: false });

    const body = await page.locator("body").innerText();
    const blank = body.trim().length < 50;
    const has404 = body.includes("404") && body.includes("Not Found");
    const hasError = body.includes("Application error") || body.includes("Something went wrong");

    results.push({ ...p, blank, has404, hasError, errors: errs });
    console.log(`${blank || has404 || hasError ? "FAIL" : "OK"}   ${p.name}`);

    page.removeAllListeners("pageerror");
  }

  // Capture admin pages
  console.log("\n=== ADMIN PAGES ===");
  for (const p of ADMIN_PAGES) {
    const errs = [];
    page.on("pageerror", (e) => errs.push(e.message));

    await page.goto(`http://localhost:8080${p.url}`);
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(2000);

    await page.screenshot({ path: path.join(OUT_DIR, `${p.name}.png`), fullPage: false });

    const body = await page.locator("body").innerText();
    const blank = body.trim().length < 50;
    const has404 = body.includes("404") && body.includes("Not Found");
    const hasError = body.includes("Application error") || body.includes("Something went wrong");

    results.push({ ...p, blank, has404, hasError, errors: errs });
    console.log(`${blank || has404 || hasError ? "FAIL" : "OK"}   ${p.name}`);

    page.removeAllListeners("pageerror");
  }

  await browser.close();

  // Save results
  const issues = results.filter((r) => r.blank || r.has404 || r.hasError || r.errors.length > 0);
  console.log(`\n\nTotal: ${results.length} pages, ${issues.length} with issues`);
  console.log(`Screenshots saved to: ${OUT_DIR}`);
  fs.writeFileSync(path.join(OUT_DIR, "audit-results.json"), JSON.stringify(results, null, 2));
})();
