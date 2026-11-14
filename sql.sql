DROP DATABASE IF EXISTS electronics_sales;
CREATE DATABASE electronics_sales CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE electronics_sales;

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    description TEXT
);

CREATE TABLE manufacturers (
    manufacturer_id INT PRIMARY KEY,
    manufacturer_name VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Открыт'
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    hire_date DATE,
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    model VARCHAR(100),
    warranty_months INT,
    category_id INT,
    manufacturer_id INT,
    list_price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    payment_method VARCHAR(50),
    store_id INT,
    employee_id INT,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE sale_items (
    sale_id INT,
    product_id VARCHAR(50),
    price DECIMAL(10, 2),
    quantity INT,
    line_sum DECIMAL(10, 2) GENERATED ALWAYS AS (ROUND(price * quantity, 2)) STORED,
    PRIMARY KEY (sale_id, product_id),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO categories (category_id, category_name, description) VALUES
(1, 'Смартфоны', 'Мобильные телефоны'),
(2, 'Ноутбуки', 'Портативные компьютеры'),
(3, 'Телевизоры', 'Телевизионная техника');

INSERT INTO manufacturers (manufacturer_id, manufacturer_name, website) VALUES
(101, 'Apple', 'https://www.apple.com'),
(102, 'Samsung', 'https://www.samsung.com'),
(103, 'Xiaomi', 'https://www.mi.com');

INSERT INTO stores (store_id, store_name, status) VALUES
(1001, 'Магазин на Ленина', 'Открыт'),
(1002, 'Магазин на Мира', 'Открыт'),
(1003, 'Магазин на Советской', 'Открыт');

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, store_id) VALUES
(10001, 'Иван', 'Иванов', 'ivanov@electron.ru', '2019-03-01', 1001),
(10002, 'Петр', 'Петров', 'petrova@electron.ru', '2020-02-10', 1001),
(10003, 'Анна', 'Кузнецова', 'kuznecova@electron.ru', '2020-09-01', 1002);

INSERT INTO products (product_id, product_name, model, warranty_months, category_id, manufacturer_id, list_price) VALUES
('4601234500017', 'Смартфон Apple iPhone 15 128GB', 'iPhone 15 128GB', 12, 1, 101, 89990.00),
('4601234500031', 'Смартфон Samsung Galaxy S24 256GB', 'Galaxy S24 256GB', 12, 1, 102, 84990.00),
('4601234500048', 'Смартфон Xiaomi Redmi Note 13', 'Redmi Note 13', 12, 1, 103, 18990.00),
('4601234500024', 'Ноутбук Apple MacBook Air 13 M2', 'MacBook Air M2', 12, 2, 101, 109990.00),
('4601234500079', 'Ноутбук Samsung Galaxy Book4', 'Galaxy Book4', 24, 2, 102, 64990.00),
('4601234500086', 'Телевизор Samsung UE50CU7100', 'UE50CU7100U', 24, 3, 102, 49990.00);

INSERT INTO sales (sale_id, sale_date, payment_method, store_id, employee_id) VALUES
(10000001, '2026-11-05', 'Банковская карта', 1001, 10003),
(10000002, '2026-11-07', 'Наличные', 1002, 10003),
(10000003, '2026-11-10', 'СБП', 1003, 10003);

INSERT INTO sale_items (sale_id, product_id, price, quantity) VALUES
(10000001, '4601234500017', 79990.00, 1),
(10000001, '4601234500048', 18990.00, 2),
(10000002, '4601234500024', 109990.00, 1),
(10000002, '4601234500086', 49990.00, 1),
(10000003, '4601234500031', 74990.00, 1),
(10000003, '4601234500079', 64990.00, 1);

UPDATE employees SET email = 'ivanov@electron.ru', hire_date = '2019-03-01', store_id = 1001 WHERE employee_id = 10001;
UPDATE employees SET email = 'petrova@electron.ru', hire_date = '2020-02-10', store_id = 1001 WHERE employee_id = 10002;
UPDATE employees SET email = 'kuznecova@electron.ru', hire_date = '2020-09-01', store_id = 1002 WHERE employee_id = 10003;

UPDATE stores SET status = 'Ремонт' WHERE store_id = 1003;
UPDATE categories SET description = 'Мобильные телефоны' WHERE category_id = 1;
UPDATE manufacturers SET website = 'https://www.apple.com' WHERE manufacturer_id = 101;

UPDATE products SET list_price = 4990.00 WHERE product_id = '4601234500048';
UPDATE products SET list_price = ROUND(list_price * 0.95, 2) WHERE category_id = 1;

UPDATE sale_items SET quantity = 3 WHERE sale_id = 10000001 AND product_id = '4601234500048';

SELECT sale_id, product_id, price, quantity, line_sum 
FROM sale_items 
WHERE sale_id = 10000001;

INSERT INTO sales (sale_id, sale_date, payment_method, store_id, employee_id) VALUES
(10000004, '2026-11-12', 'Наличные', 1001, 10003);

INSERT INTO sale_items (sale_id, product_id, price, quantity) VALUES
(10000004, '4601234500048', 18990.00, 1);

DELETE FROM sale_items WHERE sale_id = 10000004 AND product_id = '4601234500048';
DELETE FROM sales WHERE sale_id = 10000004;

DROP USER IF EXISTS 'director'@'localhost';
DROP USER IF EXISTS 'analyst'@'localhost';
DROP USER IF EXISTS 'manager'@'localhost';
DROP USER IF EXISTS 'seller'@'localhost';

CREATE USER 'director'@'localhost' IDENTIFIED BY 'Director#2026';
CREATE USER 'analyst'@'localhost' IDENTIFIED BY 'Analyst#2026';
CREATE USER 'manager'@'localhost' IDENTIFIED BY 'Manager#2026';
CREATE USER 'seller'@'localhost' IDENTIFIED BY 'Seller#2026';

GRANT ALL PRIVILEGES ON electronics_sales.* TO 'director'@'localhost' WITH GRANT OPTION;
GRANT SELECT ON electronics_sales.* TO 'analyst'@'localhost';
GRANT SELECT, INSERT, UPDATE ON electronics_sales.* TO 'manager'@'localhost';
GRANT INSERT, UPDATE, DELETE ON electronics_sales.sales TO 'seller'@'localhost';
GRANT INSERT, UPDATE, DELETE ON electronics_sales.sale_items TO 'seller'@'localhost';
GRANT SELECT ON electronics_sales.products TO 'seller'@'localhost';
GRANT SELECT ON electronics_sales.categories TO 'seller'@'localhost';
GRANT SELECT ON electronics_sales.stores TO 'seller'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'director'@'localhost';
SHOW GRANTS FOR 'analyst'@'localhost';
SHOW GRANTS FOR 'manager'@'localhost';
SHOW GRANTS FOR 'seller'@'localhost';

DESCRIBE stores;
DESCRIBE employees;
DESCRIBE categories;
DESCRIBE manufacturers;
DESCRIBE products;
DESCRIBE sales;
DESCRIBE sale_items;
