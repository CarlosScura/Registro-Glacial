
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_status_history;
SELECT COUNT(*) FROM order_audit;


TRUNCATE TABLE order_audit, order_status_history, order_items, payments, orders, products, customers CASCADE;

-- Actualizamos las secuencias
-- Porque usamos SERIAL en las PK
SELECT setval('customers_customer_id_seq', (SELECT MAX(customer_id) FROM customers));
SELECT setval('products_product_id_seq', (SELECT MAX(product_id) FROM products));
SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));
SELECT setval('order_items_order_item_id_seq', (SELECT MAX(order_item_id) FROM order_items));
SELECT setval('payments_payment_id_seq', (SELECT MAX(payment_id) FROM payments));
SELECT setval('order_status_history_status_history_id_seq', (SELECT MAX(status_history_id) FROM order_status_history));
SELECT setval('order_audit_audit_id_seq', (SELECT MAX(audit_id) FROM order_audit));
