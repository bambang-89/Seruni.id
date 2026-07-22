import pandas as pd
import json
import os

os.chdir("E:/Seruni.id/docs")
fp = "Data Penduduk KPU 2022 - Seruni Mumbul.xls"

DUSUN_MAP = {
    "MANDAR": "Seruni Barat",
    "DAMES": "Seruni Timur",
    "SASAK": "Mumbul Utara",
    "BRANGTAPEN ASRI": "Mumbul Selatan",
}
JK_MAP = {"LAKI-LAKI": "L", "P": "P"}
HUB_MAP = {"KEPALA KELUARGA": "Kepala Keluarga", "ISTRI": "Istri/Suami", "ANAK": "Anak", "FAMILI LAIN": "Famili Lain", "MERTUA": "Mertua"}
SKAW_MAP = {"BELUM KAWIN": "Belum Kawin", "KAWIN": "Kawin", "CERAI HIDUP": "Cerai Hidup", "CERAI MATI": "Cerai Mati"}

def fix_nik(val):
    if pd.isna(val):
        return None
    s = str(val).strip().replace(" ", "")
    s = s.replace("OOOO", "0000").replace("OOO", "000").replace("OO", "00")
    s = "".join(c for c in s if c.isdigit())
    if len(s) == 16:
        return s
    return None

def parse_date(val):
    if pd.isna(val):
        return None
    if hasattr(val, "strftime"):
        return val.strftime("%Y-%m-%d")
    s = str(val).strip()
    if not s or s == "nan":
        return None
    return s[:10]

def gv(val, default=None):
    if pd.isna(val):
        return default
    s = str(val).strip()
    return default if s in ("", "-", "nan", "NaN") else s

