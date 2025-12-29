-- Active: 1766410489370@@127.0.0.1@3306@fleximart_dw
-- Query 1: Customer Purchase History
SELECT 
    CONCAT(a.first_name,' ', a.last_name) as customer_name,
    a.email,
    COUNT(b.order_id) as total_order,
    sum(b.total_amount) as total_spent
FROM customers a INNER JOIN orders b on a.customer_id=b.customer_id
GROUP BY 1,2
HAVING total_spent >5000
ORDER BY total_spent DESC


-- Query 2: Product Sales Analysis
SELECT 
    a.category,
    COUNT(DISTINCT a.product_id) as num_product,
    SUM(b.quantity) as total_quantity_sold,
    SUM(c.total_amount) as total_revenue
FROM products a 
    INNER JOIN order_items b ON a.product_id=b.product_id
    INNER JOIN orders c ON b.order_id=c.order_id
GROUP BY 1

-- Query 3: Monthly Sales Trend
SELECT
    month_name,
    total_order,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY order_date)
FROM
    (SELECT
        MONTH(a.order_date) as order_date,
        MONTHNAME(a.order_date) as month_name,
        SUM(b.quantity) as total_order,
        SUM(a.total_amount) as monthly_revenue
    FROM orders a
        INNER JOIN order_items b
    GROUP BY 1,2
) t
ORDER BY order_date

