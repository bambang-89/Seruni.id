#!/usr/bin/env python3
"""Konsolidasi penduduk.csv dengan data GPU - versi final"""
import pandas as pd
import csv
from datetime import datetime

FP_XLS = "E:/Seruni.id/docs/Data Penduduk GPU 2022 - Seruni Mumbul.xls".replace("GPU","KPU")
FP_CSV = "E:/Seruni.id/docs/penduduk.csv"
FP_OUT = "E:/Seruni.id/docs/penduduk_konsolidasi_final.csv"

DUSUN_MAP = {"MANDAR":"Seruni Barat","DAMES":"Seruni Timur","SASAK":"Mumbul Utara","BRANGTAPEN ASRI":"Mumbul Selatan"}
JK_MAP = {"LAKI-LAKI":"L","LAKI LAKI":"L","P":"P","PEREMPUAN":"P"}
STATUS_MAP = {"BELUM KAWIN":"Belum Kawin","KAWIN":"Kawin","CERAI HIDUP":"Cerai Hidup","CERAI MATI":"Cerai Mati"}
HUB_MAP = {"KEPALA KELUARGA":"Kepala Keluarga","ISTRI":"Istri/Suami","SUAMI":"Istri/Suami","ANAK":"Anak","FAMILI LAIN":"Famili Lain","MERTUA":"Mertua"}

def fix_nik(v):
    if pd.isna(v): return None
    s = str(v).strip().replace(" ","")
    for x in ["OOOO","OOO","OO"]: s = s.replace(x,"0"*len(x))
    s = "".join(c for c in s if c.isdigit())
    return s if len(s)==16 else None

def gv(v, d=None):
    if pd.isna(v): return d
    s = str(v).strip()
    return d if s in ("","-","nan","NaN","None") else s

def map_dusun(v):
    if pd.isna(v): return None
    return DUSUN_MAP.get(str(v).upper().strip(), gv(v))

def map_jk(v):
    if pd.isna(v): return None
    return JK_MAP.get(str(v).upper().strip(), gv(v))

def map_status(v):
    if pd.isna(v): return None
    return STATUS_MAP.get(str(v).upper().strip(), gv(v))

def map_hub(v):
    if pd.isna(v): return None
    return HUB_MAP.get(str(v).upper().strip(), gv(v))

def parse_date(v):
    if pd.isna(v): return None
    if hasattr(v,"strftime"): return v.strftime("%Y-%m-%d")
    s = str(v).strip()
    return s[:10] if s and s!="nan" else None

CSV_COLS = ["PROVINSI","KABUPATEN","KECAMATAN","DESA","DUSUN","RT","NAMA","JENIS_KELAMIN","STATUS_DALAM_KK","NO_KK","NIK","STATUS_PERKAWINAN","TEMPAT_LAHIR","TANGGAL_LAHIR","PENDIDIKAN","PEKERJAAN","PENDAPATAN_BULAN","KEWARGANEGARAAN","AGAMA","SUKU","KEPEMILIKAN_RUMAH","LUAS_RUMAH","JUMLAH_LANTAI","JENIS_LANTAI","JENIS_DINDING","JENIS_ATAP","KEPEMILIKAN_TANAH","LUAS_TANAH","PENERANGAN","SUMBER_ENERGI_MASAK","MCK","SUMBER_AIR","BANTUAN_SOSIAL","BANTUAN_EXTRA","BPJS_KESEHATAN","BPJS_KETENAGAKERJAAN","KEPEMILIKAN_ASET","KONDISI_FISIK","NAMA_IBU","NAMA_BAPAK","GOLONGAN_DARAH"]

