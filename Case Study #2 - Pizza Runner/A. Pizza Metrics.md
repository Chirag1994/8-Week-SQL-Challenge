## Data Cleaning

### Cleaning Customer_Orders Table

Dropping table if already exists

```sql
DROP TABLE IF EXISTS customer_orders_temp;
```

Creating a temporary table customer_orders_temp

```sql
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id, customer_id, pizza_id,
CASE WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
ELSE exclusions END AS exclusions,
CASE WHEN extras IS NULL OR extras LIKE 'null' THEN ''
ELSE extras END AS extras,
order_time
FROM customer_orders;
```

Output:

### Cleaning Runner_Orders Table

Dropping table if already exists

```sql
DROP TABLE IF EXISTS runner_orders_temp;
```

Creating a temporary table runner_orders_temp

```sql
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT order_id, runner_id,
    CAST(CASE WHEN pickup_time LIKE "null" THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
    CAST(CASE WHEN distance LIKE "null" THEN NULL WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
    ELSE distance END AS FLOAT) AS distance,
CAST(CASE WHEN duration LIKE "null" THEN NULL
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
    WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
    WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
    ELSE duration END AS FLOAT) AS duration,
    CASE WHEN cancellation IN ('', 'null', 'NaN') THEN NULL
    ELSE cancellation END AS cancellation
FROM runner_orders;
```

Output:

Changing the Data Types of columns in runner_orders TABLE

```sql
ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration FLOAT;
```

### 1. How many pizzas were ordered?

```sql
SELECT COUNT(order_id) AS pizza_cnt
FROM customer_orders_temp;
```

Output:

### 2. How many unique customer orders were made?

```sql
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders_temp;
```

Output:

### 3. How many successful orders were delivered by each runner?

```sql
SELECT
	runner_id,
	COUNT(order_id) AS `successful_delivery`
FROM runner_orders
WHERE distance != 0
GROUP BY runner_id;
```

Output:

### 4. How many of each type of pizza was delivered?

```sql
SELECT
	pizza_name,
	COUNT(runner_orders_temp.order_id) as pizza_cnt
FROM customer_orders_temp
JOIN runner_orders_temp ON customer_orders_temp.order_id = runner_orders_temp.order_id
JOIN pizza_names ON pizza_names.pizza_id = customer_orders_temp.pizza_id
WHERE distance != 0
GROUP BY pizza_name;
```

Output:

### 5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT
	customer_id,
    pizza_name,
    COUNT(order_id) as order_cnt
FROM customer_orders_temp
JOIN pizza_names ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name;
```

Output:

### 6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT customer_orders_temp.order_id,
		COUNT(runner_orders_temp.order_id) as pizza_cnt
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
GROUP BY customer_orders_temp.order_id
ORDER BY pizza_cnt DESC;
```

Output:

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT
	customer_orders_temp.customer_id,
    SUM(CASE WHEN exclusions <> '' OR extras <> '' THEN 1 ELSE 0 END) AS 'Change',
    SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS 'No_Change'
FROM customer_orders_temp
JOIN runner_orders_temp ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.distance != 0
GROUP BY customer_orders_temp.customer_id;
```

Output:

### 8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT
	customer_orders_temp.customer_id,
    SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END)
		AS 'pizza_with_exclusions_and_extras'
FROM customer_orders_temp
JOIN runner_orders_temp ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL AND exclusions != '' AND extras != ''
GROUP BY customer_orders_temp.customer_id
ORDER BY SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END)  DESC;
```

Output:

### 9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT
	HOUR(order_time) as 'hour',
    COUNT(order_id)
FROM customer_orders_temp
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);
```

Output:

### 10. What was the volume of orders for each day of the week?

```sql
SELECT
	DAYNAME(order_time) as 'day_of_the_week',
    COUNT(order_id)
FROM customer_orders_temp
GROUP BY DAYNAME(order_time)
ORDER BY DAYNAME(order_time) DESC;
```

Output:
