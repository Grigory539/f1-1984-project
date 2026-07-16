from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import pandas as pd
from sqlalchemy import create_engine, text


# Настройки DAG
default_args = {
    'owner': 'f1_analytics',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'f1_1984_elt',
    default_args=default_args,
    description='ELT процесс для F1 1984',
    schedule_interval=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['f1', 'elt', '1984'],
)


# Задача 1: Загружаем CSV файлы в базу
def load_csv_files():
    print("Начинаю загрузку CSV файлов...")
    
    # Подключаемся к базе
    engine = create_engine('postgresql+psycopg2://postgres:postgres123@postgres:5432/f1_1984')
    
    # 1. Загружаем drivers.csv
    print("Загружаю drivers.csv...")
    df_drivers = pd.read_csv('/opt/airflow/data/drivers.csv')
    df_drivers = df_drivers.rename(columns={
        'Driver': 'pilot_name',
        'Chassis': 'chassis',
        'Engine': 'engine',
        'Best result': 'best_result',
        'Best grid position': 'best_grid_position'
    })
    df_drivers.to_sql('staging_pilots', engine, if_exists='replace', index=False)
    print('Загружено в staging_pilots:', len(df_drivers), 'строк')
    
    # Добавляем pilot_id в staging_pilots
    with engine.begin() as conn:
        conn.execute(text("ALTER TABLE staging_pilots ADD COLUMN pilot_id SERIAL PRIMARY KEY"))
    
    # 2. Загружаем season_report.csv
    print("Загружаю season_report.csv...")
    df_season = pd.read_csv('/opt/airflow/data/season_report.csv')
    df_season = df_season.replace('-', None)  # Заменяем "-" на NULL
    df_season = df_season.rename(columns={
        'Drivers': 'pilot_name',
        '1 BRA': 'brazil',
        '2 ZAF': 'south_africa',
        '3 BEL': 'belgium',
        '4 SMR': 'san_marino',
        '5 FRA': 'france',
        '6 MCO': 'monaco',
        '7 CAN': 'canada',
        '8 DET': 'detroit',
        '9 DAL': 'dallas',
        '10 GBR': 'britain',
        '11 DEU': 'deutschland',
        '12 AUT': 'austria',
        '13 NLD': 'netherlands',
        '14 ITA': 'italy',
        '15 EUR': 'euro',
        '16 PRT': 'portugal'
    })
    df_season.to_sql('staging_races_result', engine, if_exists='replace', index=False)
    print('Загружено в staging_races_result:', len(df_season), 'строк')
    
    # 3. Загружаем grid_position.csv
    print("Загружаю grid_position.csv...")
    df_grid = pd.read_csv('/opt/airflow/data/grid_position.csv')
    df_grid = df_grid.replace('-', None)  # Заменяем "-" на NULL
    df_grid = df_grid.rename(columns={
        'Drivers': 'pilot_name',
        '1 BRA': 'brazil',
        '2 ZAF': 'south_africa',
        '3 BEL': 'belgium',
        '4 SMR': 'san_marino',
        '5 FRA': 'france',
        '6 MCO': 'monaco',
        '7 CAN': 'canada',
        '8 DET': 'detroit',
        '9 DAL': 'dallas',
        '10 GBR': 'britain',
        '11 DEU': 'deutschland',
        '12 AUT': 'austria',
        '13 NLD': 'netherlands',
        '14 ITA': 'italy',
        '15 EUR': 'euro',
        '16 PRT': 'portugal'
    })
    df_grid.to_sql('staging_grid_position', engine, if_exists='replace', index=False)
    print('Загружено в staging_grid_position:', len(df_grid), 'строк')
    
    # 4. Загружаем laps_led_stats_table_0.csv
    # ВАЖНО: в CSV колонка 0 = индекс, 1 = имя пилота, 2 = laps_lead
    print("Загружаю laps_led_stats_table_0.csv...")
    df_laps_led = pd.read_csv('/opt/airflow/data/laps_led_stats_table_0.csv')
    df_laps_led = df_laps_led.replace('-', None)  # Заменяем "-" на NULL
    df_laps_led = df_laps_led.rename(columns={
        '1': 'pilot_name',    # Имя пилота в колонке 1
        '2': 'laps_lead'      # laps_lead в колонке 2
    })
    # Удаляем колонку 0 (индекс)
    if '0' in df_laps_led.columns:
        df_laps_led = df_laps_led.drop(columns=['0'])
    df_laps_led.to_sql('staging_laps_lead_pilots', engine, if_exists='replace', index=False)
    print('Загружено в staging_laps_lead_pilots:', len(df_laps_led), 'строк')
    
    # 5. Загружаем laps_raced_stats_table_0.csv
    # ВАЖНО: в CSV колонка 0 = индекс, 1 = имя пилота, 2 = laps_raced, 3 = percentage
    print("Загружаю laps_raced_stats_table_0.csv...")
    df_laps_raced = pd.read_csv('/opt/airflow/data/laps_raced_stats_table_0.csv')
    df_laps_raced = df_laps_raced.replace('-', None)  # Заменяем "-" на NULL
    df_laps_raced = df_laps_raced.rename(columns={
        '1': 'pilot_name',    # Имя пилота в колонке 1
        '2': 'laps_raced',    # laps_raced в колонке 2
        '3': 'percentage'     # percentage в колонке 3
    })
    # Удаляем колонку 0 (индекс)
    if '0' in df_laps_raced.columns:
        df_laps_raced = df_laps_raced.drop(columns=['0'])
    df_laps_raced.to_sql('staging_laps_raced_pilots', engine, if_exists='replace', index=False)
    print('Загружено в staging_laps_raced_pilots:', len(df_laps_raced), 'строк')
    
    print("Все CSV файлы загружены!")


