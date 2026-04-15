import pandas as pd
import psycopg2
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# leemos el archivo .env
load_dotenv()

# cargamos las variables del .env
DB_HOST = os.getenv('DB_HOST')
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')

# establecemos la conexion
engine = create_engine(f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}')


# cargamos todas las tablas con ayuda de los dataframe de pandas.
df_customers = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/customers.csv')

df_customers['is_active'] = df_customers['is_active'].astype(bool)

df_customers.to_sql('customers', engine, if_exists='append', index=False)

df_products = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/products.csv')

df_products['is_active'] = df_products['is_active'].astype(bool)

df_products.to_sql('products', engine, if_exists='append', index=False)

df_orders = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/orders.csv')

df_orders['is_active'] = df_orders['is_active'].astype(bool)

df_orders.to_sql('orders', engine, if_exists='append', index=False)

df_payments = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/payments.csv')

df_payments = df_payments.rename(columns={'method': 'payment_method'})

df_payments.to_sql('payments', engine, if_exists='append', index=False)

df_order_items = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/order_items.csv')

df_order_items.to_sql('order_items', engine, if_exists='append', index=False)

df_order_status_history = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/order_status_history.csv')

df_order_status_history.to_sql('order_status_history', engine, if_exists='append', index=False)

df_order_audit = pd.read_csv('E:/Proyectos/codepro/Registro-Glacial/csv/order_audit.csv')

df_order_audit.to_sql('order_audit', engine, if_exists='append', index=False)
