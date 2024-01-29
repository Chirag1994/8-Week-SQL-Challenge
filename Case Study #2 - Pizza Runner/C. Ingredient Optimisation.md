## DATA CLEANING pizza_recipes table

Dropping the pizza_recipes_temp table if already exists otherwise creating it.

```sql
DROP TABLE IF EXISTS pizza_recipes_temp

CREATE TEMPORARY TABLE pizza_recipes_temp AS
SELECT pizza_id, SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1) AS topping_id
FROM pizza_recipes
JOIN (SELECT 1 AS n
        UNION SELECT 2
        UNION SELECT 3
        UNION SELECT 4
        UNION SELECT 5
        UNION SELECT 6
        UNION SELECT 7
        UNION SELECT 8
        UNION SELECT 9
        UNION SELECT 10
) AS numbers ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1
ORDER BY pizza_id;
```

Output:
| pizza_id | topping_id |
|----------|------------|
| 1 | 1 |
| 1 | 2 |
| 1 | 3 |
| 1 | 4 |
| 1 | 5 |
| 1 | 6 |
| 1 | 8 |
| 1 | 10 |
| 2 | 4 |
| 2 | 6 |
| 2 | 7 |
| 2 | 9 |
| 2 | 11 |
| 2 | 12 |

Generating a unique row number to identify each record

```sql
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INT AUTO_INCREMENT PRIMARY KEY;
```

Breaking the Extras Column in Customer_Orders_Temp Table

Assuming your original table is named 'customer_orders_temp' and the column is 'extras. Create a temporary table for the exploded extras using a subquery

Dropping the extrasBreak, extrasBreak\_ tables if already exists otherwise creating them.

```sql
DROP TABLE IF EXISTS extrasBreak, extrasBreak_

CREATE TEMPORARY TABLE extrasBreak AS
SELECT record_id, TRIM(value) AS extra_id
FROM ( SELECT record_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n.digit + 1), ',', -1)) AS value
    FROM customer_orders_temp
    LEFT JOIN (
        SELECT 0 AS digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ) n ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n.digit
    WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n.digit + 1), ',', -1)) <> ''
) AS e;
```

Add rows with null or empty values

```sql
INSERT INTO extrasBreak (record_id, extra_id)
SELECT record_id, NULL AS extra_id
FROM customer_orders_temp
WHERE extras IS NULL OR TRIM(extras) = '';
```

Creating a temporary table extrasBreak\_

```sql
CREATE TABLE extrasBreak_ AS
SELECT record_id,
    CASE WHEN extra_id IS NULL THEN '' ELSE extra_id END AS extra_id
FROM extrasBreak
ORDER BY record_id, extra_id;
```

Output of extraBreak\_ table:
| record_id | extra_id |
|-----------|----------|
| 1 | |
| 2 | |
| 3 | |
| 4 | |
| 5 | |
| 6 | |
| 7 | |
| 8 | 1 |
| 9 | |
| 10 | 1 |
| 11 | |
| 12 | 1 |
| 12 | 5 |
| 13 | |
| 14 | 1 |
| 14 | 4 |

Breaking the Exclusion Column in Customer_Orders_Temp Table

Assuming your original table is named 'customer_orders_temp' and the column is 'exclusions'. Create a temporary table for the exploded exclusions using a subquery

Dropping the exclusionsBreak, exclusionsBreak\_ tables if already exists otherwise creating them.

```sql
DROP TABLE IF EXISTS exclusionsBreak, exclusionsBreak_

CREATE TEMPORARY TABLE exclusionsBreak AS
SELECT record_id, TRIM(value) AS exclusions_id
FROM ( SELECT record_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n.digit + 1), ',', -1)) AS value
    FROM customer_orders_temp
    LEFT JOIN (
        SELECT 0 AS digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ) n ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n.digit
    WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n.digit + 1), ',', -1)) <> ''
) AS e;
```

Add rows with null or empty values

```sql
INSERT INTO exclusionsBreak (record_id, exclusions_id)
SELECT record_id, NULL AS exclusions_id
FROM customer_orders_temp
WHERE exclusions IS NULL OR TRIM(exclusions) = '';
```

Creating a temporary table exclusionsBreak\_

```sql
CREATE TABLE exclusionsBreak_ AS
SELECT record_id,
    CASE WHEN exclusions_id IS NULL THEN '' ELSE exclusions_id END AS exclusions_id
FROM exclusionsBreak
ORDER BY record_id, exclusions_id;
```

Output of exclusionsBreak\_ table:
| record_id | exclusions_id |
|-----------|---------------|
| 1 | |
| 2 | |
| 3 | |
| 4 | |
| 5 | 4 |
| 6 | 4 |
| 7 | 4 |
| 8 | |
| 9 | |
| 10 | |
| 11 | |
| 12 | 4 |
| 13 | |
| 14 | 2 |
| 14 | 6 |

