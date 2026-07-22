import pandas as pd
import json
import os

os.chdir("E:/Seruni.id/docs")
fp = "Data Penduduk KPU 2022 - Seruni Mumbul.xls"

print("Loading DATA PENDUDUK...")
df = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=0)
nik_col = "NIK"
print("Columns:", nik_col in df.columns)
print("Shape:", df.shape)
print("Sample NIKs:", df["NIK"].head(3).tolist())