# Задача 2: Выполняем SQL трансформации
def run_sql_transform():
    print("Начинаю выполнение SQL трансформаций...")
    
    engine = create_engine('postgresql+psycopg2://postgres:postgres123@postgres:5432/f1_1984')
    
    # Читаем SQL файл
    with open('/opt/airflow/sql/transform.sql', 'r', encoding='utf-8') as f:
        sql_script = f.read()
    
    # Разбиваем на команды по точке с запятой
    statements = sql_script.split(';')
    
    # Выполняем каждую команду
    for stmt in statements:
        stmt = stmt.strip()
        # Пропускаем пустые строки и SELECT (они только для проверки)
        if not stmt or stmt.upper().startswith('SELECT'):
            continue
        
        try:
            with engine.connect().execution_options(isolation_level="AUTOCOMMIT") as conn:
                conn.execute(text(stmt))
        except Exception as e:
            print('Ошибка SQL (пропускаю):', str(e)[:100])
    
    print("SQL трансформации выполнены!")


# Задача 3: Проверяем результат
def check_result():
    print("=" * 50)
    print("Проверяю результат...")
    
    engine = create_engine('postgresql+psycopg2://postgres:postgres123@postgres:5432/f1_1984')
    
    with engine.connect() as conn:
        result = conn.execute(text('SELECT COUNT(*) FROM pilots_top'))
        pilots_count = result.fetchone()[0]
        
        result = conn.execute(text('SELECT COUNT(*) FROM race_winners'))
        races_count = result.fetchone()[0]
        
        result = conn.execute(text('SELECT COUNT(*) FROM constructor_report'))
        teams_count = result.fetchone()[0]
    
    print("ELT процесс завершён!")
    print("Пилотов в pilots_top:", pilots_count)
    print("Гонок в race_winners:", races_count)
    print("Команд в constructor_report:", teams_count)
    print("=" * 50)


# Создаём задачи
load_task = PythonOperator(
    task_id='load_csv_files',
    python_callable=load_csv_files,
    dag=dag,
)

sql_task = PythonOperator(
    task_id='sql_transform',
    python_callable=run_sql_transform,
    dag=dag,
)

check_task = PythonOperator(
    task_id='check_result',
    python_callable=check_result,
    dag=dag,
)

# Порядок выполнения
load_task >> sql_task >> check_task

