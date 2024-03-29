## Data Cleaning

### Cleaning Customer_Orders Table

Dropping the customer_orders_temp table if already exists otherwise creating it.

```sql
DROP TABLE IF EXISTS customer_orders_temp

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
| order_id | customer_id | pizza_id | exclusions | extras | order_time |
|----------|-------------|----------|------------|--------|-----------------------|
| 1 | 101 | 1 | | | 2020-01-01 18:05:02 |
| 2 | 101 | 1 | | | 2020-01-01 19:00:52 |
| 3 | 102 | 1 | | | 2020-01-02 23:51:23 |
| 3 | 102 | 2 | | | 2020-01-02 23:51:23 |
| 4 | 103 | 1 | 4 | | 2020-01-04 13:23:46 |
| 4 | 103 | 1 | 4 | | 2020-01-04 13:23:46 |
| 4 | 103 | 2 | 4 | | 2020-01-04 13:23:46 |
| 5 | 104 | 1 | | 1 | 2020-01-08 21:00:29 |
| 6 | 101 | 2 | | | 2020-01-08 21:03:13 |
| 7 | 105 | 2 | | 1 | 2020-01-08 21:20:29 |
| 8 | 102 | 1 | | | 2020-01-09 23:54:33 |
| 9 | 103 | 1 | 4 | 1, 5 | 2020-01-10 11:22:59 |
| 10 | 104 | 1 | | | 2020-01-11 18:34:49 |
| 10 | 104 | 1 | 2, 6 | 1, 4 | 2020-01-11 18:34:49 |

### Cleaning Runner_Orders Table

Dropping the runner_orders_temp table if already exists otherwise creating it.

```sql
DROP TABLE IF EXISTS runner_orders_temp

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

Changing the Data Types of columns in runner_orders TABLE

```sql
ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration FLOAT;
```

Output:
| order_id | runner_id | pickup_time | distance | duration | cancellation |
|----------|-----------|----------------------|----------|----------|------------------------------|
| 1 | 1 | 2020-01-01 18:15:34 | 20 | 32 | |
| 2 | 1 | 2020-01-01 19:10:54 | 20 | 27 | |
| 3 | 1 | 2020-01-03 00:12:37 | 13.4 | 20 | |
| 4 | 2 | 2020-01-04 13:53:03 | 23.4 | 40 | |
| 5 | 3 | 2020-01-08 21:10:57 | 10 | 15 | |
| 6 | 3 | | | | Restaurant Cancellation |
| 7 | 2 | 2020-01-08 21:30:45 | 25 | 25 | |
| 8 | 2 | 2020-01-10 00:15:02 | 23.4 | 15 | |
| 9 | 2 | | | | Customer Cancellation |
| 10 | 1 | 2020-01-11 18:50:20 | 10 | 10 | |

### 1. How many pizzas were ordered?

```sql
SELECT COUNT(order_id) AS pizza_cnt
FROM customer_orders_temp;
```

Output:
| pizza_cnt |
|-----------|
| 14 |

#### Analysis of Total Pizzas Ordered

1. **Pizza Order Overview**:

   - A total of 14 pizzas were ordered during the period under consideration.
   - Understanding the volume of pizza orders helps in assessing demand and operational requirements for Pizza Runner.

### 2. How many unique customer orders were made?

```sql
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders_temp;
```

Output:
| unique_orders |
|-----------|
| 10 |

#### Analysis of Unique Customer Orders

1. **Insights into Customer Order Frequency**:

   - A total of 10 unique customer orders were made during the specified period.
   - Understanding the frequency of unique orders provides insights into customer engagement and the overall demand for Pizza Runner's services.

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
| runner_id | successful_delivery |
|-----------|---------------------|
| 1 | 4 |
| 2 | 3 |
| 3 | 1 |

#### Analysis of Successful Deliveries by Runners

1. **Efficiency in Order Delivery**:

   - Runner 1 completed the highest number of successful deliveries, with a total of 4 orders fulfilled.
   - Runner 2 follows closely behind, with 3 successful deliveries.
   - Runner 3 completed 1 successful delivery during the specified period.

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
| pizza_name | pizza_cnt |
|-------------|-----------|
| Meatlovers | 9 |
| Vegetarian | 3 |

#### Analysis of Pizza Deliveries by Type

