import pandas as pd
import csv
import os
from datetime import datetime

FP_XLS = "E:/Seruni.id/docs/Data Penduduk GPU 2022 - Seruni Mumbul.xls".replace("GPU","KPU")
FP_CSV = "E:/Seruni.id/docs/penduduk.csv"
FP_OUT  = "E:/Seruni.id/docs/penduduk_konsolidasi_2022.csv"

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

print("Loading CSV...")
csv_niks = set()
csv_data = {}
with open(FP_CSV, "r", encoding="utf-8-sig") as f:
    for row in csv.DictReader(f):
        nik = str(row.get("NIK","")).strip()
        if len(nik)==16 and nik.isdigit():
            csv_niks.add(nik)
            csv_data[nik] = row
print(f"  CSV: {len(csv_niks)}")

nik_sheets = {}
def track(nik, sheet):
    if nik not in nik_sheets: nik_sheets[nik] = set()
    nik_sheets[nik].add(sheet)

print("Loading AKTIF...")
df_a = pd.read_excel(FP_XLS, sheet_name="DATA PENDUDUK", header=None)
aktif = {}
for _, row in df_a.iloc[2:].iterrows():
    nik = fix_nik(row.iloc[1] if len(row)>1 else None)
    if not nik or nik in aktif: continue
    track(nik, "aktif")
    dusun = map_dusun(row.iloc[4] if len(row)>4 else None)
    rt = gv(row.iloc[3] if len(row)>3 else None)
    aktif[nik] = {"nik":nik,"nama":gv(row.iloc[2]),"no_kk":fix_nik(row.iloc[9] if len(row)>9 else None),"jk":map_jk(row.iloc[7] if len(row)>7 else None),"tl":gv(row.iloc[5]),"tgl":parse_date(row.iloc[6] if len(row)>6 else None),"agama":gv(row.iloc[8]),"pend":gv(row.iloc[10]),"pek":gv(row.iloc[11]),"skaw":map_status(row.iloc[12] if len(row)>12 else None),"hub":map_hub(row.iloc[13] if len(row)>13 else None),"kwn":gv(row.iloc[14] if len(row)>14 else None,"WNI"),"ayah":gv(row.iloc[15] if len(row)>15 else None),"ibu":gv(row.iloc[16] if len(row)>16 else None),"dusun":dusun,"rt":rt,"rw":gv(row.iloc[18] if len(row)>18 else None),"alamat":dusun or ""}
print(f"  AKTIF: {len(aktif)}")

print("Loading MENINGGAL...")
meninggal = {}
df_m = pd.read_excel(FP_XLS, sheet_name="PDD Meninggal", header=None)
for _, row in df_m.iloc[9:].iterrows():
    nik = fix_nik(row.iloc[2] if len(row)>2 else None)
    if not nik or nik in meninggal: continue
    track(nik, "meninggal")
    meninggal[nik] = {"nik":nik,"nama":gv(row.iloc[3]),"jk":map_jk(row.iloc[6] if len(row)>6 else None),"tl":gv(row.iloc[4]),"tgl":parse_date(row.iloc[5] if len(row)>5 else None),"alamat":gv(row.iloc[7]),"dusun":map_dusun(row.iloc[9] if len(row)>9 else None)}
print(f"  MENINGGAL: {len(meninggal)}")

print("Loading PINDAH MASUK...")
pmasuk = {}
df_pm = pd.read_excel(FP_XLS, sheet_name="Pindah Masuk", header=None)
for _, row in df_pm.iloc[9:].iterrows():
    nik = fix_nik(row.iloc[2] if len(row)>2 else None)
    if not nik or nik in pmasuk: continue
    track(nik, "pindah_masuk")
    pmasuk[nik] = {"nik":nik,"nama":gv(row.iloc[3]),"jk":map_jk(row.iloc[6] if len(row)>6 else None),"tl":gv(row.iloc[4]),"tgl":parse_date(row.iloc[5] if len(row)>5 else None),"alamat":gv(row.iloc[7]),"dusun":map_dusun(row.iloc[8] if len(row)>8 else None)}
