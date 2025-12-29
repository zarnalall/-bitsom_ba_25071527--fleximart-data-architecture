-- Date table creation

DROP TABLE fleximart_dw.dim_date;
CREATE TABLE fleximart_dw.dim_date (
    full_date DATE PRIMARY KEY NOT NULL,
    day_of_week VARCHAR(10),
    day_of_month INT,
    month_num INT,
    month_name VARCHAR(10),
    quarter_num VARCHAR(2),
    dte_year INT,
    is_weekend TINYINT(1)
);


-- Insert value into Date Table (dim_date)


CREATE TEMPORARY TABLE tmp_dates AS
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS dte
    UNION ALL
    SELECT DATE_ADD(dte, INTERVAL 1 DAY)
    FROM dates
    WHERE dte < '2025-01-01'
)
SELECT
    dte AS full_date,
    DAYNAME(dte) AS day_of_week,
    DAYOFMONTH(dte) AS day_of_month,
    MONTH(dte) AS month_num,
    MONTHNAME(dte) AS month_name,
    CONCAT('Q', QUARTER(dte)) AS quarter_num,
    YEAR(dte) AS dte_year,
    CASE
        WHEN WEEKDAY(dte) IN (5, 6) THEN 1
        ELSE 0
    END AS is_weekend
FROM dates;

INSERT INTO fleximart_dw.dim_date SELECT * from tmp_dates

select * FROM fleximart_dw.dim_date 


-- dim_product
CREATE TABLE fleximart_dw.dim_product (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

INSERT INTO fleximart_dw.dim_product (product_id, product_name, category, unit_price)
SELECT product_id, product_name, category, price FROM fleximart_dw.products;

CREATE TABLE fleximart_dw.dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

INSERT INTO fleximart_dw.dim_customer (customer_id, customer_name, city)
SELECT customer_id, CONCAT(first_name,' ', last_name) as name, city FROM customers

CREATE TABLE fleximart_dw.fact_sales (
    sale_key INT PRIMARY KEY AUTO_INCREMENT,
    date_key DATE NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    quantity_sold INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (date_key) REFERENCES fleximart_dw.dim_date(full_date),
    FOREIGN KEY (product_key) REFERENCES fleximart_dw.dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES fleximart_dw.dim_customer(customer_key)
);

INSERT INTO fleximart_dw.fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, total_amount)
SELECT a.order_date,b.product_id,a.customer_id, SUM(b.quantity) as quantity_sold, SUM(b.unit_price) as unit_price,
 SUM(a.total_amount) as total_amount
FROM orders a LEFT JOIN order_items b ON a.order_id=b.order_id
GROUP BY 1,2,3


SELECT * FROM fleximart_dw.fact_sales