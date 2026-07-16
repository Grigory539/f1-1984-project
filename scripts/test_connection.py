# scripts/test_connection.py

import psycopg2

print("Тестируем подключение к PostgreSQL...")

try:
    conn = psycopg2.connect("host=localhost dbname=f1_1984 user=postgres password=postgres123")
    print("✓ Подключение успешно!")
    
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM staging_grid_position")
    count = cur.fetchone()[0]
    
    print(f"✓ В таблице staging_grid_position: {count} строк")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"✗ Ошибка: {e}")