print(f"  PINDAH_MASUK: {len(pmasuk)}")

print("Loading PINDAH KELUAR...")
pkeluar = {}
df_pk = pd.read_excel(FP_XLS, sheet_name="Pindah Keluar", header=None)
for _, row in df_pk.iloc[9:].iterrows():
    nik = fix_nik(row.iloc[2] if len(row)>2 else None)
    if not nik or nik in pkeluar: continue
    track(nik, "pindah_keluar")
    pkeluar[nik] = {"nik":nik,"nama":gv(row.iloc[3]),"jk":map_jk(row.iloc[6] if len(row)>6 else None),"tl":gv(row.iloc[4]),"tgl":parse_date(row.iloc[5] if len(row)>5 else None),"alamat":gv(row.iloc[7]),"dusun":map_dusun(row.iloc[8] if len(row)>8 else None)}
print(f"  PINDAH_KELUAR: {len(pkeluar)}")

def get_status(nik):
    sheets = nik_sheets.get(nik, set())
    if "meninggal" in sheets: return "meninggal"
    if "pindah_keluar" in sheets: return "pindah_keluar"
    if "aktif" in sheets: return "aktif"
    if "pindah_masuk" in sheets: return "pindah_masuk"
    return "aktif"

def gpu_csv(rec, status):
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

print()
print("Building output...")
output = []
processed_niks = set()
removed_meni = 0
removed_pkeluar = 0

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
    processed_niks.add(nik)

added_aktif = 0
for nik, rec in aktif.items():
    if nik not in processed_niks:
        output.append(gpu_csv(rec, "aktif"))
        processed_niks.add(nik)
        added_aktif += 1

added_pmasuk = 0
for nik, rec in pmasuk.items():
    if nik not in processed_niks:
        output.append(gpu_csv(rec, "pindah_masuk"))
        processed_niks.add(nik)
        added_pmasuk += 1

added_meni = 0
for nik, rec in meninggal.items():
    if nik not in processed_niks:
        output.append(gpu_csv(rec, "meninggal"))
        processed_niks.add(nik)
        added_meni += 1

print(f"  Kept from CSV: {len(output)}")
print(f"  Removed (meninggal): {removed_meni}")
print(f"  Removed (pindah keluar): {removed_pkeluar}")
print(f"  Added aktif: {added_aktif}")
print(f"  Added pindah_masuk: {added_pmasuk}")
print(f"  Added meninggal baru: {added_meni}")
print(f"  TOTAL: {len(output)}")

print()
print("Writing output...")
for row in output:
    if "STATUS_PENDUDUK" not in row: row["STATUS_PENDUDUK"] = ""
all_cols = CSV_COLS + ["STATUS_PENDUDUK"]
with open(FP_OUT, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.DictWriter(f, fieldnames=all_cols, extrasaction="ignore")
    w.writeheader()
    w.writerows(output)
print(f"  Written: {FP_OUT}")

ts = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = f"E:/Seruni.id/docs/penduduk_backup_{ts}.csv"
with open(FP_CSV, "r", encoding="utf-8-sig") as src:
    with open(backup, "w", encoding="utf-8-sig") as dst:
        dst.write(src.read())
print(f"  Backup: {backup}")

print()
print("="*50)
print("SUMMARY")
print("="*50)
sc = {}
for row in output:
    s = row.get("STATUS_PENDUDUK","unknown")
    sc[s] = sc.get(s,0)+1
for s,c in sorted(sc.items()): print(f"  {s}: {c}")
print(f"  TOTAL: {len(output)}")
print()
print(f"  CSV original: {len(csv_niks)}")
print(f"  Removed (meninggal): {removed_meni}")
print(f"  Removed (pindah keluar): {removed_pkeluar}")
print(f"  Added (aktif baru): {added_aktif}")
print(f"  Added (pindah masuk baru): {added_pmasuk}")
print(f"  Added (meninggal baru): {added_meni}")
print(f"  Net: {len(output) - len(csv_niks)}")
print()
print("Done!")
