-- Query 1: Monthly Sales Drill-Down

SELECT 
    a.dte_year as year,
    a.quarter_num as quarter,
    a.month_name as month_name,
    SUM(b.total_amount) as total_sales,
    SUM(b.quantity_sold) as total_quantity
FROM fleximart_dw.dim_date a INNER JOIN fleximart_dw.fact_sales b ON a.full_date=b.date_key
GROUP BY 1,2,3

-- Query 2: Top 10 Products by Revenue

SELECT
  product_name,
  category,
  units_sold,
  revenue,
  revenue_percentage
FROM (
  SELECT
    product_name,
    category,
    units_sold,
    revenue,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS revenue_percentage,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS rev_rank
  FROM (
    SELECT
      b.product_name,
      b.category,
      SUM(a.quantity_sold) AS units_sold,
      SUM(a.total_amount) AS revenue
    FROM fleximart_dw.fact_sales a
    JOIN fleximart_dw.dim_product b
      ON a.product_key = b.product_key
    GROUP BY b.product_name, b.category
  ) agg
) ranked
WHERE rev_rank <= 10
ORDER BY revenue DESC;


-- Query 3: Customer Segmentation
SELECT
    CASE 
        WHEN total_value>50000 THEN 'High Value'
        WHEN total_value>20000 and total_value<50000 THEN 'Medium Value' 
        ELSE  'Low Value'
    END,
    COUNT(customer_key) as customer_count,
    SUM(total_value) as total_revenue,
    ROUND(SUM(total_value)/COUNT(customer_key),2) as average_revenue
FROM
(SELECT customer_key,
    SUM(total_amount) as total_value
FROM fleximart_dw.fact_sales
GROUP BY 1) t
GROUP BY 1