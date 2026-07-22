import pandas as pd
import csv
from datetime import datetime

FP_CSV = "E:/Seruni.id/docs/penduduk.csv"
FP_OUT = "E:/Seruni.id/docs/penduduk_cleanup.csv"

def parse_date_str(v):
    if not v:
        return None
    s = str(v).strip()
    if not s or s in ("-", "nan"):
        return None
    if "/" in s:
        parts = s.split("/")
        if len(parts) == 3:
            try:
                d, m, y = parts[0].zfill(2), parts[1].zfill(2), parts[2][:4]
                return f"{y}-{m}-{d}"
            except:
                pass
    if "-" in s:
        return s[:10]
    return None

def is_placeholder_ttl(tl):
    """Return True if TTL is a placeholder address, not a real birthplace."""
    if not tl:
        return True
    u = str(tl).upper()
    return "SERUNI" in u or "PRINGGABAYA" in u or "LOMBOK TIMUR" in u

def completeness_score(row):
    score = 0
    if row.get("_source") == "csv":
        score += 100
    for col in ["NAMA", "TEMPAT_LAHIR", "TANGGAL_LAHIR", "AGAMA", "JENIS_KELAMIN", "DUSUN", "RT"]:
        if row.get(col, "").strip():
            score += 1
    if is_placeholder_ttl(row.get("TEMPAT_LAHIR", "")):
        score -= 5
    return score

print("=" * 60)
print("CLEANUP PENDUDUK v2")
print("=" * 60)
print()

# Load
print("Loading CSV...")
rows = []
with open(FP_CSV, "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        rows.append(row)
print(f"  Total rows: {len(rows)}")

# Tag source
for r in rows:
    agama = r.get("AGAMA", "").strip()
    if agama and agama not in ("", "-", "nan"):
        r["_source"] = "csv"
    else:
        r["_source"] = "gpu"

# Status counts
status_counts = {}
for r in rows:
    s = r.get("STATUS_PENDUDUK", "unknown")
    status_counts[s] = status_counts.get(s, 0) + 1
print()
print("Status sebelum cleanup:")
for s, c in sorted(status_counts.items()):
    print(f"  {s}: {c}")

# Remove meninggal & pindah_keluar
print()
print("Menghapus meninggal & pindah keluar...")
before = len(rows)
rows = [r for r in rows if r.get("STATUS_PENDUDUK", "") not in ("meninggal", "pindah_keluar")]
removed_status = before - len(rows)
print(f"  Dihapus: {removed_status}")

csv_count = sum(1 for r in rows if r.get("_source") == "csv")
gpu_count = sum(1 for r in rows if r.get("_source") == "gpu")
print(f"  Dari CSV: {csv_count}, dari GPU: {gpu_count}")

# Find near-duplicates
print()
print("Mencari near-duplicate...")

def make_key(row):
    nama = str(row.get("NAMA", "")).strip().upper()
    tl = str(row.get("TEMPAT_LAHIR", "")).strip().upper()
    tgl = str(row.get("TANGGAL_LAHIR", "")).strip()
    jk = str(row.get("JENIS_KELAMIN", "")).strip().upper()
    return (nama, tl, tgl, jk)

groups = {}
for i, row in enumerate(rows):
    key = make_key(row)
    if key not in groups:
        groups[key] = []
    groups[key].append((i, row))

dup_keys = {k: v for k, v in groups.items() if len(v) > 1}
print(f"  Group near-duplicate: {len(dup_keys)}")

# Split: valid TTL duplicates vs placeholder TTL duplicates
valid_dup_keys = {}
placeholder_dup_keys = {}
for key, group in dup_keys.items():
    _, tl, _, _ = key
    if is_placeholder_ttl(tl):
        placeholder_dup_keys[key] = group
    else:
        valid_dup_keys[key] = group

print(f"  - Valid TTL (keep all): {len(valid_dup_keys)}")
print(f"  - Placeholder TTL (dedupe): {len(placeholder_dup_keys)}")

# Dedupe placeholder groups only
print()
print("Mendeduplikasi placeholder TTL...")
removed_dups = 0
indices_to_remove = set()

for key, group in placeholder_dup_keys.items():
    scored = [(i, r, completeness_score(r)) for i, r in group]
    scored.sort(key=lambda x: (-x[2], x[0]))
    best_i, best_row, best_score = scored[0]
    for i, row, score in scored[1:]:
        indices_to_remove.add(i)
        removed_dups += 1

print(f"  Baris dihapus: {removed_dups}")
print(f"  Note: SUHARDI & ARIFULLAH tidak dihapus (TTL valid)")

# Verify SUHARDI and ARIFULLAH are still present
suhardi_found = sum(1 for r in rows if str(r.get("NAMA","")).strip().upper() == "SUHARDI")
arifullah_found = sum(1 for r in rows if str(r.get("NAMA","")).strip().upper() == "ARIFULLAH")
print(f"  SUHARDI tetap: {suhardi_found} record")
print(f"  ARIFULLAH tetap: {arifullah_found} record")

# Build output
print()
print("Membuild output...")
sorted_indices = sorted(indices_to_remove, reverse=True)
for idx in sorted_indices:
    rows.pop(idx)

for row in rows:
    row.pop("_source", None)

print(f"  Total setelah cleanup: {len(rows)}")

# Status count
status_counts_final = {}
for r in rows:
    s = r.get("STATUS_PENDUDUK", "unknown")
    status_counts_final[s] = status_counts_final.get(s, 0) + 1
print()
print("Status setelah cleanup:")
for s, c in sorted(status_counts_final.items()):
    print(f"  {s}: {c}")

# Write
print()
print("Menulis output...")
all_cols = None
for row in rows:
    if all_cols is None:
        all_cols = list(row.keys())
    else:
        for k in row.keys():
            if k not in all_cols:
                all_cols.append(k)

with open(FP_OUT, "w", encoding="utf-8-sig", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=all_cols, extrasaction="ignore")
    writer.writeheader()
    writer.writerows(rows)
print(f"  Written: {FP_OUT}")

print()
print("=" * 60)
print("SUMMARY")
print("=" * 60)
orig_total = len(rows) + removed_status + removed_dups
print(f"  Awal:           {orig_total}")
print(f"  Hapus status:   {removed_status}")
print(f"  Hapus duplikat: {removed_dups}")
print(f"  Final:          {len(rows)}")
print(f"  Net change:     {len(rows) - orig_total}")
print()
print("Done!")
