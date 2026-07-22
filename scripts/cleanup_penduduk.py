import pandas as pd
import csv
from datetime import datetime

FP_CSV = "E:/Seruni.id/docs/penduduk.csv"
FP_OUT = "E:/Seruni.id/docs/penduduk_cleanup.csv"

# ========================
# Helpers
# ========================
def parse_date_str(v):
    """Parse date from dd/mm/yyyy or yyyy-mm-d string."""
    if not v:
        return None
    s = str(v).strip()
    if not s or s in ("-", "nan"):
        return None
    # dd/mm/yyyy
    if "/" in s:
        parts = s.split("/")
        if len(parts) == 3:
            try:
                d, m, y = parts[0].zfill(2), parts[1].zfill(2), parts[2][:4]
                return f"{y}-{m}-{d}"
            except:
                pass
    # yyyy-mm-d
    if "-" in s:
        return s[:10]
    return None

def completeness_score(row):
    """Higher = more complete data. Prefer CSV source."""
    score = 0
    csv_source = row.get("_source", "") == "csv"
    if csv_source:
        score += 100
    # Non-empty critical fields
    for col in ["NAMA", "TEMPAT_LAHIR", "TANGGAL_LAHIR", "AGAMA", "JENIS_KELAMIN", "DUSUN", "RT"]:
        if row.get(col, "").strip():
            score += 1
    # Check if TTL is a placeholder (SERUNI MUMBUL, PRINGGABAY, LOMBOK TIMUR)
    tl = str(row.get("TEMPAT_LAHIR", "")).upper()
    if "SERUNI" in tl or "PRINGGABAYA" in tl or "LOMBOK TIMUR" in tl:
        score -= 5
    return score

print("=" * 60)
print("CLEANUP PENDUDUK")
print("=" * 60)
print()

# ========================
# Load data
# ========================
print("Loading CSV...")
rows = []
with open(FP_CSV, "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        rows.append(row)
print(f"  Total rows: {len(rows)}")

# ========================
# Step 1: Count by status
# ========================
status_counts = {}
for r in rows:
    s = r.get("STATUS_PENDUDUK", "unknown")
    status_counts[s] = status_counts.get(s, 0) + 1
print()
print("Status sebelum cleanup:")
for s, c in sorted(status_counts.items()):
    print(f"  {s}: {c}")

# ========================
# Step 2: Remove meninggal & pindah_keluar
# ========================
print()
print("Menghapus meninggal & pindah keluar...")
before = len(rows)
rows = [r for r in rows if r.get("STATUS_PENDUDUK", "") not in ("meninggal", "pindah_keluar")]
removed_status = before - len(rows)
print(f"  Dihapus: {removed_status}")

# ========================
# Step 3: Tag each row as from CSV or GPU
# ========================
# Rows from CSV have fully populated agama/pendidikan/pekerjaan/etc
# GPU-added rows have empty agama/pendidikan for most fields
for r in rows:
    agama = r.get("AGAMA", "").strip()
    if agama and agama not in ("", "-", "nan"):
        r["_source"] = "csv"
    else:
        r["_source"] = "gpu"

csv_count = sum(1 for r in rows if r.get("_source") == "csv")
gpu_count = sum(1 for r in rows if r.get("_source") == "gpu")
print(f"  Dari CSV: {csv_count}, dari GPU: {gpu_count}")

# ========================
# Step 4: Find near-duplicates (nama+ttl+jk)
# ========================
print()
print("Mencari near-duplicate...")

def make_key(row):
    nama = str(row.get("NAMA", "")).strip().upper()
    tl = str(row.get("TEMPAT_LAHIR", "")).strip().upper()
    tgl = str(row.get("TANGGAL_LAHIR", "")).strip()
    jk = str(row.get("JENIS_KELAMIN", "")).strip().upper()
    # Normalize TTL
    if "SERUNI" in tl or "PRINGGABAYA" in tl:
        tl = "INVALID_TTL"
    if "LOMBOK TIMUR" in tl:
        tl = "INVALID_TTL"
    return (nama, tl, tgl, jk)

groups = {}
for i, row in enumerate(rows):
    key = make_key(row)
    if key not in groups:
        groups[key] = []
    groups[key].append((i, row))

# Find groups with >1 row
dup_keys = {k: v for k, v in groups.items() if len(v) > 1}
print(f"  Group near-duplicate: {len(dup_keys)}")
print(f"  Total affected rows: {sum(len(v) for v in dup_keys.values())}")

# ========================
# Step 5: Deduplicate - keep best record per group
# ========================
print()
print("Mendeduplikasi...")

removed_dups = 0
indices_to_remove = set()

for key, group in dup_keys.items():
    # Score each row
    scored = [(i, r, completeness_score(r)) for i, r in group]
    # Sort: highest score first, then by row index (lower = earlier in file = prefer old)
    scored.sort(key=lambda x: (-x[2], x[0]))
    # Keep first (best), mark rest for removal
    best_i, best_row, best_score = scored[0]
    for i, row, score in scored[1:]:
        indices_to_remove.add(i)
        removed_dups += 1

print(f"  Baris dihapus (duplikat): {removed_dups}")

# ========================
# Step 6: Build final output
# ========================
print()
print("Membuild output...")

# Remove marked indices (reverse order to preserve indices)
sorted_indices = sorted(indices_to_remove, reverse=True)
for idx in sorted_indices:
    rows.pop(idx)

# Remove internal columns
for row in rows:
    row.pop("_source", None)

print(f"  Total setelah cleanup: {len(rows)}")

# ========================
# Step 7: Final status count
# ========================
status_counts_final = {}
for r in rows:
    s = r.get("STATUS_PENDUDUK", "unknown")
    status_counts_final[s] = status_counts_final.get(s, 0) + 1

print()
print("Status setelah cleanup:")
for s, c in sorted(status_counts_final.items()):
    print(f"  {s}: {c}")

# ========================
# Step 8: Write output
# ========================
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

# ========================
# Summary
# ========================
print()
print("=" * 60)
print("SUMMARY")
print("=" * 60)
print(f"  Awal:           {len(rows) + removed_status + removed_dups}")
print(f"  Hapus status:   {removed_status}")
print(f"  Hapus duplikat: {removed_dups}")
print(f"  Final:          {len(rows)}")
print(f"  Net change:     {len(rows) - (len(rows) + removed_status + removed_dups)}")
print()
print("Done!")
