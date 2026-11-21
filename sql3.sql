CREATE TABLE IF NOT EXISTS sales_statistics (
    stat_id       INT AUTO_INCREMENT PRIMARY KEY,
    calc_date     DATE,              -- дата расчёта (текущая)
    positions_cnt INT,               -- количество позиций
    total_sum     DECIMAL(14,2),     -- сумма цен
    avg_price     DECIMAL(14,2),     -- среднее
    max_price     DECIMAL(12,2),     -- максимум
    min_price     DECIMAL(12,2)      -- минимум
);

-- ---------------------------------------------------------------------
-- ПРОЦЕДУРА 1. Описательная статистика по таблице sale_items:
-- среднее, сумма, максимум, минимум + вставка новой строки
-- с текущей датой в таблицу sales_statistics.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_sales_statistics;

DELIMITER $$
CREATE PROCEDURE sp_sales_statistics()
BEGIN
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_sum DECIMAL(14,2) DEFAULT 0;
    DECLARE v_avg DECIMAL(14,2) DEFAULT 0;
    DECLARE v_max DECIMAL(12,2) DEFAULT 0;
    DECLARE v_min DECIMAL(12,2) DEFAULT 0;

    SELECT COUNT(*),
           COALESCE(SUM(price), 0),
           AVG(price),
           MAX(price),
           MIN(price)
      INTO v_cnt, v_sum, v_avg, v_max, v_min
    FROM sale_items;

    INSERT INTO sales_statistics
        (calc_date, positions_cnt, total_sum, avg_price, max_price, min_price)
    VALUES
        (CURDATE(), v_cnt, v_sum, v_avg, v_max, v_min);
END$$
DELIMITER ;

CALL sp_sales_statistics();
SELECT * FROM sales_statistics;

-- ---------------------------------------------------------------------
-- ПРОЦЕДУРА 2. Оформление продажи для предметной области:
-- добавляет строку в sales (с текущей датой) и позицию в sale_items.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_add_sale;

DELIMITER $$
CREATE PROCEDURE sp_add_sale(
    IN p_sale_id    INT,              -- номер продажи
    IN p_store_id   INT,              -- магазин
    IN p_employee_id INT,             -- сотрудник
    IN p_payment    VARCHAR(50),      -- способ оплаты
    IN p_product_id VARCHAR(50),      -- товар
    IN p_price      DECIMAL(10,2),    -- цена продажи
    IN p_quantity   INT               -- количество
)
BEGIN
    INSERT INTO sales (sale_id, sale_date, payment_method, store_id, employee_id)
    VALUES (p_sale_id, CURDATE(), p_payment, p_store_id, p_employee_id);

    INSERT INTO sale_items (sale_id, product_id, price, quantity)
    VALUES (p_sale_id, p_product_id, p_price, p_quantity);
END$$
DELIMITER ;

-- Пример вызова (дата проставится автоматически — сегодняшняя):
CALL sp_add_sale(10000020, 1001, 10001, 'Банковская карта',
                 '4601234500031', 74990.00, 1);

SELECT * FROM sales      WHERE sale_id = 10000020;
SELECT * FROM sale_items WHERE sale_id = 10000020;

-- ---------------------------------------------------------------------
-- ФУНКЦИЯ 1. Количество позиций продаж по условию на столбец:
-- результат записывается в локальную переменную и возвращается.
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_count_positions;

DELIMITER $$
CREATE FUNCTION fn_count_positions(p_min_price DECIMAL(10,2))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;          -- локальная переменная

    SELECT COUNT(*)
      INTO v_count                          -- запись результата в переменную
    FROM sale_items
    WHERE price >= p_min_price;             -- условие по любому столбцу

    RETURN v_count;                         -- возврат значения
END$$
DELIMITER ;

SELECT fn_count_positions(50000) AS позиций_дороже_50000;

-- ---------------------------------------------------------------------
-- ФУНКЦИЯ 2. Выручка по категории товаров
-- (второй пример функции с локальной переменной).
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_category_revenue;

DELIMITER $$
CREATE FUNCTION fn_category_revenue(p_category_id INT)
RETURNS DECIMAL(14,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_revenue DECIMAL(14,2) DEFAULT 0;

    SELECT COALESCE(SUM(si.line_sum), 0)
      INTO v_revenue
    FROM sale_items si
    JOIN products p ON p.product_id = si.product_id
    WHERE p.category_id = p_category_id;

    RETURN v_revenue;
END$$
DELIMITER ;

SELECT fn_category_revenue(1) AS выручка_смартфоны;
SELECT fn_category_revenue(2) AS выручка_ноутбуки;

-- ---------------------------------------------------------------------
-- Проверка созданных объектов
-- ---------------------------------------------------------------------
SHOW PROCEDURE STATUS WHERE Db = 'electronics_sales';
SHOW FUNCTION STATUS  WHERE Db = 'electronics_sales';
SHOW CREATE PROCEDURE sp_sales_statistics;
SHOW CREATE FUNCTION fn_count_positions;