### 1. What are the standard ingredients for each pizza?

```sql
SELECT
	pizza_names.pizza_id,
	pizza_names.pizza_name,
    GROUP_CONCAT(DISTINCT topping_name) AS topping_name_
FROM pizza_names
JOIN pizza_recipes_temp ON pizza_names.pizza_id = pizza_recipes.pizza_id
JOIN pizza_toppings ON pizza_recipes.topping_id = pizza_toppings.topping_id
GROUP BY pizza_names.pizza_id,pizza_names.pizza_name
ORDER BY pizza_names.pizza_name;
```

Output:
| pizza_id | pizza_name | topping_name |
|----------|------------|----------------------------------------------|
| 1 | Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2 | Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |

### 2. What was the most commonly added extra?

```sql
WITH cte AS (
	SELECT order_id,
    CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1)) AS UNSIGNED) AS topping_id
FROM customer_orders
JOIN ( SELECT 1 AS n
       UNION SELECT 2
) AS numbers ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
WHERE extras IS NOT NULL
)
SELECT topping_name, COUNT(order_id) AS most_common_extras
    FROM cte JOIN pizza_toppings ON pizza_toppings.topping_id = cte.topping_id
GROUP BY topping_name LIMIT 1;
```

Output:
| topping_name | most_common_extras |
|--------------|--------------------|
| Bacon | 4 |

### 3. What was the most common exclusion?

```sql
WITH cte AS (
	SELECT order_id,
    CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1)) AS UNSIGNED) AS topping_id
FROM customer_orders
JOIN ( SELECT 1 AS n
	   UNION SELECT 2
) AS numbers ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1
WHERE exclusions IS NOT NULL
)
SELECT topping_name, COUNT(order_id) AS most_common_exclusions
FROM cte JOIN pizza_toppings ON pizza_toppings.topping_id = cte.topping_id
GROUP BY topping_name LIMIT 1;
```

Output:
| topping_name | most_common_exclusions |
|--------------|--------------------|
| Cheese | 4 |

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:

> Meat Lovers, Meat Lovers - Exclude Beef, Meat Lovers - Extra Bacon, Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers.

```sql
WITH extras_cte AS (
SELECT record_id, GROUP_CONCAT('Extra ', PT.topping_name) AS option_text
FROM extrasBreak_ AS EB JOIN pizza_toppings AS PT ON EB.extra_id = PT.topping_id GROUP BY record_id
),
exclusions_cte AS (
SELECT record_id, GROUP_CONCAT('Exclusion ', PT.topping_name) AS option_text
FROM exclusionsBreak_ AS EB JOIN pizza_toppings AS PT ON EB.exclusions_id = PT.topping_id
GROUP BY record_id
),
combined_cte AS (
SELECT * FROM extras_cte UNION SELECT * FROM exclusions_cte
),
partial_data_cte AS (
SELECT CO.record_id, CO.order_id, CO.customer_id, CO.pizza_id, CO.order_time,
	IFNULL(GROUP_CONCAT(PN.pizza_name, ' - ', option_text), '') AS pizza_details
FROM customer_orders_temp AS CO LEFT JOIN combined_cte AS CC ON CO.record_id = CC.record_id
JOIN pizza_names AS PN ON PN.pizza_id = CO.pizza_id
GROUP BY CO.record_id, CO.order_id, CO.customer_id, CO.pizza_id, CO.order_time
)
SELECT PDC.record_id, PDC.order_id, PDC.customer_id, PDC.pizza_id, PDC.order_time,
	CASE WHEN PDC.pizza_id = '1' AND pizza_details = '' THEN 'MeatLover'
		 WHEN PDC.pizza_id = '2' AND pizza_details = '' THEN 'Vegetarian' ELSE PDC.pizza_details END AS pizza_detail
FROM partial_data_cte AS PDC;
```