def gpu_to_csv(rec, status):
    d = {}
    for c in CSV_COLS: d[c] = ""
    d["PROVINSI"] = "Nusa Tenggara Barat"
    d["KABUPATEN"] = "Lombok Timur"
    d["KECAMATAN"] = "Pringgabaya"
    d["DESA"] = "Seruni Mumbul"
    d["NIK"] = rec.get("nik","")
    d["NAMA"] = rec.get("nama","")
    d["NO_KK"] = rec.get("no_kk","")
    d["JENIS_KELAMIN"] = rec.get("jk","")
    d["TEMPAT_LAHIR"] = rec.get("tl","")
    d["TANGGAL_LAHIR"] = rec.get("tgl","")
    d["AGAMA"] = rec.get("agama","")
    d["PENDIDIKAN"] = rec.get("pend","")
    d["PEKERJAAN"] = rec.get("pek","")
    d["STATUS_PERKAWINAN"] = rec.get("skaw","")
    d["HUBUNGAN_KK"] = rec.get("hub","")
    d["KEWARGANEGARAAN"] = rec.get("kwn","WNI")
    d["NAMA_AYAH"] = rec.get("ayah","")
    d["NAMA_IBU"] = rec.get("ibu","")
    d["DUSUN"] = rec.get("dusun","")
    d["RT"] = rec.get("rt","")
    d["RW"] = rec.get("rw","")
    d["ALAMAT"] = rec.get("alamat","")
    d["STATUS_PENDUDUK"] = status
    d["KEPEMILIKAN_RUMAH"] = "-"
    d["LUAS_RUMAH"] = "-"
    d["JUMLAH_LANTAI"] = "-"
    d["JENIS_LANTAI"] = "-"
    d["JENIS_DINDING"] = "-"
    d["JENIS_ATAP"] = "-"
    d["KEPEMILIKAN_TANAH"] = "-"
    d["LUAS_TANAH"] = "-"
    d["PENERANGAN"] = "Tidak"
    d["SUMBER_ENERGI_MASAK"] = "Tidak"
    d["MCK"] = "Tidak"
    d["BANTUAN_SOSIAL"] = "Tidak"
    d["BANTUAN_EXTRA"] = "Tidak"
    d["BPJS_KESEHATAN"] = "Tidak"
    d["BPJS_KETENAGAKERJAAN"] = "Tidak"
    d["KONDISI_FISIK"] = "Normal"
    return d

def is_placeholder_ttl(tl):
    if not tl: return True
    u = str(tl).upper()
    return "SERUNI" in u or "PRINGGABAYA" in u or "LOMBOK TIMUR" in u

def completeness_score(row):
    score = 0
    if row.get("_source") == "csv": score += 100
    for col in ["NAMA","TEMPAT_LAHIR","TANGGAL_LAHIR","AGAMA","JENIS_KELAMIN","DUSUN","RT"]:
        if row.get(col,"").strip(): score += 1
    if is_placeholder_ttl(row.get("TEMPAT_LAHIR","")): score -= 5
    return score

print("="*60)
print("KONSOLIDASI FINAL v2")
print("="*60)
print()

print("1. Loading penduduk.csv...")
csv_data = {}
with open(FP_CSV, "r", encoding="utf-8-sig") as f:
    for row in csv.DictReader(f):
        nik = str(row.get("NIK","")).strip()
        if len(nik)==16 and nik.isdigit():
            csv_data[nik] = row
print(f"   Loaded: {len(csv_data)}")

nik_sheets = {}
def track(nik, sheet):
    if nik not in nik_sheets: nik_sheets[nik] = set()
    nik_sheets[nik].add(sheet)

print("2. Loading GPU sheets...")

df_a = pd.read_excel(FP_XLS, sheet_name="DATA PENDUDUK", header=None)
aktif = {}
for _, row in df_a.iloc[2:].iterrows():
    nik = fix_nik(row.iloc[1] if len(row)>1 else None)
    if not nik or nik in aktif: continue
    track(nik, "aktif")
    dusun = map_dusun(row.iloc[4] if len(row)>4 else None)
    rt = gv(row.iloc[3] if len(row)>3 else None)
    aktif[nik] = {"nik":nik,"nama":gv(row.iloc[2]),"no_kk":fix_nik(row.iloc[9] if len(row)>9 else None),"jk":map_jk(row.iloc[7] if len(row)>7 else None),"tl":gv(row.iloc[5]),"tgl":parse_date(row.iloc[6] if len(row)>6 else None),"agama":gv(row.iloc[8]),"pend":gv(row.iloc[10]),"pek":gv(row.iloc[11]),"skaw":map_status(row.iloc[12] if len(row)>12 else None),"hub":map_hub(row.iloc[13] if len(row)>13 else None),"kwn":gv(row.iloc[14] if len(row)>14 else None,"WNI"),"ayah":gv(row.iloc[15] if len(row)>15 else None),"ibu":gv(row.iloc[16] if len(row)>16 else None),"dusun":dusun,"rt":rt,"rw":gv(row.iloc[18] if len(row)>18 else None),"alamat":dusun or ""}
