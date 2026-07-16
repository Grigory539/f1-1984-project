# scripts/extract.py

import pandas as pd
import requests
import os
import time

# Указываем базовый URL для сезона 1984 года
BASE_URL = "https://www.statsf1.com/en/1984"

# Создаем словарь с ссылками на нужные страницы
URLS = {
    "drivers": f"{BASE_URL}/pilotes.aspx",
    "season_report": f"{BASE_URL}/bilan.aspx",
    "grille_position": f"{BASE_URL}/grille.aspx",
    "laps_led_stats": f"{BASE_URL}/stats-tour-en-tete.aspx",
    "laps_raced_stats": f"{BASE_URL}/stats-tour-parcouru.aspx"
}

# Создаем папку для сырых данных, если ее нет
os.makedirs("data/raw", exist_ok=True)

# Функция дла скачивания таблицы с сайта и сохранения в CSV
def extract_table(url, filename):
    print(f"Скачиваем данные: {filename}...")

    try:
        # 1 Делаем GET запрос к сайту
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        response =  requests.get(url, headers=headers, timeout=10)

        # Проверяем, что запрос прошел успешно
        if response.status_code != 200:
            print(f"Ошибка! Код ответа: {response.status_code}")
            return
        
        # 2 Парсим HTML и ищем таблицы с помощью pandas
        all_tables = pd.read_html(response.text)

        total_tables = len(all_tables)
        print(f"Найдено таблиц: {total_tables}")

        # Если таблица одна
        if total_tables == 1:
            df = all_tables[0]
            filepath = f"data/raw/{filename}.csv"
            df.to_csv(filepath, index=False, encoding='utf-8')
            print(f"Сохранено: {filepath} ({len(df)} строк)")
        
        # Если таблиц несколько - сохраняем каждую с индексом
        else:
            for i, df in enumerate(all_tables):
                # Универсальное имя: filename_table_0, filename_table_1, ...
                filepath = f"data/raw/{filename}_table_{i}.csv"

                df.to_csv(filepath, index=False, encoding='utf-8')
                print(f"Таблица {i+1}/{total_tables}: {filepath} ({len(df)} строк)")

    except Exception as e:
        print(f"Ошибка при скачивании {filename}: {e}")

# Главная часть скрипта

print("Начинаем извлечение данных для сезона 1984 года...")

# Проходимся по нашему словарю URL, и скачиваем каждую таблицу
for name, url in URLS.items():
    extract_table(url, name)
    # Делаем паузу 2 секунды, чтобы не спамить запросами сайт
    time.sleep(2)

print("Готово! Все данные сохранены в data/raw/")
