import pandas as pd
import json
import os

os.chdir("E:/Seruni.id/docs")
fp = "Data Penduduk KPU 2022 - Seruni Mumbul.xls"

DUSUN = {"MANDAR": "Seruni Barat", "DAMES": "Seruni Timur", "SASAK": "Mumbul Utara", "BRANGTAPEN ASRI": "Mumbul Selatan"}
JK = {"LAKI-LAKI": "L", "LAKI": "L", "P": "P"}
HUB = {"KEPALA KELUARGA": "Kepala Keluarga", "ISTRI": "Istri/Suami", "ANAK": "Anak", "FAMILI LAIN": "Famili Lain"}

def fix_nik(v):
    if v is None: return None
    s = str(v).strip().replace(" ", "")
    s = s.replace("OOOO", "0000").replace("OOO", "000").replace("OO", "00")
    s = "".join(c for c in s if c.isdigit())
    return s if len(s) == 16 else None

def pdate(v):
    if v is None: return None
    if hasattr(v, "strftime"): return v.strftime("%Y-%m-%d")
    s = str(v).strip()
    if not s or s.lower() == "nan": return None
    return s[:10]

def gv(v, default=None):
    if v is None: return default
    s = str(v).strip()
    return default if s in ("", "-", "nan", "NaN") else s

def dusun(v):
    if v is None: return None
    u = str(v).upper().strip()
    return DUSUN.get(u, gv(v))

def jk(v):
    if v is None: return None
    u = str(v).upper().strip()
    return JK.get(u, u)

def hub(v):
    if v is None: return None
    u = str(v).upper().strip()
    return HUB.get(u, u)

def skaw(v):
    if v is None: return None
    s = str(v).strip()
    if s.upper() in ("BELUM KAWIN", ""): return "Belum Kawin"
    if s.upper() == "KAWIN": return "Kawin"
    return s

konsol = {}

# Sheet: DATA PENDUDUK
# Header row 0, data row 1+
xls = pd.ExcelFile(fp)
print("Parsing AKTIF...")
df = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=0)
nik_col = "NIK"
if nik_col in df.columns:
    df[nik_col] = df[nik_col].astype(str)
    df = df[df[nik_col].notna() & (df[nik_col] != "nan")]
    rows = df[[str(x).isdigit() and len(str(x)) == 16 for x in df[nik_col]]
    print(f"  Found {len(df)} rows with NIK, {len(rows)} valid 16-digit NIK")
else:
    print("  Column NIK not found. Columns:", list(df.columns))
    df = pd.DataFrame()

# For each valid NIK, collect record
for _, row in df.iterrows():
    nik_raw = str(row.get(nik_col, "")).strip()
    nik = fix_nik(nik_raw)
    if not nik or nik in konsol: continue
    konsol[nik] = {"nik": nik, "status": "aktif", "sumber": "XLS-KPU-AKTIF"}
    konsol[nik]["nama"] = gv(row.get("NAMA"))
    no_kk = fix_nik(row.get("NOMOR KK"))
    konsol[nik]["no_kk"] = no_kk
    konsol[nik]["jenis_kelamin"] = jk(row.get("JENIS KELAMIN"))
    konsol[nik]["tempat_lahir"] = gv(row.get("TEMPAT LAHIR"))
    konsol[nik]["tanggal_lahir"] = pdate(row.get("TANGGAL LAHIR"))
    konsol[nik]["agama"] = dusun(row.get("AGAMA"))
    konsol[nik]["pendidikan"] = gv(row.get("PENDIDIKAN"))
    konsol[nik]["pekerjaan"] = gv(row.get("PEKERJAAN"))
    konsol[nik]["status_perkawinan"] = skaw(row.get("STATUS PERKAWINAN"))
    konsol[nik]["hubungan_kk"] = hub(row.get("HUBUNGAN DALAM KK"))
    konsol[nik]["kewarganegaraan"] = gv(row.get("KEWARGANEGARAAN"), "WNI")
    konsol[nik]["nama_ayah"] = gv(row.get("NAMA AYAH"))
    konsol[nik]["nama_ibu"] = gv(row.get("NAMA IBU"))
    dusun_val = dusun(row.get("DUSUN"))
    rt_val = gv(row.get("RT"))
    konsol[nik]["dusun"] = dusun_val
    konsol[nik]["rt"] = rt_val
    konsol[nik]["rw"] = gv(row.get("RW"))
    konsol[nik]["alamat"] = f"{dusun_val or ''} RT {rt_val or ''}".strip()

print(f"  Aktif: {sum(1 for r in konsol.values() if r.get('status') == 'aktif'}")

# Sheet: PDD Meninggal
print("Parsing MENINGGAL...")
for col_name in ["NIK", "NIK Penduduk"]:
    try:
        df_m = pd.read_excel(fp, sheet_name="PDD Meninggal", header=0)
        if col_name in df_m.columns:
            df_m[col_name] = df_m[col_name].astype(str).str.strip()
            break
    except:
        continue

if "NIK" in df_m.columns:
    df_m = df_m[df_m["NIK"].notna()]
    for _, row in df_m.iterrows():
        nik = fix_nik(str(row["NIK"]))
        if not nik: continue
        konsol[nik] = {
            "nik": nik, "status": "meninggal", "sumber": "XLS-MENINGGAL",
            "nama": gv(row.get("NAMA")),
            "tanggal_lahir": pdate(row.get("TANGGAL LAHIR")),
            "dusun": dusun(row.get("DUSUN")),
        }

# Sheet: Pindah Masuk
print("Parsing PINDAH MASUK...")
for col_name in ["NIK", "NIK Penduduk"]:
    try:
        df_pm = pd.read_excel(fp, sheet_name="Pindah Masuk", header=0)
        if col_name in df_pm.columns:
            df_pm[col_name] = df_pm[col_name].astype(str).str.strip()
            break
    except:
        continue

if "NIK" in df_pm.columns:
    df_pm = df_pm[df_pm["NIK"].notna()]
    for _, row in df_pm.iterrows():
        nik = fix_nik(str(row["NIK"]))
        if not nik: continue
        konsol[nik] = {"nik": nik, "status": "pindah_masuk", "sumber": "XLS-PINDAH-MASUK",
                        "nama": gv(row.get("NAMA")), "dusun": dusun(row.get("DUSUN"))}

# Sheet: Pindah Keluar
print("Parsing PINDAH KELUAR...")
try:
    df_pk = pd.read_excel(fp, sheet_name="Pindah Keluar", header=0)
    if "NIK" in df_pk.columns:
        df_pk["NIK"] = df_pk["NIK"].astype(str).str.strip()
        df_pk = df_pk[df_pk["NIK"].notna()]
        for _, row in df_pk.iterrows():
            nik = fix_nik(str(row["NIK"]))
            if not nik: continue
            konsol[nik] = {"nik": nik, "status": "pindah_keluar", "sumber": "XLS-PINDAH-KELUAR",
                            "nama": gv(row.get("NAMA")), "dusun": dusun(row.get("DUSUN"))}
except Exception as e:
    print("  Error:", e)

# Summary
counts = {}
for r in konsol.values():
    s = r.get("status", "unknown")
    counts[s] = counts.get(s, 0) + 1

print()
print("=" * 50)
print("KONSOLIDASI SUMMARY")
print("=" * 50)
for st in sorted(counts): print(" ", st, ":", counts[st])
print("  TOTAL:", len(konsol))

# Save
out = "penduduk_konsolidasi.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(konsol, f, ensure_ascii=False, indent=2)
print("Saved:", out)
print("Done")