print(f"   AKTIF: {len(aktif)}")

df_m = pd.read_excel(FP_XLS, sheet_name="PDD Meninggal", header=None)
meninggal = {}
for _, row in df_m.iloc[9:].iterrows():
    nik = fix_nik(row.iloc[2] if len(row)>2 else None)
    if not nik or nik in meninggal: continue
    track(nik, "meninggal")
    meninggal[nik] = {"nik":nik,"nama":gv(row.iloc[3]),"jk":map_jk(row.iloc[6] if len(row)>6 else None),"tl":gv(row.iloc[4]),"tgl":parse_date(row.iloc[5] if len(row)>5 else None),"alamat":gv(row.iloc[7]),"dusun":map_dusun(row.iloc[9] if len(row)>9 else None)}
print(f"   MENINGGAL: {len(meninggal)}")

df_pm = pd.read_excel(FP_XLS, sheet_name="Pindah Masuk", header=None)
pmasuk = {}
for _, row in df_pm.iloc[9:].iterrows():
    nik = fix_nik(row.iloc[2] if len(row)>2 else None)
    if not nik or nik in pmasuk: continue
    track(nik, "pindah_masuk")
    pmasuk[nik] = {"nik":nik,"nama":gv(row.iloc[3]),"jk":map_jk(row.iloc[6] if len(row)>6 else None),"tl":gv(row.iloc[4]),"tgl":parse_date(row.iloc[5] if len(row)>5 else None),"alamat":gv(row.iloc[7]),"dusun":map_dusun(row.iloc[8] if len(row)>8 else None)}
print(f"   PINDAH MASUK: {len(pmasuk)}")

df_pk = pd.read_excel(FP_XLS, sheet_name="Pindah Keluar", header=None)
pkeluar = {}
for _, row in df_pk.iloc[9:].iterrows():
    nik = fix_nik(row.iloc[2] if len(row)>2 else None)
    if not nik or nik in pkeluar: continue
    track(nik, "pindah_keluar")
    pkeluar[nik] = {"nik":nik,"nama":gv(row.iloc[3]),"jk":map_jk(row.iloc[6] if len(row)>6 else None),"tl":gv(row.iloc[4]),"tgl":parse_date(row.iloc[5] if len(row)>5 else None),"alamat":gv(row.iloc[7]),"dusun":map_dusun(row.iloc[8] if len(row)>8 else None)}
print(f"   PINDAH KELUAR: {len(pkeluar)}")

def get_status(nik):
    sheets = nik_sheets.get(nik, set())
    if "meninggal" in sheets: return "meninggal"
    if "pindah_keluar" in sheets: return "pindah_keluar"
    if "aktif" in sheets: return "aktif"
    if "pindah_masuk" in sheets: return "pindah_masuk"
    return "aktif"

print()
print("3. Building output...")
output = []
processed = set()
removed_meni = 0
removed_pkeluar = 0
kept_csv = 0

# Process CSV rows - skip if marked meninggal/pindah_keluar
for nik, row in csv_data.items():
    status = get_status(nik)
    if status == "meninggal":
        removed_meni += 1
        continue
    if status == "pindah_keluar":
        removed_pkeluar += 1
        continue
    out_row = dict(row)
    out_row["STATUS_PENDUDUK"] = status
    output.append(out_row)
    processed.add(nik)
    kept_csv += 1

# Add GPU aktif NOT in CSV
added_aktif = 0
added_aktif_meni = 0
added_aktif_pk = 0
for nik, rec in aktif.items():
    if nik not in processed:
        final_status = get_status(nik)
        output.append(gpu_to_csv(rec, final_status))
        processed.add(nik)
        if final_status == "aktif":
            added_aktif += 1
        elif final_status == "meninggal":
            added_aktif_meni += 1
        elif final_status == "pindah_keluar":
            added_aktif_pk += 1

# Add GPU pindah_masuk NOT in CSV
added_pmasuk = 0
for nik, rec in pmasuk.items():
    if nik not in processed:
        output.append(gpu_to_csv(rec, "pindah_masuk"))
        processed.add(nik)
        added_pmasuk += 1

# Add GPU meninggal NOT in CSV
added_meni = 0
for nik, rec in meninggal.items():
    if nik not in processed:
        output.append(gpu_to_csv(rec, "meninggal"))
        processed.add(nik)
        added_meni += 1