def map_dusun(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return DUSUN_MAP.get(u, gv(val))

def map_jk(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return JK_MAP.get(u, gv(val))

def map_hub(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return HUB_MAP.get(u, gv(val))

def map_sk(val):
    if pd.isna(val):
        return None
    u = str(val).upper().strip()
    return SKAW_MAP.get(u, gv(val))

konsol = {}

# ====================
# AKTIF
# ====================
print("1. DATA AKTIF...")
df_aktif = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=0)
df_aktif = df_aktif[df_aktif["NIK"].notna()]
print(f"   Rows with NIK: {len(df_aktif)}")
for _, row in df_aktif.iterrows():
    nik = fix_nik(row["NIK"])
    if not nik or nik in konsol:
        continue
    konsol[nik] = {
        "nik": nik,
        "nama": gv(row.get("NAMA")),
        "no_kk": fix_nik(row.get("NOMOR KK")) if "NOMOR KK" in row.index else None,
        "jenis_kelamin": map_jk(row.get("JENIS KELAMIN")),
        "tempat_lahir": gv(row.get("TEMPAT LAHIR")),
        "tanggal_lahir": parse_date(row.get("TANGGAL LAHIR")),
        "agama": map_dusun(row.get("AGAMA")),
        "pendidikan": gv(row.get("PENDIDIKAN DALAM KK")),
        "pekerjaan": gv(row.get("PEKERJAAN")),
        "status_perkawinan": map_sk(row.get("STATUS PERKAWINAN")),
        "hubungan_kk": map_hub(row.get("HUBUNGAN DALAM KK")),
        "kewarganegaraan": gv(row.get("KEWARGANEGARAAN"), "WNI"),
        "nama_ayah": gv(row.get("NAMA AYAH")),
        "nama_ibu": gv(row.get("NAMA IBU")),
        "dusun": map_dusun(row.get("DUSUN")),
        "rt": gv(row.get("RT")),
        "rw": gv(row.get("RW")),
        "alamat": "",
        "status": "aktif",
        "sumber": "XLS-KPU-AKTIF",
    }
    dusun_val = konsol[nik]["dusun"]
    rt_val = konsol[nik]["rt"]
    konsol[nik]["alamat"] = f"{dusun_val or ''} RT {rt_val or ''}".strip()

print(f"   Konsol aktif: {sum(1 for r in konsol.values() if r['status']=='aktif')}")

# ====================
# MENINGGAL
# ====================
print("2. PDD MENINGGAL...")
try:
    df_m = pd.read_excel(fp, sheet_name="PDD Meninggal", header=0)
    df_m = df_m[df_m["NIK"].notna()]
    print(f"   Rows: {len(df_m)}")
    for _, row in df_m.iterrows():
        nik = fix_nik(row["NIK"])
        if not nik:
            continue
        konsol[nik] = {
            "nik": nik,
            "nama": gv(row.get("NAMA")),
            "tanggal_lahir": parse_date(row.get("TANGGAL LAHIR")),
            "jenis_kelamin": map_jk(row.get("JENIS KELAMIN")),
            "alamat": gv(row.get("ALAMAT")),
            "dusun": map_dusun(row.get("DUSUN")),
            "status": "meninggal",
            "sumber": "XLS-KPU-MENINGGAL",
        }
except Exception as e:
    print(f"   Error: {e}")

print(f"   Meninggal: {sum(1 for r in konsol.values() if r['status']=='meninggal')}")

# ====================
# PINDAH MASUK
# ====================
print("3. PINDAH MASUK...")
try:
    df_pm = pd.read_excel(fp, sheet_name="Pindah Masuk", header=0)
    df_pm = df_pm[df_pm["NIK"].notna()]
    print(f"   Rows: {len(df_pm)}")
    for _, row in df_pm.iterrows():
        nik = fix_nik(row["NIK"])
        if not nik:
            continue
        konsol[nik] = {
            "nik": nik,
            "nama": gv(row.get("NAMA")),
            "tanggal_lahir": parse_date(row.get("TANGGAL LAHIR")),
            "jenis_kelamin": map_jk(row.get("JENIS KELAMIN")),
            "alamat": gv(row.get("ALAMAT")),
            "dusun": map_dusun(row.get("DUSUN")),
            "status": "pindah_masuk",
            "sumber": "XLS-KPU-PINDAH-MASUK",
        }
except Exception as e:
    print(f"   Error: {e}")

print(f"   Masuk: {sum(1 for r in konsol.values() if r['status']=='pindah_masuk')}")

# ====================
# PINDAH KELUAR
# ====================
print("4. PINDAH KELUAR...")
try:
    df_pk = pd.read_excel(fp, sheet_name="Pindah Keluar", header=0)
    df_pk = df_pk[df_pk["NIK"].notna()]
    print(f"   Rows: {len(df_pk)}")
    for _, row in df_pk.iterrows():
        nik = fix_nik(row["NIK"])
        if not nik:
            continue
        konsol[nik] = {
            "nik": nik,
            "nama": gv(row.get("NAMA")),
            "tanggal_lahir": parse_date(row.get("TANGGAL LAHIR")),
            "jenis_kelamin": map_jk(row.get("JENIS KELAMIN")),
            "alamat": gv(row.get("ALAMAT")),
            "dusun": map_dusun(row.get("DUSUN")),
            "status": "pindah_keluar",
            "sumber": "XLS-KPU-PINDAH-KELUAR",
        }
except Exception as e:
    print(f"   Error: {e")

print(f"   Keluar: {sum(1 for r in konsol.values() if r['status']=='pindah_keluar')}")

# ====================
# SUMMARY
# ====================
counts = {}
for rec in konsol.values():
    s = rec["status"]
    counts[s] = counts.get(s, 0) + 1

print()
print("=" * 50)
print("KONSOLIDASI SUMMARY")
print("=" * 50)
for s in sorted(counts):
    print(f"  {s:20s}: {counts[s]}")
print(f"  {'TOTAL':20s}: {len(konsol)}")

# ====================
# VALIDATION SAMPLES
# ====================
print()
print("Sample AKTIF (3):")
for nik, rec in list(konsol.items())[:3]:
    print(f"  {nik} | {rec['nama']} | {rec.get('dusun') or ''}")

# ====================
# SAVE
# ====================
out = "penduduk_konsolidasi.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(konsol, f, ensure_ascii=False, indent=2)
print(f"\nSaved: {out}")
print("Done")
