# Visual Regression — Seruni Editorial System

Automated screenshot checks for the homepage and key inner routes to catch
styling drift in the editorial section primitives (no rounded radius, no
icons, hairline dividers, italic display headings).

## Prerequisites

Runs inside the Lovable sandbox where Playwright is preinstalled. No
`playwright install` needed. The dev server must already be running at
`http://localhost:8080` (Vite starts it automatically).

## Run baseline capture (first run)

```
python3 tests/visual/pages.spec.py --update
```

Baselines are written to `tests/visual/baseline/<route>.png`.

## Run regression check (subsequent runs)

```
python3 tests/visual/pages.spec.py
```

For each route the script captures a fresh screenshot to
`tests/visual/current/<route>.png` and diffs it against the baseline.
A route fails if the pixel diff ratio exceeds `THRESHOLD` (default 1%).
Failures are written as `tests/visual/diff/<route>.png` (red overlay).

## Routes covered

- `/`               — Home (Editorial Portal)
- `/berita`         — News list
- `/kalender-desa`  — Agenda
- `/layanan`        — Services catalog
- `/status-idm`     — IDM stats
- `/potensi`        — Village potential
- `/marketplace`    — Marketplace
- `/peta`           — Map

Add or remove entries in the `ROUTES` list inside `pages.spec.py`.