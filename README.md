# Registro-Glacial
Tercer Challenge en The Huddle, base de datos.

Orden de creación:

customers y products
orders
order_items, payments, order_status_history, order_audit

Tipos de datos y constrains

customers

customer_id: PK
full_name: VARCHAR(100) NOT NULL
email: VARCHAR(254) UNIQUE NOT NULL
phone: VARCHAR(20) UNIQUE NOT NULL
city: VARCHAR(100) NOT NULL
segment: VARCHAR(50) NOT NULL
created_at: TIMESTAMP NOT NULL
is_active: BOOLEAN NOT NULL
deleted_at: TIMESTAMP


products

product_id: PK
sku: VARCHAR(100) NOT NULL UNIQUE
product_name: VARCHAR(254) NOT NULL
category: VARCHAR(100) NOT NULL
brand: VARCHAR(100) NOT NULL
unit_price: NUMERIC(10,2) NOT NULL
unit_cost: NUMERIC(10,2) NOT NULL
created_at: TIMESTAMP NOT NULL
is_active: BOOLEAN NOT NULL
deleted_at: TIMESTAMP


orders

order_id: PK
customer_id: FK → customers
order_datetime: TIMESTAMP NOT NULL
channel: VARCHAR(50) NOT NULL
currency: VARCHAR(10) NOT NULL
current_status: VARCHAR(25) NOT NULL CHECK IN ('created', 'packed', 'shipped', 'delivered', 'cancelled', 'refunded')
is_active: BOOLEAN NOT NULL
deleted_at: TIMESTAMP
order_total: NUMERIC(10,2) NOT NULL CHECK > 0


order_items

order_item_id: PK
order_id: FK → orders
product_id: FK → products
quantity: INTEGER NOT NULL CHECK > 0
unit_price: NUMERIC(10,2) NOT NULL
discount_rate: NUMERIC(5,2) CHECK >= 0 AND <= 100
line_total: NUMERIC(10,2) NOT NULL


payments

payment_id: PK
order_id: FK → orders
payment_datetime: TIMESTAMP NOT NULL
method: VARCHAR(20) NOT NULL CHECK IN ('card', 'cash', 'transfer', 'wallet')
payment_status: VARCHAR(20) NOT NULL CHECK IN ('approved', 'pending', 'refunded', 'rejected')
amount: NUMERIC(10,2) NOT NULL CHECK > 0
currency: VARCHAR(10) NOT NULL


order_status_history

status_history_id: PK
order_id: FK → orders
status: VARCHAR(25) NOT NULL CHECK IN ('cancelled', 'created', 'delivered', 'packed', 'refunded', 'shipped')
changed_at: TIMESTAMP NOT NULL
changed_by: VARCHAR(25) NOT NULL CHECK IN ('ops', 'payment_gateway', 'system', 'user', 'warehouse')
reason: VARCHAR(25)


order_audit

audit_id: PK
order_id: FK → orders
field_name: VARCHAR(50) NOT NULL CHECK IN ('order_id', 'customer_id', 'order_datetime', 'channel', 'currency', 'current_status', 'is_active', 'deleted_at', 'order_total')
old_value: VARCHAR(50)
new_value: VARCHAR(50)
changed_at: TIMESTAMP NOT NULL
changed_by: VARCHAR(25) NOT NULL CHECK IN ('ops', 'support', 'system')