Create database Pizza_DB;
Use Pizza_DB;
-- KPI
-- 1.	Total Revenue:
SELECT SUM(total_price) as Total_Revenue FROM pizza_sales;

-- 2.	Average Order Value
SELECT SUM(total_price)/Count(distinct order_id) AS Avg_Order_Value FROM pizza_sales;

-- 3.	Total Pizza Sold
SELECT SUM(quantity) AS Total_Pizza_Sold FROM pizza_sales;


-- 4.	Total Orders
SELECT COUNT(distinct order_id) AS Total_Orders FROM pizza_sales;


-- 5.	Average Pizzas Per Order
SELECT round(SUM(quantity)/COUNT(distinct order_id),2) AS AVG_Pizza_per_Order FROM pizza_sales;

-- change date formate text to date
ALTER TABLE pizza_sales
ADD COLUMN order_date_temp DATE;

UPDATE pizza_sales
SET order_date_temp = STR_TO_DATE(order_date, '%d-%m-%Y');

ALTER TABLE pizza_sales
DROP COLUMN order_date;

ALTER TABLE pizza_sales
CHANGE order_date_temp order_date DATE;

-- change time formate text to time
ALTER TABLE pizza_sales
ADD COLUMN order_time_temp TIME;

UPDATE pizza_sales
SET order_time_temp = STR_TO_DATE(order_time, '%H:%i:%s');

ALTER TABLE pizza_sales
DROP COLUMN order_time;

ALTER TABLE pizza_sales
CHANGE order_time_temp order_time TIME;

-- 1. Daily Trend
SELECT DAYNAME(order_date) as order_day, COUNT(DISTINCT order_id) AS Total_orders
from pizza_sales
GROUP BY DAYNAME(order_date);


-- 2. Hourly Trend
SELECT HOUR(order_time) as order_hours, COUNT(DISTINCT order_id) AS Total_orders
from pizza_sales
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 3. Percentage of Sales by Pizza Category
SELECT pizza_category, ROUND(SUM(total_price),2) as Total_sales, ROUND(SUM(total_price)*100/(SELECT sum(total_price) FROM pizza_sales),2) AS PCT_Of_Sales
FROM pizza_sales
GROUP BY pizza_category;


-- 3.A Percentage of Sales by Pizza Category of Paticular Month
SELECT pizza_category, ROUND(SUM(total_price),2) as Total_sales, ROUND(SUM(total_price)*100/(SELECT sum(total_price) FROM pizza_sales),2) AS PCT_Of_Sales
FROM pizza_sales
WHERE MONTH(order_date)=1
GROUP BY pizza_category;

-- 3.B Percentage of Sales by Pizza Category of each Month
SELECT pizza_category, MONTH(order_date) AS Month, ROUND(SUM(total_price),2) as Total_sales, ROUND(SUM(total_price)*100/(SELECT sum(total_price) FROM pizza_sales),2) AS PCT_Of_Sales
FROM pizza_sales
GROUP BY MONTH(order_date), pizza_category;

-- 4.	Percentage of Sales by Pizza Size:
SELECT pizza_size, ROUND(SUM(total_price),2) as Total_sales, ROUND(SUM(total_price)*100/(SELECT sum(total_price) FROM pizza_sales),2) AS PCT_Of_Sales
FROM pizza_sales
GROUP BY pizza_size
ORDER BY PCT_Of_Sales DESC;

-- 5.	Total Pizzas Sold by Pizza Category
SELECT pizza_category, sum(quantity) as Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_category;

-- 6.	Top 5 Best Sellers by Total Pizzas Sold:
SELECT pizza_name, sum(quantity) as Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER by Total_Pizza_Sold DESC
LIMIT 5;

-- 7.	Bottom 5 Worst Sellers by Total Pizzas Sold
SELECT pizza_name, sum(quantity) as Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER by Total_Pizza_Sold 
LIMIT 5;

-- Extra

-- 1. HAVING Clause
-- Find pizza categories with  more than 12,000 pizzas sold
SELECT pizza_category, SUM(quantity) AS Total_Quantity
FROM pizza_sales
GROUP BY pizza_category
HAVING SUM(quantity) > 12000;

-- 2. SELF JOIN 
-- Find pairs of pizzas sold on the same order (i.e., same order_id) but with different names.

SELECT 
    A.order_id,
    A.pizza_name AS pizza_1,
    B.pizza_name AS pizza_2
FROM pizza_sales A
JOIN pizza_sales B 
  ON A.order_id = B.order_id
  AND A.pizza_name < B.pizza_name
ORDER BY A.order_id;


-- 3. CASE Statement 
-- Classify each order as `'Small'`, `'Medium'`, or `'Large'` revenue order.

SELECT order_id, total_price,
  CASE
    WHEN total_price < 15 THEN 'Small'
    WHEN total_price BETWEEN 15 AND 20 THEN 'Medium'
    ELSE 'Large'
  END AS order_type
FROM pizza_sales;

-- 4. COALESCE and NULL Handling 
-- Show all pizzas and their total revenue, defaulting to 0 if no revenue exists.

SELECT pizza_name, COALESCE(SUM(total_price), 0) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name;

-- 5. String Functions 
-- Get pizza names with their first 5 letters and total sold quantity.

SELECT pizza_name, SUBSTRING(pizza_name, 5, 4) AS short_name, SUM(quantity) AS Total_Sold
FROM pizza_sales
GROUP BY pizza_name;

-- 6. CTE (Common Table Expression) 
-- Using a CTE, calculate average revenue per pizza and show only those above average.

WITH PizzaRevenue AS (
  SELECT pizza_name, SUM(total_price) AS revenue
  FROM pizza_sales
  GROUP BY pizza_name
)
SELECT *
FROM PizzaRevenue
WHERE revenue > (SELECT AVG(revenue) FROM PizzaRevenue);

-- 7. Window Function 
-- Rank pizzas by revenue within each category.

SELECT pizza_name, pizza_category, SUM(total_price) AS revenue,
       RANK() OVER (PARTITION BY pizza_category ORDER BY SUM(total_price) DESC) AS rank_in_category
FROM pizza_sales
GROUP BY pizza_name, pizza_category;

-- 8. UNION / UNION ALL 
-- List pizza names sold more than 1000 units or with revenue over \$10,000.

SELECT pizza_name FROM pizza_sales
GROUP BY pizza_name
HAVING SUM(quantity) > 1000

UNION

SELECT pizza_name FROM pizza_sales
GROUP BY pizza_name
HAVING SUM(total_price) > 10000;

-- 9. DELETE 
-- Delete test orders with 0 quantity.

DELETE FROM pizza_sales
WHERE quantity = 0;

