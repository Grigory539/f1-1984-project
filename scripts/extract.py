# scripts/extract.py

import pandas as pd
import requests
import os
import time

# Указываем базовый URL для сезона 1984 года
BASE_URL = "https://www.statsf1.com/en/1984"

# Создаём словарь с ссылками на нужные страницы
URLS = {
    "drivers": f"{BASE_URL}/pilotes.aspx",
    "season_report": f"{BASE_URL}/bilan.aspx",
    "wins_stats": f"{BASE_URL}/stats-victoire.aspx",
    "pole_stats": f"{BASE_URL}/stats-pole.aspx",
    "fastest_lap_stats": f"{BASE_URL}/stats-meilleur-tour.aspx",
    "laps_led_stats": f"{BASE_URL}/stats-tour-en-tete.aspx"
}

# Создаём папку для сырых данных, если её нет
os.makedirs("data/raw", exist_ok=True)

def extract_table(url, filename):
    """
    Функция для скачивания таблицы с сайта и сохранения в CSV.
    """
    print(f"Скачиваем данные: {filename}...")
    
    try:
        # 1. Делаем GET-запрос к сайту
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        response = requests.get(url, headers=headers, timeout=10)
        
        # Проверяем, что запрос прошёл успешно
        if response.status_code != 200:
            print(f"Ошибка! Код ответа: {response.status_code}")
            return
        
        # 2. Парсим HTML и ищем таблицы с помощью pandas
        tables = pd.read_html(response.text)
        
        # Проверяем, что таблицы найдены
        if not tables:
            print(f"Таблицы не найдены на странице {filename}")
            return
        
        # 3. Берём первую таблицу
        df = tables[0]
        
        # 4. Сохраняем в CSV
        filepath = f"data/raw/{filename}.csv"
        df.to_csv(filepath, index=False, encoding='utf-8')
        
        print(f"Успешно сохранено в {filepath}! Строк: {len(df)}")
        
    except Exception as e:
        print(f"Ошибка при скачивании {filename}: {e}")

# === ГЛАВНАЯ ЧАСТЬ СКРИПТА ===

print("Начинаем извлечение данных для сезона 1984 года...")

# Проходимся по нашему словарю URL и скачиваем каждую таблицу
for name, url in URLS.items():
    extract_table(url, name)
    # Делаем паузу 2 секунды, чтобы не спамить запросами на сайт
    time.sleep(2) 

print("Готово! Все данные сохранены в data/raw/")
