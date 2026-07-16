# scripts/load_laps_raced_stats_pilots.py

import pandas as pd
import psycopg2

print("Загружаем laps_raced_stats_table_0...")

# Читаем CSV
df = pd.read_csv("data/raw/laps_raced_stats_table_0.csv")

# Заменяем "-" на NULL
df = df.replace('-', None)

# Подключаемся
conn = psycopg2.connect("host=localhost dbname=f1_1984 user=postgres password=postgres123")
cur = conn.cursor()

# Очищаем таблицу
cur.execute("TRUNCATE TABLE staging_laps_raced_pilots RESTART IDENTITY")

# Вставляем данные
for _, row in df.iterrows():
    cur.execute("""
        INSERT INTO staging_laps_raced_pilots (pilot_name, laps_raced, percentage)
        VALUES (%s, %s, %s)
    """, (
        row.get('1'),
        row.get('2'),
        row.get('3')
    ))

conn.commit()
cur.close()
conn.close()

print("Загружено", len(df), "строк")