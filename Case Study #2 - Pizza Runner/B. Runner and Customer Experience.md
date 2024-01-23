### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
	WEEK(registration_date) AS 'week',
	COUNT(runner_id) as num_of_runners
FROM runners
GROUP BY WEEK(registration_date);
```

Output:

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
WITH runners_pick_cte AS (
SELECT runner_id,
	ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)),2) AS avg_time
FROM runner_orders_temp
JOIN customer_orders_temp ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE runner_orders_temp.distance != 0
GROUP BY runner_id
)
SELECT ROUND(AVG(avg_time),0) AS avg_pick_time
FROM runners_pick_cte;
```

Output:

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH order_count_cte AS (
SELECT
	customer_orders_temp.order_id,
	COUNT(customer_orders_temp.order_id) AS pizza_order_count,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)),2) AS avg_time_to_prepare
FROM runner_orders_temp
JOIN customer_orders_temp ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.order_id
)
SELECT pizza_order_count, ROUND(AVG(avg_time_to_prepare),2) AS avg_time_to_prepare
FROM order_count_cte
GROUP BY pizza_order_count;
```

Output:

### 4. What was the average distance travelled for each customer?

```sql
SELECT
	customer_orders_temp.customer_id,
	ROUND(AVG(distance),2) as avg_distance
FROM customer_orders_temp
JOIN runner_orders_temp ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.distance != 0
GROUP BY customer_orders_temp.customer_id;
```

Output:

### 5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT (MAX(duration) - MIN(duration)) AS diff
FROM runner_orders_temp;
```

Output:

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT
	RO.runner_id, RO.order_id,
    ROUND(AVG(RO.distance/(RO.duration/60)),2) AS average_speed_in_kmph
FROM runner_orders AS RO
JOIN customer_orders AS CO ON RO.order_id = CO.order_id
WHERE RO.distance != 0
GROUP BY RO.runner_id, RO.order_id
ORDER BY RO.runner_id, RO.order_id ASC;
```

Output:

### 7. What is the successful delivery percentage for each runner?

```sql
SELECT runner_id,
(ROUND(SUM(CASE WHEN duration IS NOT NULL THEN 1 ELSE 0 END)/COUNT(runner_id),2) \* 100) AS percentage
FROM runner_orders_temp
GROUP BY runner_id;
```

Output:
