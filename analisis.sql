-- Creamos los indices.
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX idx_order_audit_order_id ON order_audit(order_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Ordenes con pagos nulos | 37384 registros.
SELECT o.order_id 
FROM orders AS o
LEFT JOIN payments AS p 
ON o.order_id = p.order_id
WHERE p.order_id IS NULL

-- Órdenes sin items | 5934 registros
SELECT o.order_id
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Totales inválidos | 5934 registros
SELECT order_id, order_total
FROM orders
WHERE order_total <= 0;

-- Pagos con amount 0 o negativo | 6911 registros
SELECT payment_id, amount
FROM payments
WHERE amount <= 0;

-- Segmentos inválidos | 4471 registros
SELECT customer_id, segment
FROM customers
WHERE segment NOT IN ('retail', 'wholesale');

-- Status history que referencia órdenes que no existen | 0 registros
SELECT osh.status_history_id
FROM order_status_history osh
LEFT JOIN orders o ON osh.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Auditorías que referencian órdenes que no existen | 0 registros
SELECT oa.audit_id
FROM order_audit oa
LEFT JOIN orders o ON oa.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Items que referencian productos que no existen | 0 registros
SELECT oi.order_item_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Relaciones rotas | 0 registros
-- pagos que referencian órdenes que no existen
SELECT p.payment_id
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Descuentos inválidos | 0 Filas
SELECT order_item_id, discount_rate
FROM order_items
WHERE discount_rate < 0 OR discount_rate > 100;

SELECT discount_rate
FROM order_items
WHERE discount_rate > 1
ORDER BY discount_rate DESC
LIMIT 10;

SELECT order_item_id, discount_rate
FROM order_items
WHERE discount_rate < 0 OR discount_rate > 1;

SELECT * FROM order_items 
WHERE discount_rate > 0.25
LIMIT 10;

-- Ordenes sin clientes | 0 filas

SELECT o.order_id
FROM orders AS o
LEFT JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL


-- Órdenes con sus clientes | 
SELECT o.order_id, c.full_name, o.order_datetime, o.current_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_datetime DESC
LIMIT 10;

-- Historial de estados de una orden |
SELECT o.order_id, osh.status, osh.changed_at, osh.changed_by
FROM orders o
JOIN order_status_history osh ON o.order_id = osh.order_id
ORDER BY osh.changed_at DESC
LIMIT 10;

-- Items de una orden con detalle de producto
SELECT oi.order_id, p.product_name, oi.quantity, oi.unit_price, oi.line_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LIMIT 10;