# Add GPU pindah_keluar NOT in CSV
added_pkeluar_gpu = 0
for nik, rec in pkeluar.items():
    if nik not in processed:
        output.append(gpu_to_csv(rec, "pindah_keluar"))
        processed.add(nik)
        added_pkeluar_gpu += 1

print(f"   Dari CSV (dipertahankan): {kept_csv}")
print(f"   Dihapus (meninggal):      {removed_meni}")
print(f"   Dihapus (pindah keluar):  {removed_pkeluar}")
print(f"   Ditambah (aktif benar):     {added_aktif}")
print(f"   Ditambah (aktif->meninggal):{added_aktif_meni}")
print(f"   Ditambah (aktif->pklr):    {added_aktif_pk}")
print(f"   Ditambah (pindah masuk):   {added_pmasuk}")
print(f"   Ditambah (meninggal):      {added_meni}")
print(f"   Ditambah (pindah keluar):  {added_pkeluar_gpu}")
print(f"   TOTAL:                     {len(output)}")

print()
print("4. Deduplication (placeholder TTL)...")

# Tag sources
for r in output:
    if r.get("AGAMA","").strip() and r.get("AGAMA","").strip() not in ("","-"):
        r["_source"] = "csv"
    else:
        r["_source"] = "gpu"

# Group by (nama, ttl, tgl, jk)
def make_key(row):
    nama = str(row.get("NAMA","")).strip().upper()
    tl = str(row.get("TEMPAT_LAHIR","")).strip().upper()
    tgl = str(row.get("TANGGAL_LAHIR","")).strip()
    jk = str(row.get("JENIS_KELAMIN","")).strip().upper()
    return (nama, tl, tgl, jk)

groups = {}
for i, row in enumerate(output):
    key = make_key(row)
    if key not in groups: groups[key] = []
    groups[key].append(i)

dup_keys = {k:v for k,v in groups.items() if len(v)>1}
valid_dup = {k:v for k,v in dup_keys.items() if not is_placeholder_ttl(k[1])}
placeholder_dup = {k:v for k,v in dup_keys.items() if is_placeholder_ttl(k[1])}

print(f"   Group near-duplicate: {len(dup_keys)}")
print(f"   - Valid TTL (keep all): {len(valid_dup)}")
print(f"   - Placeholder TTL (dedupe): {len(placeholder_dup)}")

removed_dups = 0
indices_to_remove = set()
for key, group in placeholder_dup.items():
    scored = [(i, output[i], completeness_score(output[i])) for i in group]
    scored.sort(key=lambda x: (-x[2], x[0]))
    for i, row, score in scored[1:]:
        indices_to_remove.add(i)
        removed_dups += 1

print(f"   Baris dihapus (duplikat): {removed_dups}")

# Build final
sorted_indices = sorted(indices_to_remove, reverse=True)
for idx in sorted_indices:
    output.pop(idx)

for row in output:
    row.pop("_source", None)

print(f"   Total setelah dedup: {len(output)}")
print()
print("5. Writing output...")
for row in output:
    if "STATUS_PENDUDUK" not in row: row["STATUS_PENDUDUK"] = ""

all_cols = CSV_COLS + ["STATUS_PENDUDUK"]
with open(FP_OUT, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.DictWriter(f, fieldnames=all_cols, extrasaction="ignore")
    w.writeheader()
    w.writerows(output)
print(f"   Written: {FP_OUT}")

print()
print("="*60)
print("SUMMARY")
print("="*60)
sc = {}
for row in output:
    s = row.get("STATUS_PENDUDUK","unknown")
    sc[s] = sc.get(s,0)+1
for s,c in sorted(sc.items()): print(f"  {s}: {c}")
print(f"  TOTAL: {len(output)}")
print()
print(f"  CSV original: {len(csv_data)}")
print(f"  Dihapus (meninggal):     {removed_meni}")
print(f"  Dihapus (pindah keluar): {removed_pkeluar}")
print(f"  Dihapus (duplikat):     {removed_dups}")
print(f"  Ditambah (aktif):       {added_aktif}")
print(f"  Ditambah (pindah masuk): {added_pmasuk}")
print(f"  Ditambah (meninggal):    {added_meni}")
print(f"  Ditambah (pindah keluar):{added_pkeluar_gpu}")
print(f"  Net:                    {len(output) - len(csv_data)}")
print()
print("Done!")
