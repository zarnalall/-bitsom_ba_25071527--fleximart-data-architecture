
-- Insert value into Date Table (dim_date)


INSERT INTO fleximart_dw.dim_date (
    date_key,
    full_date,
    day_of_week,
    day_of_month,
    month,
    month_name,
    quarter,
    year,
    is_weekend
)
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS dte
    UNION ALL
    SELECT DATE_ADD(dte, INTERVAL 1 DAY)
    FROM dates
    WHERE dte < '2024-02-29'
)
SELECT
    DATE_FORMAT(dte, '%Y%m%d') AS date_key,
    dte AS full_date,
    DAYNAME(dte) AS day_of_week,
    DAYOFMONTH(dte) AS day_of_month,
    MONTH(dte) AS month,
    MONTHNAME(dte) AS month_name,
    CONCAT('Q', QUARTER(dte)) AS quarter,
    YEAR(dte) AS year,
    CASE
        WHEN WEEKDAY(dte) IN (5, 6) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM dates;


-- Insert value into product Table (dim_product)

INSERT INTO fleximart_dw.dim_product (product_id, product_name, category, unit_price)
SELECT product_id, product_name, category, price FROM fleximart_dw.products;

-- Turn off safe updates for this session
SET SQL_SAFE_UPDATES = 0;

-- Updates Subcategoy in dim_product table
UPDATE dim_product
SET subcategory = CASE
    WHEN product_name REGEXP '(?i)\\b(Samsung Galaxy|iPhone|Phone|Nord)\\b' THEN 'Mobiles'
    WHEN product_name REGEXP '(?i)\\b(Laptop|MacBook)\\b'    THEN 'Laptops'
    WHEN product_name REGEXP '(?i)\\b(Headphones|Earbud|Earbuds)\\b' THEN 'Audio'
    WHEN product_name REGEXP '(?i)\\b(Monitor)\\b'          THEN 'Monitors'
    WHEN product_name REGEXP '(?i)\\b(TV|Television)\\b'    THEN 'Televisions'
    ELSE 'Unknown'
  END
WHERE subcategory IS NULL
  AND category = 'Electronics';
  
UPDATE dim_product
SET subcategory = CASE
    WHEN product_name REGEXP '(?i)\\b(Shoes|Sneakers)\\b' THEN 'Shoes'
    WHEN product_name REGEXP '(?i)\\b(Jeans|T-Shirt|Shirt|Trackpants)\\b'    THEN 'Cloths'
    ELSE 'Unknown'
  END
WHERE subcategory IS NULL
  AND category = 'Fashion';
  
UPDATE dim_product
SET subcategory = CASE
    WHEN product_name LIKE '%Almond%' THEN 'Dry Fruits'
    WHEN product_name LIKE '%Rice%' THEN 'Grains'
    WHEN product_name LIKE '%Honey%' THEN 'Condiments'
    WHEN product_name LIKE '%Dal%' THEN 'Pulses'
    ELSE 'Other'
END
WHERE category = 'Groceries'
  AND subcategory IS NULL;

-- Insert value into Customer Table (dim_customer)

INSERT INTO fleximart_dw.dim_customer (customer_id, customer_name, city)
SELECT customer_id, concat(first_name,' ',last_name) as name, city FROM fleximart_dw.customers;

-- Updates state in dim_customer table
UPDATE dim_customer
SET state = CASE
    WHEN city like 'Trivandrum' THEN 'Kerala'
    WHEN city like 'Pune' THEN 'Maharashtra'
    WHEN city like 'Mumbai' THEN 'Maharashtra'
    WHEN city like 'Lucknow' THEN 'Uttar Pradesh'
    WHEN city like 'Kolkata' THEN 'West Bengal'
    WHEN city like 'Kochi' THEN 'Kerala'
    WHEN city like 'Jaipur' THEN 'Rajasthan'
    WHEN city like 'Indore' THEN 'Madhya Pradesh'
    WHEN city like 'Hyderabad' THEN 'Telangana'
    WHEN city like 'Delhi' THEN 'Delhi'
    WHEN city like 'Chennai' THEN 'Tamil Nadu'
    WHEN city like 'Chandigarh' THEN 'Chandigarh'
    WHEN city like 'Bangalore' THEN 'Karnataka'
    WHEN city like 'Ahmedabad' THEN 'Gujarat'
    ELSE 'Unknown'
  END
WHERE state IS NULL;

-- Updates customer_segment in dim_customer table
UPDATE dim_customer
SET customer_segment = CASE customer_key
    WHEN 1 THEN 'Corporate'
    WHEN 2 THEN 'Retail'
    WHEN 3 THEN 'Corporate'
    WHEN 4 THEN 'Corporate'
    WHEN 5 THEN 'Retail'
    WHEN 6 THEN 'Small Business'
    WHEN 7 THEN 'Retail'
    WHEN 8 THEN 'Corporate'
    WHEN 9 THEN 'Retail'
    WHEN 10 THEN 'Small Business'
    WHEN 11 THEN 'Corporate'
    WHEN 12 THEN 'Retail'
    WHEN 13 THEN 'Small Business'
    WHEN 14 THEN 'Corporate'
    WHEN 15 THEN 'Corporate'
    WHEN 16 THEN 'Retail'
    WHEN 17 THEN 'Small Business'
    WHEN 18 THEN 'Retail'
    WHEN 19 THEN 'Corporate'
    WHEN 20 THEN 'Small Business'
    WHEN 21 THEN 'Small Business'
    WHEN 22 THEN 'Corporate'
    WHEN 23 THEN 'Retail'
    WHEN 24 THEN 'Small Business'
    WHEN 25 THEN 'Corporate'
END;

-- Insert value into Sales Fact Table (fact_sales)

INSERT INTO fleximart_dw.fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, total_amount)
SELECT a.order_date,b.product_id,a.customer_id, SUM(b.quantity) as quantity_sold, SUM(b.unit_price) as unit_price,
 SUM(a.total_amount) as total_amount
FROM orders a LEFT JOIN order_items b ON a.order_id=b.order_id
GROUP BY 1,2,3


SELECT * FROM fleximart_dw.fact_sales