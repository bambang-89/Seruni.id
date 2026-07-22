"""
Visual regression checks for the Seruni editorial system.
Run inside the Lovable sandbox (Playwright preinstalled).

Usage:
    python3 tests/visual/pages.spec.py            # compare against baseline
    python3 tests/visual/pages.spec.py --update   # rewrite baselines
"""

import asyncio
import sys
from pathlib import Path

from PIL import Image, ImageChops
from playwright.async_api import async_playwright

ROOT = Path(__file__).parent
BASELINE = ROOT / "baseline"
CURRENT = ROOT / "current"
DIFF = ROOT / "diff"
for d in (BASELINE, CURRENT, DIFF):
    d.mkdir(parents=True, exist_ok=True)

BASE_URL = "http://localhost:8080"
VIEWPORT = {"width": 1280, "height": 1800}
THRESHOLD = 0.01  # 1% pixel-diff ratio allowed

ROUTES = [
    ("home", "/"),
    ("berita", "/berita"),
    ("kalender", "/kalender-desa"),
    ("layanan", "/layanan"),
    ("status-idm", "/status-idm"),
    ("potensi", "/potensi"),
    ("marketplace", "/marketplace"),
    ("peta", "/peta"),
]


def diff_ratio(a: Path, b: Path, out: Path) -> float:
    im_a = Image.open(a).convert("RGB")
    im_b = Image.open(b).convert("RGB")
    if im_a.size != im_b.size:
        im_b = im_b.resize(im_a.size)
    diff = ImageChops.difference(im_a, im_b)
    bbox = diff.getbbox()
    if not bbox:
        return 0.0
    # crude ratio: non-zero pixels / total pixels
    hist = diff.convert("L").point(lambda p: 255 if p > 10 else 0).getdata()
    changed = sum(1 for p in hist if p)
    total = im_a.size[0] * im_a.size[1]
    ratio = changed / total
    # write red-tinted diff overlay for inspection
    red = Image.new("RGB", im_a.size, (255, 0, 0))
    mask = diff.convert("L").point(lambda p: 255 if p > 10 else 0)
    composite = Image.composite(red, im_a, mask)
    composite.save(out)
    return ratio


async def capture(update: bool) -> int:
    failed: list[tuple[str, float]] = []
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(headless=True)
        ctx = await browser.new_context(viewport=VIEWPORT, reduced_motion="reduce")
        page = await ctx.new_page()
        for name, route in ROUTES:
            url = f"{BASE_URL}{route}"
            print(f"→ {name:12s} {url}")
            await page.goto(url, wait_until="networkidle")
            await page.wait_for_timeout(300)
            current = CURRENT / f"{name}.png"
            await page.screenshot(path=str(current))
            baseline = BASELINE / f"{name}.png"
            if update or not baseline.exists():
                current.replace(baseline)
                print(f"  baseline written")
                continue
            ratio = diff_ratio(baseline, current, DIFF / f"{name}.png")
            status = "OK" if ratio <= THRESHOLD else "FAIL"
            print(f"  {status}  diff={ratio*100:.3f}%")
            if ratio > THRESHOLD:
                failed.append((name, ratio))
        await browser.close()
    if failed:
        print("\nRegressions:")
        for name, ratio in failed:
            print(f"  - {name}: {ratio*100:.3f}% (see tests/visual/diff/{name}.png)")
        return 1
    print("\nAll routes match baseline.")
    return 0


if __name__ == "__main__":
    update = "--update" in sys.argv
    sys.exit(asyncio.run(capture(update)))