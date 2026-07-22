import pandas as pd
import json
import os
os.chdir("E:/Seruni.id/docs")

fp = "Data Penduduk KPU 2022 - Seruni Mumbul.xls"
print("Testing pandas read...")
xls = pd.ExcelFile(fp)
print("Sheets:", xls.sheet_names)
df = pd.read_excel(fp, sheet_name="DATA PENDUDUK", header=None)
print("Shape:", df.shape)
print("OK")
