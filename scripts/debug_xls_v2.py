# Analysis script - run directly
import pandas as pd
import csv
import json

fp = r"E:\Seruni.id\docs\Data Penduduk GPU 2022 - Seruni Mumbul.xls"

xls = pd.ExcelFile(fp)
print("Sheets:", xls.sheet_names)
print()

# Try reading AKTIF with named header
try:
    df = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=0)
    print(f"AKTIF header=0 rows: {len(df)}, cols: {list(df.columns)[:10]}")
    print("First row:", list(df.iloc[0].values[:10]))
except Exception as e:
    print(f"header=0 error: {e}")

print()

# Try with no header
df_raw = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=None)
print(f"AKTIF no-header rows: {len(df_raw)}, cols: {len(df_raw.columns)}")
print("Row 0:", list(df_raw.iloc[0].values[:10]))
print("Row 1:", list(df_raw.iloc[1].values[:10]))
print("Row 2:", list(df_raw.iloc[2].values[:10]))

# Find header row
for i in range(5):
    row = df_raw.iloc[i].values
    nik_count = sum(1 for v in row if pd.notna(v) and str(v).strip().isdigit() and len(str(v).strip()) == 16)
    print(f"  Row {i}: NaN count={sum(1 for v in row if pd.isna(v))}, potential NIKs={nik_count}")
