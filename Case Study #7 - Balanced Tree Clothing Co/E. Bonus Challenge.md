### Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table. Hint: you may want to consider using a recursive CTE to solve this problem!

Using JOINs

```sql
SELECT
		PP.product_id, PP.price,
		CONCAT(PH3.level_text, ' - ', PH1.level_text) AS product_name,
		PH2.parent_id AS category_id, PH2.id AS segment_id,
		PH3.id AS style_id, PH1.level_text AS category_name,
		PH2.level_text AS segment_name, PH3.level_text AS style_name
	FROM product_hierarchy AS PH1
	JOIN product_hierarchy AS PH2 ON PH1.id = PH2.parent_id
	JOIN product_hierarchy AS PH3 ON PH2.id = PH3.parent_id
	JOIN product_prices AS PP ON PH3.id = PP.id
	ORDER BY category_id, segment_id, style_id;
```

Using Recursive CTE

```sql
WITH RECURSIVE ProductHierarchyCTE AS (
    SELECT id, parent_id, level_text
    FROM product_hierarchy
    WHERE parent_id IS NULL

    UNION ALL

    SELECT ph.id, ph.parent_id, ph.level_text
    FROM product_hierarchy ph
    JOIN ProductHierarchyCTE p ON ph.parent_id = p.id
)
	SELECT PP.product_id, PP.price,
		CONCAT(PHC3.level_text, ' - ', PHC1.level_text) AS product_name,
		PHC2.id AS category_id, PHC2.parent_id AS segment_id,
		PHC3.id AS style_id, PHC1.level_text AS category_name,
		PHC2.level_text AS segment_name, PHC3.level_text AS style_name
	FROM ProductHierarchyCTE PHC1
	JOIN ProductHierarchyCTE PHC2 ON PHC1.id = PHC2.parent_id
	JOIN ProductHierarchyCTE PHC3 ON PHC2.id = PHC3.parent_id
	JOIN product_prices PP ON PHC3.id = PP.id
	ORDER BY category_id, segment_id, style_id;
```

Output:
| product_id | price | product_name | category_id | segment_id | style_id | category_name | segment_name | style_name |
|------------|-------|-----------------------------------|-------------|------------|----------|---------------|--------------|----------------------|
| c4a632 | 13 | Navy Oversized Jeans - Womens | 1 | 3 | 7 | Womens | Jeans | Navy Oversized |
| e83aa3 | 32 | Black Straight Jeans - Womens | 1 | 3 | 8 | Womens | Jeans | Black Straight |
| e31d39 | 10 | Cream Relaxed Jeans - Womens | 1 | 3 | 9 | Womens | Jeans | Cream Relaxed |
| d5e9a6 | 23 | Khaki Suit Jacket - Womens | 1 | 4 | 10 | Womens | Jacket | Khaki Suit |
| 72f5d4 | 19 | Indigo Rain Jacket - Womens | 1 | 4 | 11 | Womens | Jacket | Indigo Rain |
| 9ec847 | 54 | Grey Fashion Jacket - Womens | 1 | 4 | 12 | Womens | Jacket | Grey Fashion |
| 5d267b | 40 | White Tee Shirt - Mens | 2 | 5 | 13 | Mens | Shirt | White Tee |
| c8d436 | 10 | Teal Button Up Shirt - Mens | 2 | 5 | 14 | Mens | Shirt | Teal Button Up |
| 2a2353 | 57 | Blue Polo Shirt - Mens | 2 | 5 | 15 | Mens | Shirt | Blue Polo |
| f084eb | 36 | Navy Solid Socks - Mens | 2 | 6 | 16 | Mens | Socks | Navy Solid |
| b9a74d | 17 | White Striped Socks - Mens | 2 | 6 | 17 | Mens | Socks | White Striped |
| 2feb6b | 29 | Pink Fluro Polkadot Socks - Mens | 2 | 6 | 18 | Mens | Socks | Pink Fluro Polkadot |
