USE balanced_tree;

/* High Level Sales Analysis */

-- 1. What was the total quantity sold for all products?
	
    -- Total quantity sold from all the products is given by the following query:
	SELECT 
		SUM(qty) AS total_quantity_sold 
	FROM sales;
	
    -- Total quantity sold for all the products is given by the following query:
    SELECT 
		PD.product_name, SUM(S.qty) AS total_quantity_sold
    FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
    GROUP BY PD.product_name
    ORDER BY total_quantity_sold DESC;

-- 2. What is the total generated revenue for all products before discounts?
	
    -- Total revenue before discounts
    SELECT 
		SUM(qty * price) AS total_revenue 
	FROM sales;
    
    -- Total revenue before discounts for all the products
    SELECT 
		PD.product_name, SUM(S.qty * S.price) AS total_revenue
    FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
    GROUP BY PD.product_name
    ORDER BY total_revenue DESC;

-- 3. What was the total discount amount for all products?
	
    -- Total discount given is given by
    SELECT 
		ROUND(SUM((qty*price*discount)/100),2) AS total_discount 
	FROM sales;
	
    -- Total discount for all the products is given by
	SELECT 
		PD.product_name, ROUND(SUM((S.qty*S.price*S.discount)/100),2) AS total_discount
    FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
    GROUP BY PD.product_name
    ORDER BY total_discount DESC;
    
/* Transaction Analysis */

-- 1. How many unique transactions were there?
SELECT
	COUNT(DISTINCT txn_id) AS unique_number_of_transactions
FROM sales;

-- 2. What is the average unique products purchased in each transaction?
SELECT
	ROUND(AVG(unique_products_purchased),0) AS avg_unique_products_purchased
FROM (
	SELECT txn_id,
		COUNT(DISTINCT prod_id) AS unique_products_purchased
	FROM sales
	GROUP BY txn_id
) AS unique_products_count;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue_per_transaction AS (
	SELECT
		S.txn_id,
		SUM(S.qty * S.price) AS total_revenue
 	FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
 	GROUP BY S.txn_id
 	ORDER BY S.txn_id
)
SELECT
	MAX(CASE WHEN percentile_group = 1 THEN total_revenue END) AS percentile_25,
    MAX(CASE WHEN percentile_group = 2 THEN total_revenue END) AS percentile_50,
    MAX(CASE WHEN percentile_group = 3 THEN total_revenue END) AS percentile_75
FROM (
	SELECT
		txn_id,
		total_revenue,
		NTILE(4) OVER (ORDER BY total_revenue) as percentile_group
    FROM revenue_per_transaction
	) AS percentile_groups;
  
-- 4. What is the average discount value per transaction?
SELECT
	ROUND(AVG(discount_value),1) AS avg_discount_value
FROM (
	SELECT
		txn_id,
		ROUND(SUM((price * qty * discount)/100),0) AS discount_value
	FROM sales
	GROUP BY txn_id
	) AS discount_table;

-- 5. What is the percentage split of all transactions for members vs non-members?
SELECT
	ROUND(100.0 * (COUNT(DISTINCT CASE WHEN member = 't' THEN txn_id ELSE 0 END))
		/(SELECT COUNT(DISTINCT txn_id)  FROM sales),2) As member_transaction_pct,
	ROUND(100.0 * (COUNT(DISTINCT CASE WHEN member = 'f' THEN txn_id ELSE 0 END))
		/(SELECT COUNT(DISTINCT txn_id)  FROM sales),2) As non_member_transaction_pct
FROM sales;

-- 6. What is the average revenue for member transactions and non-member transactions?
WITH member_transactions_cte AS (
	SELECT
		member,
		txn_id,
		SUM(qty*price) AS avg_revenue
	FROM sales GROUP BY member,txn_id
	)
	SELECT
		member,
		ROUND(AVG(avg_revenue),2) AS avg_member_transactions
	FROM member_transactions_cte
	GROUP BY member;

/* Product Analysis */

-- 1. What are the top 3 products by total revenue before discount?
SELECT PD.product_name,
	SUM(S.price * S.qty) AS total_revenue_before_discount
FROM product_details AS PD
JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_revenue_before_discount DESC
LIMIT 3;

-- 2. What is the total quantity, revenue and discount for each segment?
SELECT PD.segment_name,
	ROUND(SUM(S.qty),2) AS total_quantity,
    ROUND(SUM(S.qty * S.price),2) AS total_revenue_before_discount,
    ROUND(SUM((S.qty * S.price * S.discount)/100), 2) AS discount
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.segment_name;

-- 3. What is the top selling product for each segment?
WITH segment_product_qty_sales_cte AS (
	SELECT 
		PD.segment_name, PD.product_name,
		SUM(S.qty) AS total_qty_sold
	FROM product_details AS PD JOIN sales AS S 
	ON PD.product_id = S.prod_id
	GROUP BY PD.segment_name, PD.product_name
	),
	top_selling_products_cte AS (
	SELECT 
		segment_product_qty_sales_cte.segment_name, 
		segment_product_qty_sales_cte.product_name,
		segment_product_qty_sales_cte.total_qty_sold,
    ROW_NUMBER() OVER (PARTITION BY segment_product_qty_sales_cte.segment_name
		ORDER BY segment_product_qty_sales_cte.total_qty_sold DESC) AS row_num 
	FROM segment_product_qty_sales_cte
	)
	SELECT 
		top_selling_products_cte.segment_name, 
		top_selling_products_cte.product_name,
		top_selling_products_cte.total_qty_sold
	FROM top_selling_products_cte
	WHERE row_num = 1;
    
