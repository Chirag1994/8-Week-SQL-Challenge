### 1. What are the top 3 products by total revenue before discount?

```sql
SELECT PD.product_name,
	SUM(S.price * S.qty) AS total_revenue_before_discount
FROM product_details AS PD
JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_revenue_before_discount DESC
LIMIT 3;
```

Output:

### 2. What is the total quantity, revenue and discount for each segment?

```sql
SELECT PD.segment_name,
	ROUND(SUM(S.qty),2) AS total_quantity,
    ROUND(SUM(S.qty * S.price),2) AS total_revenue_before_discount,
    ROUND(SUM((S.qty * S.price * S.discount)/100), 2) AS discount
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.segment_name;
```

Output:

### 3. What is the top selling product for each segment?

```sql
WITH segment_product_qty_sales_cte AS (
SELECT PD.segment_name, PD.product_name,
	SUM(S.qty) AS total_qty_sold
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.segment_name, PD.product_name),
	top_selling_products_cte AS (
SELECT segment_product_qty_sales_cte.segment_name, segment_product_qty_sales_cte.product_name,
	segment_product_qty_sales_cte.total_qty_sold,
    ROW_NUMBER() OVER (PARTITION BY segment_product_qty_sales_cte.segment_name
		ORDER BY segment_product_qty_sales_cte.total_qty_sold DESC)
		AS row_num FROM segment_product_qty_sales_cte)
SELECT top_selling_products_cte.segment_name, top_selling_products_cte.product_name,
top_selling_products_cte.total_qty_sold
	FROM top_selling_products_cte
WHERE row_num = 1;
```

Output:

### 4. What is the total quantity, revenue and discount for each category?

```sql
SELECT PD.category_name,
	ROUND(SUM(S.qty),2) AS total_quantity,
    ROUND(SUM(S.qty * S.price),2) AS total_revenue_before_discount,
    ROUND(SUM((S.qty * S.price * S.discount)/100), 2) AS discount
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.category_name;
```

Output:

### 5. What is the top selling product for each category?

```sql
WITH category_product_qty_sales_cte AS (
SELECT PD.category_name, PD.product_name,
	SUM(S.qty) AS total_qty_sold
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.category_name, PD.product_name),
	top_selling_products_cte AS (
SELECT category_product_qty_sales_cte.category_name, category_product_qty_sales_cte.product_name,
	category_product_qty_sales_cte.total_qty_sold,
    ROW_NUMBER() OVER (PARTITION BY category_product_qty_sales_cte.category_name
		ORDER BY category_product_qty_sales_cte.total_qty_sold DESC)
		AS row_num FROM category_product_qty_sales_cte)
SELECT top_selling_products_cte.category_name, top_selling_products_cte.product_name,
top_selling_products_cte.total_qty_sold
	FROM top_selling_products_cte
WHERE row_num = 1;
```

Output:

### 6. What is the percentage split of revenue by product for each segment?

```sql
WITH segment_product_revenue_cte AS (
SELECT PD.segment_name, PD.product_name,
	SUM(S.price * S.qty) AS segment_product_revenue
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.segment_name, PD.product_name)
SELECT segment_name, product_name,
	ROUND(100.0 * segment_product_revenue / (
		SUM(segment_product_revenue) OVER (PARTITION BY segment_name)), 2)
		AS revenue_pct
FROM segment_product_revenue_cte
ORDER BY segment_name, product_name;
```

Output:

### 7. What is the percentage split of revenue by segment for each category?

```sql
WITH category_segment_revenue_cte AS (
SELECT PD.category_name, PD.segment_name,
	SUM(S.price * S.qty) AS category_segment_revenue
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.category_name, PD.segment_name)
SELECT category_name, segment_name,
	ROUND(100.0 * category_segment_revenue / (
		SUM(category_segment_revenue) OVER (PARTITION BY category_name)), 2)
		AS revenue_pct
FROM category_segment_revenue_cte
ORDER BY category_name, segment_name;
```

Output:

### 8. What is the percentage split of total revenue by category?

```sql
WITH category_revenue_cte AS (
SELECT PD.category_name,
	SUM(S.price * S.qty) AS category_revenue
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.category_name)
SELECT category_name,
	ROUND(100.0 * category_revenue / (
		SUM(category_revenue) OVER()), 2)
		AS revenue_pct
FROM category_revenue_cte
GROUP BY category_name
ORDER BY category_name;
```

Output:

### 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql

```

Output:

### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

```sql

```

Output:
