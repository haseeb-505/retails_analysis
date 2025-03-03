-- Project 1 of SQL, retail_sales_analysis system

-- show data
select * from sql_project1.retail_sales_analysis;

-- checking the data type of each column in the table
SHOW COLUMNS FROM `retail_sales_analysis` FROM `sql_project1`;

-- we see sale_date and sale_time are both formatted as text values 
-- while we want them to be date and time respectively,

ALTER TABLE sql_project1.retail_sales_analysis
MODIFY COLUMN sale_date DATE;

-- change the quantiy column name to quantity
ALTER TABLE sql_project1.retail_sales_analysis
RENAME COLUMN quantiy TO quantity;

-- checking the data type of each column in the table again
SHOW COLUMNS FROM `retail_sales_analysis` FROM `sql_project1`;

-- show data
SELECT * FROM sql_project1.retail_sales_analysis;

-- change the sale_time to time data type
ALTER TABLE sql_project1.retail_sales_analysis
MODIFY COLUMN sale_time TIME;

-- show the data types again
SHOW COLUMNS FROM `retail_sales_analysis` FROM `sql_project1`;
-- modify the price_per_unit to double,
-- cogs to double, 
-- total_sale to double,

ALTER TABLE sql_project1.retail_sales_analysis
MODIFY COLUMN price_per_unit DOUBLE,
MODIFY COLUMN cogs DOUBLE,
MODIFY COLUMN total_sale DOUBLE;

-- show table and then show data types again

SELECT * FROM sql_project1.retail_sales_analysis;

SHOW COLUMNS FROM `retail_sales_analysis` FROM `sql_project1`;

-- Data cleaning and EDA
-- find the total number of records in the data set
SELECT COUNT(*) FROM sql_project1.retail_sales_analysis;

-- find the total number of distinct customers in the data
SELECT COUNT(DISTINCT customer_id) FROM sql_project1.retail_sales_analysis;

-- find the total number of distinct categories in the data
SELECT COUNT(DISTINCT category) FROM sql_project1.retail_sales_analysis;
-- there are 3 distinct categories

-- find the names
SELECT DISTINCT category FROM sql_project1.retail_sales_analysis;

-- Check for null values if any; delete the records with missing values
SELECT * FROM sql_project1.retail_sales_analysis
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL 
		OR gender IS NULL OR age IS NULL OR category IS NULL OR quantity IS NULL
        OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL
;

-- This show there is no null data but still we'd like to drop the resulting data
-- if there would have been any

-- safe updates allowed
SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;
DELETE FROM sql_project1.retail_sales_analysis
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL 
      OR gender IS NULL OR age IS NULL OR category IS NULL OR quantity IS NULL
      OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

-- commit if the results are not affecting your data
COMMIT;

-- rollback if data is affected
-- ROLLBACK;

-- safe updates denied again
SET SQL_SAFE_UPDATES = 1;

-- Data Analysis & Findings

-- 1 Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT *
FROM sql_project1.retail_sales_analysis
WHERE sale_date = '2022-11-05';

-- 2 Write a SQL query to retrieve all transactions where the category is 'Clothing' 
-- and the quantity sold is more than or equal to 4 in the month of Nov-2022:
SELECT * FROM sql_project1.retail_sales_analysis
WHERE category = 'Clothing' 
	AND quantity >= 4 
    AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
;

-- 3 Write a SQL query to calculate the total transactions for each category.
SELECT category, COUNT(category)
FROM sql_project1.retail_sales_analysis
GROUP BY category;

-- 3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, 
	COUNT(category) as category_order, 
    SUM(total_sale) as total_sales_category,
    SUM(total_sale) / COUNT(category) as averge_order_price
FROM sql_project1.retail_sales_analysis
GROUP BY category;

-- 4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- we'll use window functions to show the average all the way long
SELECT customer_id, gender, 
	category, age,
	AVG(age) OVER(PARTITION BY category) as avg_age_beauty_customer
FROM sql_project1.retail_sales_analysis
WHERE category = 'Beauty';

--  Write a SQL query to find the average age of customers on the basis of gender 
-- who purchased items from the 'Beauty' category .
SELECT gender, category, ROUND(AVG(age), 2) as avg_gender_age_beauty
FROM sql_project1.retail_sales_analysis
WHERE category = 'Beauty'
GROUP BY gender;

-- 5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM sql_project1.retail_sales_analysis where total_sale > 1000;

-- 6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id) as total_orders_by_gender
FROM sql_project1.retail_sales_analysis
GROUP BY category, gender
ORDER BY category;

-- 7 Write an SQL query to calculate the average sale for each month. 
-- Find out best selling month in each year.

WITH sales_summary AS(
SELECT EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	AVG(total_sale) AS avg_sale
FROM sql_project1.retail_sales_analysis
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
), ranked_sale AS (
	SELECT *, 
		RANK() OVER(PARTITION BY year ORDER BY avg_sale DESC) as sale_rank
	FROM sales_summary
)
SELECT * 
FROM ranked_sale 
WHERE sale_rank = 1
;

-- 8 Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT customer_id, SUM(total_sale) as total_sales
FROM sql_project1.retail_sales_analysis
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- 9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, COUNT(Distinct customer_id) as unique_customer_count,
	COUNT(customer_id) as category_total_order
FROM sql_project1.retail_sales_analysis
GROUP BY category;

-- 10 Write a SQL query to create each shift and number of orders 
-- (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

-- shift design
WITH hourly_sale AS(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'AfterNoon'
        WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 'Night'
END AS shift
FROM sql_project1.retail_sales_analysis
)
SELECT shift,
	COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY total_orders DESC
;