-- 4. What is the total quantity, revenue and discount for each category?
SELECT PD.category_name,
	ROUND(SUM(S.qty),2) AS total_quantity,
    ROUND(SUM(S.qty * S.price),2) AS total_revenue_before_discount,
    ROUND(SUM((S.qty * S.price * S.discount)/100), 2) AS discount
FROM product_details AS PD 
JOIN sales AS S 
ON PD.product_id = S.prod_id
GROUP BY PD.category_name;

-- 5. What is the top selling product for each category?
WITH category_product_qty_sales_cte AS (
	SELECT 
		PD.category_name, 
		PD.product_name,
		SUM(S.qty) AS total_qty_sold
	FROM product_details AS PD 
	JOIN sales AS S 
	ON PD.product_id = S.prod_id
	GROUP BY PD.category_name, PD.product_name
	),
	top_selling_products_cte AS (
	SELECT 
		category_product_qty_sales_cte.category_name, 
		category_product_qty_sales_cte.product_name,
		category_product_qty_sales_cte.total_qty_sold,
    ROW_NUMBER() OVER (PARTITION BY category_product_qty_sales_cte.category_name
		ORDER BY category_product_qty_sales_cte.total_qty_sold DESC) AS row_num 
	FROM category_product_qty_sales_cte
	)
	SELECT 
		top_selling_products_cte.category_name, 
		top_selling_products_cte.product_name,
	top_selling_products_cte.total_qty_sold
	FROM top_selling_products_cte
	WHERE row_num = 1;

-- 6. What is the percentage split of revenue by product for each segment?
WITH segment_product_revenue_cte AS (
	SELECT
		PD.segment_name,
		PD.product_name,
		SUM(S.price * S.qty) AS segment_product_revenue
	FROM product_details AS PD
	JOIN sales AS S
	ON PD.product_id = S.prod_id
	GROUP BY PD.segment_name, PD.product_name
	)
	SELECT
		segment_name,
		product_name,
		ROUND(100.0 * segment_product_revenue / (
			SUM(segment_product_revenue) OVER
			(PARTITION BY segment_name)), 2) AS revenue_pct
	FROM segment_product_revenue_cte
	ORDER BY segment_name, product_name;

-- 7. What is the percentage split of revenue by segment for each category?
WITH category_segment_revenue_cte AS (
	SELECT
		PD.category_name,
		PD.segment_name,
		SUM(S.price * S.qty) AS category_segment_revenue
	FROM product_details AS PD
	JOIN sales AS S
	ON PD.product_id = S.prod_id
	GROUP BY PD.category_name, PD.segment_name
	)
	SELECT
		category_name,
		segment_name,
		ROUND(100.0 * category_segment_revenue / (
			SUM(category_segment_revenue) OVER
			(PARTITION BY category_name)), 2) AS revenue_pct
	FROM category_segment_revenue_cte
	ORDER BY category_name, segment_name;

-- 8. What is the percentage split of total revenue by category?
WITH category_revenue_cte AS (
	SELECT 
		PD.category_name,
		SUM(S.price * S.qty) AS category_revenue
	FROM product_details AS PD 
	JOIN sales AS S 
	ON PD.product_id = S.prod_id
	GROUP BY PD.category_name
	)
	SELECT category_name,
		ROUND(100.0 * category_revenue / (
			SUM(category_revenue) OVER()), 2) AS revenue_pct
	FROM category_revenue_cte
	GROUP BY category_name
	ORDER BY category_name;

-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions 
	-- where at least 1 quantity of a product was purchased divided by total number of transactions)
WITH product_transactions AS (
	SELECT 
		PD.product_name,
		COUNT(DISTINCT S.txn_id) AS product_transactions,
    	(SELECT 
			COUNT(DISTINCT txn_id) 
		FROM sales) AS total_number_of_transactions
	FROM product_details AS PD 
	JOIN sales AS S 
	ON PD.product_id = S.prod_id
	GROUP BY PD.product_name
	)
	SELECT 
		product_name,
		ROUND(100.0 * (product_transactions/total_number_of_transactions),2) AS product_penetration
	FROM product_transactions
	ORDER BY product_penetration DESC;

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?


/* Reporting Challenge */

/* Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced 
   Tree team can run at the beginning of each month to calculate the previous month’s values.
   Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end 
   of every month.
   He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can 
   easily run the same analysis for February without many changes (if at all).
   Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference 
   which table outputs relate to which question for full marks :) */

/* Bonus Challenge */
/* Use a single SQL query to transform the product_hierarchy and product_prices datasets to 
   the product_details table.
   Hint: you may want to consider using a recursive CTE to solve this problem! */