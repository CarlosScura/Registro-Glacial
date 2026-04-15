DROP TABLE order_audit;
DROP TABLE order_status_history;
DROP TABLE payments;
DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE customers;
products;


CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
	full_name VARCHAR(100) NOT NULL,
	email VARCHAR(254) UNIQUE NOT NULL,
	phone VARCHAR(20) NOT NULL,
	city VARCHAR(100) NOT NULL,
	segment VARCHAR(50) NOT NULL,
	created_at TIMESTAMP NOT NULL,
	is_active BOOLEAN NOT NULL,
	deleted_at TIMESTAMP
);

CREATE TABLE products (
	product_id SERIAL PRIMARY KEY,
	sku VARCHAR(100) UNIQUE NOT NULL,
	product_name VARCHAR(254) NOT NULL,
	category VARCHAR(100) NOT NULL,
	brand VARCHAR(100) NOT NULL,
	unit_price NUMERIC(10,2) NOT NULL,
	unit_cost NUMERIC(10,2) NOT NULL,
	created_at TIMESTAMP NOT NULL,
	is_active BOOLEAN NOT NULL,
	deleted_at TIMESTAMP
);

CREATE TABLE orders(
	order_id SERIAL PRIMARY KEY,
	customer_id INT REFERENCES customers(customer_id),
	order_datetime TIMESTAMP NOT NULL,
	channel VARCHAR(50) NOT NULL,
	currency VARCHAR(10) NOT NULL,
	current_status VARCHAR(25) NOT NULL,
	is_active BOOLEAN NOT NULL,
	deleted_at TIMESTAMP,
	order_total NUMERIC(10,2) NOT NULL
);

CREATE TABLE order_items(
	order_item_id SERIAL PRIMARY KEY,
	order_id INT REFERENCES orders(order_id),
	product_id INT REFERENCES products(product_id),
	quantity INT NOT NULL,
	unit_price NUMERIC(10,2) NOT NULL,
	discount_rate NUMERIC(5,2),
	line_total NUMERIC(10,2) NOT NULL
);

CREATE TABLE payments(
	payment_id SERIAL PRIMARY KEY,
	order_id INT REFERENCES orders(order_id),
	payment_datetime TIMESTAMP NOT NULL,
	payment_method VARCHAR(20) NOT NULL,
	payment_status VARCHAR(20) NOT NULL,
	amount NUMERIC(10,2) NOT NULL,
	currency VARCHAR(10) NOT NULL
);

CREATE TABLE order_status_history(
	status_history_id SERIAL PRIMARY KEY,
	order_id INT REFERENCES orders(order_id),
	status VARCHAR(25) NOT NULL,
	changed_at TIMESTAMP NOT NULL,
	changed_by VARCHAR(25) NOT NULL,
	reason VARCHAR(25)
);

CREATE TABLE order_audit(
	audit_id SERIAL PRIMARY KEY,
	order_id INT REFERENCES orders(order_id),
	field_name varchar(50) NOT NULL,
	old_value VARCHAR(50),
	new_value VARCHAR(50),
	changed_at TIMESTAMP NOT NULL,
	changed_by VARCHAR(25) NOT NULL
);