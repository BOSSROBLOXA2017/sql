# -------------------------------------
# Список всех товаров 
SELECT 
    p.product_name AS "Товар",
    c.category_name AS "Категория",
    p.list_price AS "Цена"
FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY p.list_price DESC;

# -------------------------------------
# Сотрудники конкретного магазина
SELECT 
    e.first_name AS "Имя",
    e.last_name AS "Фамилия",
    e.email AS "Почта",
    s.store_name AS "Магазин"
FROM employees e
JOIN stores s ON e.store_id = s.store_id
WHERE s.store_name = 'Магазин на Ленина';

# -------------------------------------
# Три самых дорогих товара в каталоге
SELECT 
    product_name AS "Товар",
    model AS "Модель",
    list_price AS "Цена"
FROM products
ORDER BY list_price DESC
LIMIT 3;

# -------------------------------------
# Средняя цена товаров по категориям
SELECT 
    c.category_name AS "Категория",
    ROUND(AVG(p.list_price), 2) AS "Средняя цена"
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY "Средняя цена" DESC;

# -------------------------------------
# Список открытых магазинов
SELECT 
    store_name AS "Название магазина",
    status AS "Статус"
FROM stores
WHERE status = 'Открыт'
ORDER BY store_name;

# -------------------------------------
# неявное соединение таблиц с фильтром данных (WHERE) и сортировкой (ORDER BY):
# позиции продаж дороже 20 000 с названиями товаров
SELECT 
    s.sale_id AS "Номер продажи",
    s.sale_date AS "Дата",
    p.product_name AS "Товар",
    si.quantity AS "Кол-во",
    si.line_sum AS "Сумма"
FROM sales s, sale_items si, products p
WHERE si.sale_id = s.sale_id
  AND si.product_id = p.product_id
  AND si.line_sum > 20000
ORDER BY s.sale_date DESC, si.line_sum DESC;

# -------------------------------------
# агрегирующие операции (SUM, AVG, COUNT, MAX, MIN)
SELECT 
    COUNT(*) AS "Кол-во позиций",
    SUM(si.line_sum) AS "Общая выручка",
    MAX(si.line_sum) AS "Максимальная позиция",
    MIN(si.line_sum) AS "Минимальная позиция"
FROM sale_items si;

# -------------------------------------
# группировку GROUP BY и фильтрацию HAVING
# выручка по категориям, оставить категории с выручкой > 50 000
SELECT 
    c.category_name AS "Категория",
    COUNT(DISTINCT si.sale_id) AS "Кол-во продаж",
    SUM(si.line_sum) AS "Выручка"
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
HAVING SUM(si.line_sum) > 50000
ORDER BY Выручка DESC;

# -------------------------------------
# вложенные подзапросы (запрос в запросе), в т.ч. использовать операторы IN
# товары из категорий, по которым были продажи
SELECT 
    product_name AS "Товар",
    list_price AS "Цена"
FROM products
WHERE category_id IN (
    SELECT DISTINCT p.category_id
    FROM sale_items si
    JOIN products p ON p.product_id = si.product_id
);

# -------------------------------------
# вложенные подзапросы (запрос в запросе), в т.ч. использовать операторы ALL
# позиции продаж с самой высокой ценой
SELECT 
    p.product_name AS "Товар",
    si.price AS "Цена продажи"
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
WHERE si.price >= ALL (SELECT price FROM sale_items);

# -------------------------------------
# использование «функций управления потоком» (IF, CASE) в соответствии с бизнес-логикой задачи
# классификация чеков + состояние магазина
SELECT 
    s.sale_id AS "Номер продажи",
    s.sale_date AS "Дата",
    st.store_name AS "Магазин",
    IF(st.status = 'Открыт', 'работает', 'закрыт') AS "Состояние",
    SUM(si.line_sum) AS "Сумма чека",
    CASE
        WHEN SUM(si.line_sum) < 30000  THEN 'Мелкий'
        WHEN SUM(si.line_sum) < 100000 THEN 'Средний'
        ELSE 'Крупный'
    END AS "Категория чека"
FROM sales s
JOIN stores st ON st.store_id = s.store_id
JOIN sale_items si ON si.sale_id = s.sale_id
GROUP BY s.sale_id, s.sale_date, st.store_name, st.status
ORDER BY s.sale_id;

# -------------------------------------
# создание одного представления на наиболее популярный запрос (CREATE VIEW) и временное представление – оператор WITH
# выручка по категориям
CREATE OR REPLACE VIEW v_revenue_by_category AS
SELECT 
    c.category_name AS "Категория",
    SUM(si.line_sum) AS "Выручка",
    COUNT(DISTINCT si.sale_id) AS "Кол-во продаж"
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

SELECT * FROM v_revenue_by_category;

# -------------------------------------
# выполнить анализ и оптимизацию запросов средствами EXPLAIN и созданием индексов (CREATE INDEX)
# категории с выручкой выше средней

EXPLAIN
SELECT s.sale_id, s.sale_date, SUM(si.line_sum)
FROM sales s
JOIN sale_items si ON si.sale_id = s.sale_id
WHERE s.sale_date >= '2026-11-06'
GROUP BY s.sale_id, s.sale_date;

# -------------------------------------
# создание индексов (CREATE INDEX)
CREATE INDEX idx_sales_sale_date ON sales(sale_date);
CREATE INDEX idx_sale_items_line_sum ON sale_items(line_sum);

# -------------------------------------
# использовать механизм транзакций (START TRANSACTION) для своей предметной области
# оформление продажи, вторая позиция с ошибочной ценой откатывается
START TRANSACTION;

INSERT INTO sales (sale_id, sale_date, payment_method, store_id, employee_id)
VALUES (10000010, CURDATE(), 'СБП', 1001, 10001);

INSERT INTO sale_items (sale_id, product_id, price, quantity)
VALUES (10000010, '4601234500017', 79990.00, 1);

SAVEPOINT after_first;

INSERT INTO sale_items (sale_id, product_id, price, quantity)
VALUES (10000010, '4601234500048', 1.00, 1);   # ошибка оператора

ROLLBACK TO SAVEPOINT after_first;             # откат только второй позиции

COMMIT;                                        # фиксация первой позиции

SELECT * FROM sale_items WHERE sale_id = 10000010;

# -------------------------------------
# один из запросов на выборку записать и выполнить средствами операторов PREPARE, EXECUTE, DEALLOCATE
# позиции продаж дороже заданной суммы
SET @min_sum := 30000;

PREPARE stmt FROM
'SELECT s.sale_id, p.product_name, si.line_sum
 FROM sale_items si
 JOIN products p ON p.product_id = si.product_id
 JOIN sales s ON s.sale_id = si.sale_id
 WHERE si.line_sum > ?';

EXECUTE stmt USING @min_sum;

DEALLOCATE PREPARE stmt;
