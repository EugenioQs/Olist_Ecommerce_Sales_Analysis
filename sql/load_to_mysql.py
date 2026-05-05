"""
Carga los exports limpios de Python a MySQL.
Ejecutar desde la raíz del proyecto: python sql/load_to_mysql.py
"""
import pandas as pd
from sqlalchemy import create_engine, text
import getpass
import os

EXPORTS = 'exports/'
DB_NAME = 'olist_db'
DB_HOST = '127.0.0.1'
DB_USER = 'root'

password = getpass.getpass(f'MySQL password for {DB_USER}: ')
engine = create_engine(f'mysql+pymysql://{DB_USER}:{password}@{DB_HOST}/{DB_NAME}?charset=utf8mb4')

tables = {
    'orders_features': 'orders_features.csv',
    'agg_monthly':     'agg_monthly.csv',
    'agg_category':    'agg_category.csv',
    'agg_state':       'agg_state.csv',
    'agg_delivery':    'agg_delivery.csv',
    'agg_sellers':     'agg_sellers.csv',
    'agg_payment':     'agg_payment.csv',
}

with engine.connect() as conn:
    for table, fname in tables.items():
        path = os.path.join(EXPORTS, fname)
        df = pd.read_csv(path, encoding='utf-8-sig')
        df.to_sql(table, conn, if_exists='replace', index=False)
        print(f'Cargado: {table:30s} {df.shape}')

    # Verificar
    result = conn.execute(text('SELECT ROUND(SUM(revenue),0) AS total_revenue FROM orders_features'))
    print(f'\nRevenue total en MySQL: R$ {result.fetchone()[0]:,.0f}')

print('\nListo.')
