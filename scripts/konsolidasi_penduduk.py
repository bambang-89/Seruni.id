import pandas as pd
import json
from datetime import datetime

# ---- maps ----
JK_MAP = {"L": "L", "P": "P"}
HUB_MAP = {
    "KEPALA KELUARGA": "Kepala Keluarga",
    "ISTRI": "Istri/Suami",
    "SUAMI": "Istri/Suami",
    "ANAK": "Anak",
    "FAMILI LAIN": "Famili Lain",
    "MERTUA": "Mertua",
}
STATUS_KAWIN = {
    "BELUM KAWIN": "Belum Kawin",
    "KAWIN": "Kawin",
    "CERAI HIDUP": "Cerai Hidup",
    "CERAI MATI": "Cerai Mati",
}
AGAMA_MAP = {
    "ISLAM": "Islam",
    "KRISTEN": "Kristen",
    "KATHOLIK": "Katolik",
    "HINDU": "Hindu",
    "BUDHA": "Buddha",
    "KHONGHUCU": "Khonghucu",
}
DUSUN_MAP = {
    "MANDAR": "Seruni Barat",
    "DAMES": "Seruni Timur",
    "SASAK": "Mumbul Utara",
    "BRANGTAPEN ASRI": "Mumbul Selatan",
}

def fix_nik(val):
    if val is None:
        return None
    s = str(val).strip()
    if not s or s.lower() in ("nan", ""):
        return None
    s = s.replace(" ", "")
    # fix OCR errors
    while "OOOO" in s: s = s.replace("OOOO", "0000")
    while "OOO" in s: s = s.replace("OOO", "000")
    while "OO" in s: s = s.replace("OO", "00")
    s = "".join(c for c in s if c.isdigit())
    if len(s) == 16:
        return s
    return None

def parse_date(val):
    if val is None: return None
    if isinstance(val, datetime):
        return val.strftime("%Y-%m-d")
    s = str(val).strip()
    if not s or s.lower() in ("nan", "nat"): return None
    if "/" in s:
        parts = s.split("/")
        if len(parts) == 3:
            try:
                return f"{parts[2][:4]}-{parts[1].zfill(2)}-{parts[0].zfill(2)}"
            except: pass
    if "-" in s:
        return s[:10]
    return None

def get_v(val, default=None):
    if val is None: return default
    s = str(val).strip()
    if s in ("", "-", "nan", "NaN", "None"): return default
    return s

def normalize(s, default=None):
    if not s: return default
    upper = s.upper()
    return HUB_MAP.get(upper, s) if "HUBUNGAN" in upper or upper in HUB_MAP else JK_MAP.get(upper, AGAMA_MAP.get(upper, DUSUN_MAP.get(upper, s))

# ---- helper: find header row ----
def find_header(df, keyword, max_row=12):
    for i in range(min(max_row, len(df)):
        vals = [str(v).upper() for v in df.iloc[i].tolist()]
        if keyword in vals:
            return i
    return None

# ---- parse sheet ----
def parse_sheet(fp, sheet, nik_col=2):
    try:
        df = pd.read_excel(fp, sheet_name=sheet, header=None)
    except Exception as e:
        print(f"  ERROR {sheet}: {e}")
        return []
    hdr = find_header(df, "NIK")
    if hdr is None:
        print(f"  WARN no NIK header in {sheet}")
        return []
    df.columns = range(len(df.columns))
    data = df.iloc[hdr + 1:].dropna(subset=[hdr if hdr < len(df.columns) else None])
    result = []
    for _, row in data.iterrows():
        nik = fix_nik(row.iloc[nik_col] if nik_col < len(row) else None)
        if nik:
            result.append((nik, row))
    return result

# ---- main ----
fp = "E:/Seruni.id/docs/Data Penduduk KPU 2022 - Seruni Mumbul.xls"
print("Loading Excel...")
xls = pd.ExcelFile(fp)
print(f"Sheets: {xls.sheet_names}")

konsol = {}  # nik -> record

# AKTIF
print("Parsing DATA PENDUDUK...")
rows = parse_sheet(fp, "DATA PENDUDUK", nik_col=2)
print(f"  {len(rows)} rows")
for nik, row in rows:
    if nik in konsol:
        continue
    jk = get_v(row.iloc[5] if len(row) > 5 else None, "")
    agama_raw = get_v(row.iloc[9] if len(row) > 9 else None, "")
    hubungan_raw = get_v(row.iloc[12] if len(row) > 12 else None, "")
    dusun_raw = get_v(row.iloc[20] if len(row) > 20 else None, "")
    no_kk = fix_nik(row.iloc[1] if len(row) > 1 else None)
    dusun_norm = DUSUN_MAP.get(dusun_raw.upper(), dusun_raw) if dusun_raw else None

    konsol[nik] = {
        "nik": nik,
        "nama": get_v(row.iloc[3] if len(row) > 3 else None),
        "no_kk": no_kk,
        "jenis_kelamin": JK_MAP.get(jk.upper(), jk) if jk else None,
        "tempat_lahir": get_v(row.iloc[6] if len(row) > 6 else None),
        "tanggal_lahir": parse_date(row.iloc[7] if len(row) > 7 else None),
        "pendidikan": get_v(row.iloc[10] if len(row) > 10 else None),
        "pekerjaan": get_v(row.iloc[11] if len(row) > 11 else None),
        "status_perkawinan": STATUS_KAWIN.get(get_v(row.iloc[12], "").upper(), get_v(row.iloc[12])),
        "hubungan_kk": HUB_MAP.get(hubungan_raw.upper(), hubungan_raw) if hubungan_raw else None,
        "agama": AGAMA_MAP.get(agama_raw.upper(), agama_raw) if agama_raw else None,
        "kewarganegaraan": get_v(row.iloc[14] if len(row) > 14 else None, "WNI"),
        "nama_ayah": get_v(row.iloc[15] if len(row) > 15 else None),
        "nama_ibu": get_v(row.iloc[16] if len(row) > 16 else None),
        "dusun": dusun_norm,
        "rt": get_v(row.iloc[18] if len(row) > 18 else None),
        "rw": get_v(row.iloc[19] if len(row) > 19 else None),
        "alamat": f"{dusun_norm or ''} RT {get_v(row.iloc[18] if len(row) > 18 else None) or ''}".strip(),
        "status": "aktif",
        "sumber": "XLS-KPU-AKTIF",
    }
print(f"  Aktif: {sum(1 for r in konsol.values() if r['status']=='aktif')}")

# MENINGGAL
print("Parsing PDD Meninggal...")
rows = parse_sheet(fp, "PDD Meninggal", nik_col=2)
print(f"  {len(rows)} rows")
for nik, row in rows:
    konsol[nik] = {
        "nik": nik,
        "nama": get_v(row.iloc[3] if len(row) > 3 else None),
        "tempat_lahir": get_v(row.iloc[4] if len(row) > 4 else None),
        "tanggal_lahir": parse_date(row.iloc[5] if len(row) > 5 else None),
        "jenis_kelamin": JK_MAP.get(get_v(row.iloc[6], "").upper(), get_v(row.iloc[6])),
        "alamat": get_v(row.iloc[7] if len(row) > 7 else None),
        "dusun": DUSUN_MAP.get(get_v(row.iloc[9], "").upper(), get_v(row.iloc[9])) if len(row) > 9 else None,
        "status": "meninggal",
        "sumber": "XLS-KPU-MENINGGAL",
    }
print(f"  Meninggal: {sum(1 for r in konsol.values() if r['status']=='meninggal')}")

# PINDAH MASUK
print("Parsing Pindah Masuk...")
rows = parse_sheet(fp, "Pindah Masuk", nik_col=2)
print(f"  {len(rows)} rows")
for nik, row in rows:
    konsol[nik] = {
        "nik": nik,
        "nama": get_v(row.iloc[3] if len(row) > 3 else None),
        "tempat_lahir": get_v(row.iloc[4] if len(row) > 4 else None),
        "tanggal_lahir": parse_date(row.iloc[5] if len(row) > 5 else None),
        "jenis_kelamin": JK_MAP.get(get_v(row.iloc[6], "").upper(), get_v(row.iloc[6])),
        "alamat": get_v(row.iloc[7] if len(row) > 7 else None),
        "dusun": DUSUN_MAP.get(get_v(row.iloc[9], "").upper(), get_v(row.iloc[9])) if len(row) > 9 else None,
        "status": "pindah_masuk",
        "sumber": "XLS-KPU-PINDAH-MASUK",
    }
print(f"  Masuk: {sum(1 for r in konsol.values() if r['status']=='pindah_masuk')}")

# PINDAH KELUAR
print("Parsing Pindah Keluar...")
rows = parse_sheet(fp, "Pindah Keluar", nik_col=2)
print(f"  {len(rows)} rows")
for nik, row in rows:
    konsol[nik] = {
        "nik": nik,
        "nama": get_v(row.iloc[3] if len(row) > 3 else None),
        "tempat_lahir": get_v(row.iloc[4] if len(row) > 4 else None),
        "tanggal_lahir": parse_date(row.iloc[5] if len(row) > 5 else None),
        "jenis_kelamin": JK_MAP.get(get_v(row.iloc[6], "").upper(), get_v(row.iloc[6])),
        "alamat": get_v(row.iloc[7] if len(row) > 7 else None),
        "dusun": DUSUN_MAP.get(get_v(row.iloc[9], "").upper(), get_v(row.iloc[9])) if len(row) > 9 else None,
        "status": "pindah_keluar",
        "sumber": "XLS-KPU-PINDAH-KELUAR",
    }
print(f"  Keluar: {sum(1 for r in konsol.values() if r['status']=='pindah_keluar')}")

# ---- summary ----
counts = {}
for r in konsol.values():
    s = r["status"]
    counts[s] = counts.get(s, 0) + 1
print("\n" + "=" * 40)
print("SUMMARY KONSOLIDASI")
print("=" * 40)
for status in sorted(counts):
    print(f"  {status:20s}: {counts[status]}")
print(f"  {'TOTAL':20s}: {len(konsol)}")

# ---- save ----
out_path = "E:/Seruni.id/docs/penduduk_konsolidasi.json"
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(konsol, f, ensure_ascii=False, indent=2)
print(f"\nSaved: {out_path}")
print("Done!")
