# scripts/load_pilots.py

import pandas as pd
import psycopg2

print("Загружаем pilots...")

# Читаем CSV
df = pd.read_csv("data/raw/drivers.csv")

# Заменяем "-" на NULL
df = df.replace('-', None)

# Подключаемся
conn = psycopg2.connect("host=localhost dbname=f1_1984 user=postgres password=postgres123")
cur = conn.cursor()

# Очищаем таблицу
cur.execute("TRUNCATE TABLE staging_pilots RESTART IDENTITY")

# Вставляем данные
for _, row in df.iterrows():
    cur.execute("""
        INSERT INTO staging_pilots (pilot_name, chassis, engine, best_result, best_grid_position)
        VALUES (%s, %s, %s, %s, %s)
    """, (
        row.get('Driver'),
        row.get('Chassis'),
        row.get('Engine'),
        row.get('Best result'),
        row.get('Best grid position')
    ))

conn.commit()
cur.close()
conn.close()

print("Загружено", len(df), "строк")