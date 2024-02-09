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
| product_name | total_revenue_before_discount |
|-------------------------------------|-------------------------------|
| Blue Polo Shirt - Mens | 217683 |
| Grey Fashion Jacket - Womens | 209304 |
| White Tee Shirt - Mens | 152000 |

#### Analysis of

1. **Insights**:

   -

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
| segment_name | total_quantity | total_revenue_before_discount | total_revenue_after_discount |
|--------------|-----------------|-------------------------------|------------------------------|
| Jeans | 11349 | 208350 | 25343.97 |
| Shirt | 11265 | 406143 | 49594.27 |
| Socks | 11217 | 307977 | 37013.44 |
| Jacket | 11385 | 366983 | 44277.46 |

#### Analysis of

1. **Insights**:

   -

### 3. What is the top selling product for each segment?

```sql
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
```

Output:
| segment_name | product_name | total_qty_sold |
|--------------|------------------------------------|-----------------|
| Jacket | Grey Fashion Jacket - Womens | 3876 |
| Jeans | Navy Oversized Jeans - Womens | 3856 |
| Shirt | Blue Polo Shirt - Mens | 3819 |
| Socks | Navy Solid Socks - Mens | 3792 |

#### Analysis of

1. **Insights**:

   -

### 4. What is the total quantity, revenue and discount for each category?

```sql
SELECT PD.category_name,
	ROUND(SUM(S.qty),2) AS total_quantity,
    ROUND(SUM(S.qty * S.price),2) AS total_revenue_before_discount,
    ROUND(SUM((S.qty * S.price * S.discount)/100), 2) AS discount
FROM product_details AS PD
JOIN sales AS S
ON PD.product_id = S.prod_id
GROUP BY PD.category_name;
```

Output:
| category_name | total_quantity | total_revenue_before_discount | discount |
|---------------|----------------|-------------------------------|-------------|
| Womens | 22734 | 575333 | 69621.43 |
| Mens | 22482 | 714120 | 86607.71 |

#### Analysis of

1. **Insights**:

   -

### 5. What is the top selling product for each category?

```sql
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
```

Output:
| category_name | product_name | total_qty_sold |
|---------------|--------------------------------|----------------|
| Mens | Blue Polo Shirt - Mens | 3819 |
| Womens | Grey Fashion Jacket - Womens | 3876 |

#### Analysis of

1. **Insights**:

   -

### 6. What is the percentage split of revenue by product for each segment?

```sql
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
```

Output:
| segment_name | product_name | revenue_pct |
|--------------|----------------------------------------|-------------|
| Jacket | Grey Fashion Jacket - Womens | 57.03 |
| Jacket | Indigo Rain Jacket - Womens | 19.45 |
| Jacket | Khaki Suit Jacket - Womens | 23.51 |
| Jeans | Black Straight Jeans - Womens | 58.15 |
| Jeans | Cream Relaxed Jeans - Womens | 17.79 |
| Jeans | Navy Oversized Jeans - Womens | 24.06 |
| Shirt | Blue Polo Shirt - Mens | 53.60 |
| Shirt | Teal Button Up Shirt - Mens | 8.98 |
| Shirt | White Tee Shirt - Mens | 37.43 |
| Socks | Navy Solid Socks - Mens | 44.33 |
| Socks | Pink Fluro Polkadot Socks - Mens | 35.50 |
| Socks | White Striped Socks - Mens | 20.18 |

#### Analysis of

1. **Insights**:

   -

### 7. What is the percentage split of revenue by segment for each category?

```sql
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
```

Output:
| category_name | segment_name | revenue_pct |
|---------------|--------------|-------------|
| Mens | Shirt | 56.87 |
| Mens | Socks | 43.13 |
| Womens | Jacket | 63.79 |
| Womens | Jeans | 36.21 |

#### Analysis of

1. **Insights**:

   -

### 8. What is the percentage split of total revenue by category?

```sql
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
```

Output:
| category_name | revenue_pct |
|---------------|-------------|
| Mens | 55.38 |
| Womens | 44.62 |

#### Analysis of

1. **Insights**:

   -

### 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql
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
```

Output:
| product_name | product_penetration |
|-----------------------------------|---------------------|
| Navy Solid Socks - Mens | 51.24 |
| Grey Fashion Jacket - Womens | 51.00 |
| Navy Oversized Jeans - Womens | 50.96 |
| Blue Polo Shirt - Mens | 50.72 |
| White Tee Shirt - Mens | 50.72 |
| Pink Fluro Polkadot Socks - Mens | 50.32 |
| Indigo Rain Jacket - Womens | 50.00 |
| Khaki Suit Jacket - Womens | 49.88 |
| Black Straight Jeans - Womens | 49.84 |
| Cream Relaxed Jeans - Womens | 49.72 |
| White Striped Socks - Mens | 49.72 |
| Teal Button Up Shirt - Mens | 49.68 |

#### Analysis of

1. **Insights**:

   -

### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

```sql
WITH products_per_transaction AS (
    SELECT s.txn_id, pd.product_id, pd.product_name, s.qty,
        COUNT(pd.product_id) OVER (PARTITION BY txn_id) AS cnt
    FROM sales s
    JOIN product_details pd ON s.prod_id = pd.product_id
), combinations AS (
    SELECT
        GROUP_CONCAT(product_id ORDER BY product_id) AS product_ids,
        GROUP_CONCAT(product_name ORDER BY product_id) AS product_names
    FROM products_per_transaction
    WHERE cnt = 3
    GROUP BY txn_id
), combination_count AS (
    SELECT product_ids, product_names, COUNT(*) AS common_combinations
    FROM combinations
    GROUP BY product_ids, product_names
) SELECT product_ids, product_names
FROM combination_count
WHERE common_combinations = (SELECT MAX(common_combinations) FROM combination_count);

```

Output:
| Product IDs | Product Names |
|----------------------------------|-----------------------------------------------------------------|
| 5d267b,c4a632,e31d39 | White Tee Shirt - Mens, Navy Oversized Jeans - Womens, Cream Relaxed Jeans - Womens |
| b9a74d,c4a632,d5e9a6 | White Striped Socks - Mens, Navy Oversized Jeans - Womens, Khaki Suit Jacket - Womens |
| 2a2353,2feb6b,c4a632 | Blue Polo Shirt - Mens, Pink Fluro Polkadot Socks - Mens, Navy Oversized Jeans - Womens |
| 5d267b,c4a632,e83aa3 | White Tee Shirt - Mens, Navy Oversized Jeans - Womens, Black Straight Jeans - Womens |
| c4a632,c8d436,e83aa3 | Navy Oversized Jeans - Womens, Teal Button Up Shirt - Mens, Black Straight Jeans - Womens |

#### Analysis of

1. **Insights**:

   -
