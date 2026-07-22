import pandas as pd
import json
from datetime import datetime

fp = "E:/Seruni.id/docs/Data Penduduk KPU 2022 - Seruni Mumbul.xls"

DUSUN_MAP = {"MANDAR": "Seruni Barat", "DAMES": "Seruni Timur", "SASAK": "Mumbul Utara", "BRANGTAPEN ASRI": "Mumbul Selatan"}
JK_MAP = {"L": "L", "P": "P"}
HUB_MAP = {"KEPALA KELUARGA": "Kepala Keluarga", "ISTRI": "Istri/Suami", "ANAK": "Anak", "FAMILI LAIN": "Famili Lain", "MERTUA": "Mertua"}

def fix_nik(v):
    if v is None: return None
    s = str(v).strip().replace(" ", "")
    for old, new in [("OOOO", "0000"), ("OOO", "000"), ("OO", "00")]:
        while old in s: s = s.replace(old, new)
    s = "".join(c for c in s if c.isdigit() or c == "X")
    if len(s) == 16: return s
    return None

def parse_date(v):
    if v is None: return None
    if isinstance(v, datetime): return v.strftime("%Y-%m-%d")
    s = str(v).strip()
    if "/" in s:
        try:
            p = s.split("/")
            return f"{p[2][:4]}-{p[1].zfill(2)}-{p[0].zfill(2)}"
        except: pass
    return s[:10] if s else None

def gv(v, default=None):
    if v is None: return default
    s = str(v).strip()
    return default if s in ("", "-", "nan") else s

def dusun(s):
    return DUSUN_MAP.get(gv(s, "").upper(), gv(s))

def find_hdr(df, keyword, max_r=12):
    for i in range(min(max_r, len(df)):
        if keyword.upper() in [str(v).upper() for v in df.iloc[i].tolist()]:
            return i
    return None

def parse_sheet(sheet_name, nik_col=2):
    df = pd.read_excel(fp, sheet_name=sheet_name, header=None)
    hdr = find_hdr(df, "NIK")
    if hdr is None: return []
    df.columns = range(len(df.columns))
    data = df.iloc[hdr+1:].dropna(subset=[df.columns[nik_col]])
    result = []
    for _, row in data.iterrows():
        nik = fix_nik(row.iloc[nik_col] if nik_col < len(row) else None)
        if nik: result.append((nik, row))
    return result

konsol = {}

print("AKTIF...")
rows = parse_sheet("DATA PENDUDUK")
print(f"  {len(rows)} rows")
for nik, row in rows:
    if nik in konsol: continue
    konsol[nik] = {
        "nik": nik, "nama": gv(row.iloc[3]), "no_kk": fix_nik(row.iloc[1]),
        "jenis_kelamin": JK_MAP.get(gv(row.iloc[5], "").upper(), gv(row.iloc[5])),
        "tempat_lahir": gv(row.iloc[6]), "tanggal_lahir": parse_date(row.iloc[7]),
        "pendidikan": gv(row.iloc[10]), "pekerjaan": gv(row.iloc[11]),
        "status_perkawinan": gv(row.iloc[12]), "hubungan_kk": HUB_MAP.get(gv(row.iloc[13], "").upper(), gv(row.iloc[13])),
        "agama": dusun(row.iloc[9]), "kewarganegaraan": gv(row.iloc[14], "WNI"),
        "nama_ayah": gv(row.iloc[15]), "nama_ibu": gv(row.iloc[16]),
        "dusun": dusun(row.iloc[20]), "rt": gv(row.iloc[18]), "rw": gv(row.iloc[19]),
        "alamat": f"{dusun(row.iloc[20]) or ''} RT {gv(row.iloc[18]) or ''}".strip(),
        "status": "aktif", "sumber": "XLS-KPU-AKTIF"
    }
print(f"  aktif: {sum(1 for r in konsol.values() if r['status']=='aktif')}")

print("MENINGGAL...")
rows = parse_sheet("PDD Meninggal")
print(f"  {len(rows)} rows")
for nik, row in rows:
    konsol[nik] = {
        "nik": nik, "nama": gv(row.iloc[3]), "tempat_lahir": gv(row.iloc[4]),
        "tanggal_lahir": parse_date(row.iloc[5]), "jenis_kelamin": JK_MAP.get(gv(row.iloc[6], "").upper(), gv(row.iloc[6])),
        "alamat": gv(row.iloc[7]), "dusun": dusun(row.iloc[9]),
        "status": "meninggal", "sumber": "XLS-KPU-MENINGGAL"
    }
print(f"  meninggal: {sum(1 for r in konsol.values() if r['status']=='meninggal')}")

print("PINDAH MASUK...")
rows = parse_sheet("Pindah Masuk")
print(f"  {len(rows)} rows")
for nik, row in rows:
    konsol[nik] = {
        "nik": nik, "nama": gv(row.iloc[3]), "tempat_lahir": gv(row.iloc[4]),
        "tanggal_lahir": parse_date(row.iloc[5]), "jenis_kelamin": JK_MAP.get(gv(row.iloc[6], "").upper(), gv(row.iloc[6])),
        "alamat": gv(row.iloc[7]), "dusun": dusun(row.iloc[9]),
        "status": "pindah_masuk", "sumber": "XLS-KPU-PINDAH-MASUK"
    }
print(f"  masuk: {sum(1 for r in konsol.values() if r['status']=='pindah_masuk')}")

print("PINDAH KELUAR...")
rows = parse_sheet("Pindah Keluar")
print(f"  {len(rows)} rows")
for nik, row in rows:
    konsol[nik] = {
        "nik": nik, "nama": gv(row.iloc[3]), "tempat_lahir": gv(row.iloc[4]),
        "tanggal_lahir": parse_date(row.iloc[5]), "jenis_kelamin": JK_MAP.get(gv(row.iloc[6], "").upper(), gv(row.iloc[6])),
        "alamat": gv(row.iloc[7]), "dusun": dusun(row.iloc[9]),
        "status": "pindah_keluar", "sumber": "XLS-KPU-PINDAH-KELUAR"
    }
print(f"  keluar: {sum(1 for r in konsol.values() if r['status']=='pindah_keluar')}")

counts = {}
for r in konsol.values():
    s = r["status"]; counts[s] = counts.get(s, 0) + 1
print("\nSUMMARY:")
for st, ct in sorted(counts.items()): print(f"  {st}: {ct}")
print(f"  TOTAL: {len(konsol)}")

out = "E:/Seruni.id/docs/penduduk_konsolidasi.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(konsol, f, ensure_ascii=False, indent=2)
print(f"\nSaved: {out}")
