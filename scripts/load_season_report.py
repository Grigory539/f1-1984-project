# scripts/load_season_report.py

import pandas as pd
import psycopg2

print("Загружаем season_report...")

# Читаем CSV
df = pd.read_csv("data/raw/season_report.csv")

# Заменяем "-" на NULL
df = df.replace('-', None)

# Подключаемся
conn = psycopg2.connect("host=localhost dbname=f1_1984 user=postgres password=postgres123")
cur = conn.cursor()

# Очищаем таблицу
cur.execute("TRUNCATE TABLE staging_races_result RESTART IDENTITY")

# Вставляем данные
for _, row in df.iterrows():
    cur.execute("""
        INSERT INTO staging_races_result (
            pilot_name, brazil, south_africa, belgium, san_marino, france,
            monaco, canada, detroit, dallas, britain, deutschland,
            austria, netherlands, italy, euro, portugal)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        row.get('Drivers'),
        row.get('1 BRA'),
        row.get('2 ZAF'),
        row.get('3 BEL'),
        row.get('4 SMR'),
        row.get('5 FRA'),
        row.get('6 MCO'),
        row.get('7 CAN'),
        row.get('8 DET'),
        row.get('9 DAL'),
        row.get('10 GBR'),
        row.get('11 DEU'),
        row.get('12 AUT'),
        row.get('13 NLD'),
        row.get('14 ITA'),
        row.get('15 EUR'),
        row.get('16 PRT')
    ))

conn.commit()
cur.close()
conn.close()

print("Загружено", len(df), "строк")