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
