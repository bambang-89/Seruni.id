import pandas as pd
import json
import os

os.chdir("E:/Seruni.id/docs")

fp = "Data Penduduk KPU 2022 - Seruni Mumbul.xls"

DUSUN = {"MANDAR": "Seruni Barat", "DAMES": "Seruni Timur", "SASAK": "Mumbul Utara", "BRANGTAPEN ASRI": "Mumbul Selatan"}
JK = {"LAKI-LAKI": "L", "P": "P"}
HUB = {"KEPALA KELUARGA": "Kepala Keluarga", "ISTRI": "Istri/Suami", "ANAK": "Anak"}

def fix_nik(val):
    if pd.isna(val):
        return None
    s = str(val).strip().replace(" ", "")
    for old, new in [("OOOO", "0000"), ("OOO", "000"), ("OO", "00")]:
        s = s.replace(old, new)
    s = "".join(c for c in s if c.isdigit())
    if len(s) == 16:
        return s
    return None

def pdate(val):
    if pd.isna(val):
        return None
    if hasattr(val, "strftime"):
        return val.strftime("%Y-%m-%d")
    s = str(val).strip()
    if not s or s.lower() == "nan":
        return None
    if "/" in s:
        parts = s.split("/")
        if len(parts) == 3:
            return parts[2][:4] + "-" + parts[1].zfill(2) + "-" + parts[0].zfill(2)
    return s[:10]

def gv(val, default=None):
    if pd.isna(val):
        return default
    s = str(val).strip()
    return default if s in ("", "-", "nan") else s

def dusuns(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return DUSUN.get(u, gv(val))

def jk_map(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return JK.get(u, gv(val))

def hub_map(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return HUB.get(u, gv(val))

konsol = {}

# AKTIF
print("1. AKTIF...")
df = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=0)
df = df[df["NIK"].notna()]
print("  rows:", len(df))

for _, row in df.iterrows():
    nik = fix_nik(row["NIK"])
    if not nik:
        continue
    if nik in konsol:
        continue
    konsol[nik] = {
        "nik": nik,
        "nama": gv(row.get("NAMA")),
        "no_kk": fix_nik(row.get("NOMOR KK")),
        "jenis_kelamin": jk_map(row.get("JENIS KELAMIN")),
        "tempat_lahir": gv(row.get("TEMPAT LAHIR")),
        "tanggal_lahir": pdate(row.get("TANGGAL LAHIR")),
        "agama": dusuns(row.get("AGAMA")),
        "pendidikan": gv(row.get("PENDIDIKAN DALAM KK")),
        "pekerjaan": gv(row.get("PEKERJAAN")),
        "status_perkawinan": gv(row.get("STATUS PERKAWINAN")),
        "hubungan_kk": hub_map(row.get("HUBUNGAN DALAM KK")),
        "kewarganegaraan": gv(row.get("KEWARGANEGARAAN"), "WNI"),
        "nama_ayah": gv(row.get("NAMA AYAH")),
        "nama_ibu": gv(row.get("NAMA IBU")),
        "dusun": dusuns(row.get("DUSUN")),
        "rt": gv(row.get("RT")),
        "rw": gv(row.get("RW")),
        "alamat": "",
        "status": "aktif",
        "sumber": "XLS-KPU-AKTIF",
    }
    konsol[nik]["alamat"] = str(konsol[nik].get("dusun") or "") + " RT " + str(konsol[nik].get("rt") or "")
    konsol[nik]["alamat"] = konsol[nik]["alamat"].strip()

print("  aktif:", sum(1 for r in konsol.values() if r["status"] == "aktif"))

# MENINGGAL
print("2. MENINGGAL...")
try:
    df_m = pd.read_excel(fp, sheet_name="PDD Meninggal")
    df_m = df_m[df_m["NIK"].notna()]
    print("  rows:", len(df_m))
    for _, row in df_m.iterrows():
        nik = fix_nik(row.get("NIK"))
        if not nik:
            continue
        konsol[nik] = {
            "nik": nik,
            "nama": gv(row.get("NAMA")),
            "tempat_lahir": gv(row.get("TEMPAT LAHIR")),
            "tanggal_lahir": pdate(row.get("TANGGAL LAHIR")),
            "jenis_kelamin": jk_map(row.get("JENIS KELAMIN")),
            "alamat": gv(row.get("ALAMAT")),
            "dusun": dusuns(row.get("DUSUN")),
            "status": "meninggal",
            "sumber": "XLS-KPU-MENINGGAL",
        }
except Exception as e:
    print("  error:", e)

print("  meninggal:", sum(1 for r in konsol.values() if r["status"] == "meninggal")

# PINDAH MASUK
print("3. PINDAH MASUK...")
try:
    df_pm = pd.read_excel(fp, sheet_name="Pindah Masuk")
    df_pm = df_pm[df_pm["NIK"].notna()]
    print("  rows:", len(df_pm))
    for _, row in df_pm.iterrows():
        nik = fix_nik(row.get("NIK"))
        if not nik:
            continue
        konsol[nik] = {
            "nik": nik,
            "nama": gv(row.get("NAMA")),
            "tempat_lahir": gv(row.get("TEMPAT LAHIR")),
            "tanggal_lahir": pdate(row.get("TANGGAL LAHIR")),
            "jenis_kelamin": jk_map(row.get("JENIS KELAMIN")),
            "alamat": gv(row.get("ALAMAT")),
            "dusun": dusuns(row.get("DUSUN")),
            "status": "pindah_masuk",
            "sumber": "XLS-KPU-PINDAH-MASUK",
        }
except Exception as e:
    print("  error:", e)

print("  pindah_masuk:", sum(1 for r in konsol.values() if r["status"] == "pindah_masuk")

# PINDAH KELUAR
print("4. PINDAH KELUAR...")
try:
    df_pk = pd.read_excel(fp, sheet_name="Pindah Keluar")
    df_pk = df_pk[df_pk["NIK"].notna()]
    print("  rows:", len(df_pk))
    for _, row in df_pk.iterrows():
        nik = fix_nik(row.get("NIK"))
        if not nik:
            continue
        konsol[nik] = {
            "nik": nik,
            "nama": gv(row.get("NAMA")),
            "tempat_lahir": gv(row.get("TEMPAT LAHIR")),
            "tanggal_lahir": pdate(row.get("TANGGAL LAHIR")),
            "jenis_kelamin": jk_map(row.get("JENIS KELAMIN")),
            "alamat": gv(row.get("ALAMAT")),
            "dusun": dusuns(row.get("DUSUN")),
            "status": "pindah_keluar",
            "sumber": "XLS-KPU-PINDAH-KELUAR",
        }
except Exception as e:
    print("  error:", e)

print("  pindah_keluar:", sum(1 for r in konsol.values() if r["status"] == "pindah_keluar")

# SUMMARY
counts = {}
for r in konsol.values():
    s = r["status"]
    counts[s] = counts.get(s, 0) + 1

print()
print("=" * 50)
print("KONSOLIDASI SUMMARY")
print("=" * 50)
for s in sorted(counts):
    print(" ", s, ":", counts[s])
print("  TOTAL:", len(konsol))

# SAVE
out = "penduduk_konsolidasi.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(konsol, f, ensure_ascii=False, indent=2)
print("Saved:", out)