Output:
| record_id | order_id | customer_id | pizza_id | order_time | pizza_detail |
|-----------|----------|-------------|----------|----------------------|----------------------------------------------------------------|
| 1 | 1 | 101 | 1 | 2020-01-01 18:05:02 | MeatLover |
| 2 | 2 | 101 | 1 | 2020-01-01 19:00:52 | MeatLover |
| 3 | 3 | 102 | 1 | 2020-01-02 23:51:23 | MeatLover |
| 4 | 3 | 102 | 2 | 2020-01-02 23:51:23 | Vegetarian |
| 5 | 4 | 103 | 1 | 2020-01-04 13:23:46 | Meatlovers - Exclusion Cheese |
| 6 | 4 | 103 | 1 | 2020-01-04 13:23:46 | Meatlovers - Exclusion Cheese |
| 7 | 4 | 103 | 2 | 2020-01-04 13:23:46 | Vegetarian - Exclusion Cheese |
| 8 | 5 | 104 | 1 | 2020-01-08 21:00:29 | Meatlovers - Extra Bacon |
| 9 | 6 | 101 | 2 | 2020-01-08 21:03:13 | Vegetarian |
| 10 | 7 | 105 | 2 | 2020-01-08 21:20:29 | Vegetarian - Extra Bacon |
| 11 | 8 | 102 | 1 | 2020-01-09 23:54:33 | MeatLover |
| 12 | 9 | 103 | 1 | 2020-01-10 11:22:59 | Meatlovers - Extra Bacon, Extra Chicken, Meatlovers - Exclusion Cheese |
| 13 | 10 | 104 | 1 | 2020-01-11 18:34:49 | MeatLover |
| 14 | 10 | 104 | 1 | 2020-01-11 18:34:49 | Meatlovers - Extra Bacon, Extra Cheese, Meatlovers - Exclusion BBQ Sauce, Exclusion Mushrooms |

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the

> -- customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami".

```sql
WITH pizza_ingredients AS (
    SELECT CO.record_id, CO.order_id, CO.customer_id, CO.pizza_id, CO.order_time, PN.pizza_name,
	  CASE WHEN PT.topping_id IN (SELECT extra_id FROM extrasBreak_ AS EB1 WHERE CO.record_id = EB1.record_id)
      THEN CONCAT('2x ', PT.topping_name) ELSE PT.topping_name END AS ingredients_used
    FROM customer_orders_temp AS CO JOIN pizza_recipes_temp AS PR ON CO.pizza_id = PR.pizza_id
    JOIN pizza_toppings AS PT ON PT.topping_id = PR.topping_id
    JOIN pizza_names AS PN ON PN.pizza_id = CO.pizza_id
    WHERE PR.topping_id NOT IN (SELECT exclusions_id FROM exclusionsBreak_ AS EB2 WHERE CO.record_id = EB2.record_id)
)
SELECT PI.record_id, PI.order_id, PI.customer_id, PI.pizza_id, PI.order_time,CONCAT(PI.pizza_name, ': ',
        GROUP_CONCAT(ingredients_used ORDER BY ingredients_used)) AS ingredients_used
FROM pizza_ingredients AS PI
GROUP BY PI.record_id, PI.order_id, PI.customer_id, PI.pizza_id, PI.order_time, PI.pizza_name
ORDER BY PI.record_id, PI.order_id, PI.customer_id, PI.pizza_id, PI.order_time;
```

| record_id | order_id | customer_id | pizza_id | order_time          | ingredients_used                                                                 |
| --------- | -------- | ----------- | -------- | ------------------- | -------------------------------------------------------------------------------- |
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23 | Vegetarian: Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes                |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46 | Vegetarian: Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes                       |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29 | Meatlovers: 2x Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami    |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13 | Vegetarian: Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes                |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29 | Vegetarian: Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes                |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59 | Meatlovers: 2x Bacon,2x Chicken,BBQ Sauce,Beef,Cheese,Mushrooms,Pepperoni,Salami |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49 | Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami       |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49 | Meatlovers: 2x Bacon,2x Cheese,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami |

### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH pizza_ingredients AS (
SELECT CO.order_id, CO.customer_id, PT.topping_name,
	CASE WHEN PR.topping_id IN (SELECT extra_id FROM extrasBreak_ AS EB1 WHERE CO.record_id = EB1.record_id) THEN 2
	WHEN PR.topping_id IN (SELECT exclusions_id FROM exclusionsBreak_ AS EB2 WHERE CO.record_id = EB2.record_id) THEN 0
    ELSE 1 END AS ingredients_used
FROM customer_orders_temp AS CO JOIN pizza_recipes_temp AS PR
ON CO.pizza_id = PR.pizza_id JOIN pizza_toppings AS PT
ON PT.topping_id = PR.topping_id
)
SELECT PI.topping_name, SUM(ingredients_used) AS qty_used_of_each_ingredients FROM pizza_ingredients AS PI
GROUP BY PI.topping_name
ORDER BY PI.topping_name;
```

Output:
| topping_name | qty_used_of_each_ingredients |
|--------------|------------------------------|
| Bacon | 13 |
| BBQ Sauce | 10 |
| Beef | 10 |
| Cheese | 13 |
| Chicken | 10 |
| Mushrooms | 14 |
| Onions | 4 |
| Pepperoni | 10 |
| Peppers | 4 |
| Salami | 10 |
| Tomato Sauce | 4 |
| Tomatoes | 4 |