1. **Distribution of Pizza Types**:

   - Meat Lovers pizza was the most frequently delivered, with a total of 9 orders fulfilled.
   - Vegetarian pizza accounted for a smaller portion of deliveries, with 3 orders fulfilled.

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
| customer_id | pizza_name | order_cnt |
|-------------|-------------|-----------|
| 101 | Meatlovers | 2 |
| 101 | Vegetarian | 1 |
| 102 | Meatlovers | 2 |
| 102 | Vegetarian | 1 |
| 103 | Meatlovers | 3 |
| 103 | Vegetarian | 1 |
| 104 | Meatlovers | 3 |
| 105 | Vegetarian | 1 |

#### Analysis of Pizza Orders by Customer

1. **Customer Pizza Preferences**:

   - Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza, indicating a preference for both varieties.
   - Similarly, Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza, suggesting a balanced preference for different pizza types.
   - Customer 103 predominantly ordered Meatlovers pizzas, with 3 orders, and also ordered 1 Vegetarian pizza, indicating a preference for meat-based options but also an interest in vegetarian choices.
   - Customer 104 ordered 3 Meatlovers pizzas, indicating a strong preference for this type, while Customer 105 ordered 1 Vegetarian pizza, suggesting a preference for meat-free options.

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
| order_id | pizza_cnt |
|----------|-----------|
| 4 | 3 |
| 3 | 2 |
| 10 | 2 |
| 1 | 1 |
| 2 | 1 |
| 5 | 1 |
| 6 | 1 |
| 7 | 1 |
| 8 | 1 |
| 9 | 1 |

#### Analysis of Maximum Pizzas Delivered in a Single Order

1. **Order Size Overview**:

   - Order ID 4 recorded the highest number of pizzas delivered in a single order, with 3 pizzas.
   - Orders 3 and 10 followed, each consisting of 2 pizzas, indicating moderate order sizes.
   - Several orders, including IDs 1, 2, 5, 6, 7, 8, and 9, were comprised of a single pizza, representing smaller order sizes.

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
| customer_id | change | no_change |
|-------------|--------|-----------|
| 101 | 0 | 2 |
| 102 | 0 | 3 |
| 103 | 3 | 0 |
| 104 | 2 | 1 |
| 105 | 1 | 0 |

#### Analysis of Pizza Orders with Changes

1. **Change vs. No Change**:

   - Customer 101 and Customer 102 placed orders without any modifications, indicating a preference for standard pizza options without exclusions or extras.
   - Customer 103 exclusively ordered pizzas with modifications, suggesting a preference for customized or personalized options tailored to specific dietary preferences or taste preferences.
   - Customer 104 had a mix of orders with and without changes, indicating a varied preference for both standard and customized pizza options.
   - Customer 105 ordered pizzas with at least one change, reflecting a preference for personalized pizza options.

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
| customer_id | pizza_with_exclusions_and_extras |
|-------------|---------------------------------|
| 104 | 1 |

#### Analysis of Pizza Orders with Both Exclusions and Extras

1. **Pizza Customization Trends**:

   - Customer 104 placed an order that included both exclusions and extras, indicating a preference for a customized pizza with specific modifications to the standard recipe.

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
| hour | order_cnt |
|------|-----------|
| 11 | 1 |
| 13 | 3 |
| 18 | 3 |
| 19 | 1 |
| 21 | 3 |
| 23 | 3 |

#### Analysis of Pizza Orders by Hour

1. **Peak Ordering Hours**:

   - Pizza orders exhibit fluctuations throughout the day, with distinct peaks during specific hours.
   - The busiest hours for pizza orders are observed between 1 PM and 3 PM, with a total volume of 3 orders during each hour.

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
| day_of_the_week | order_cnt |
|------------------|-----------|
| Wednesday | 5 |
| Thursday | 3 |
| Saturday | 5 |
| Friday | 1 |

#### Analysis of Pizza Orders by Day of the Week

1. **Weekday vs. Weekend Orders**:

   - Pizza orders exhibit variations based on the day of the week, with distinct patterns observed between weekdays and weekends.
   - Wednesdays and Saturdays emerge as the busiest days for pizza orders, with 5 orders recorded on each day.
   - Thursdays also demonstrate moderate order volume, with 3 orders placed, indicating consistent demand mid-week.
   - Fridays recorded the lowest order volume, with only 1 order registered, suggesting a dip in demand at the end of the workweek.
