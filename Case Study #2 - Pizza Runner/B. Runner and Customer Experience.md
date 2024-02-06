### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
	WEEK(registration_date) AS 'week',
	COUNT(runner_id) as num_of_runners
FROM runners
GROUP BY WEEK(registration_date);
```

Output:

| week | num_of_runners |
| ---- | -------------- |
| 0    | 1              |
| 1    | 2              |
| 2    | 1              |

#### Analysis of Runner Sign-ups by Week

1. **Weekly Runner Acquisition**:

   - Runner sign-ups fluctuate across different weeks, indicating variations in recruitment efforts and market response over time.
   - In Week 0 (starting from January 1, 2021), 1 runner signed up for Pizza Runner, marking the initial stage of recruitment.
   - Runner sign-ups increased in Week 1, with 2 new runners joining the platform, suggesting a positive response to initial marketing and recruitment initiatives.
   - However, in Week 2, the number of new sign-ups decreased to 1 runner, indicating potential challenges or fluctuations in recruitment effectiveness.

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
| avg_pickup_time |
|-----------|
| 16 |

#### Analysis of Average Pickup Time for Runners

1. **Average Pickup Time**:

   - The average pickup time for all runners is approximately 16 minutes, indicating the typical duration between order placement and runner arrival at the Pizza Runner HQ.
   - This metric provides insights into the efficiency of runner operations and the responsiveness of the delivery network in fulfilling customer orders promptly.

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
| pizza_order_cnt | avg_time_to_prepare |
|------------------|---------------------|
| 1 | 12.00 |
| 2 | 18.00 |
| 3 | 29.00 |

#### Analysis of Relationship Between Pizza Order Quantity and Preparation Time

1. **Average Preparation Time by Pizza Quantity**:

   - Orders consisting of a single pizza have an average preparation time of approximately 12 minutes.
   - Orders with two pizzas exhibit a slightly longer average preparation time, averaging around 18 minutes.
   - Orders comprising three pizzas demonstrate the longest average preparation time, with an average of 29 minutes.

2. **Potential Relationship**:

   - The analysis suggests a potential positive correlation between the quantity of pizzas in an order and the time required for preparation.
   - As the number of pizzas in an order increases, the preparation time tends to lengthen, indicating a possible relationship between order complexity and processing duration.

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
| customer_id | avg_distance |
|-------------|--------------|
| 101 | 20 |
| 102 | 16.73 |
| 103 | 23.4 |
| 104 | 10 |
| 105 | 25 |

#### Analysis of Average Distance Travelled by Customers

1. **Average Distance Travelled**:

   - Customer 101 had an average delivery distance of 20 kilometers, indicating a moderate travel distance per order.
   - Customer 102's average delivery distance was approximately 16.73 kilometers, suggesting a slightly shorter travel distance compared to Customer 101.
   - Customer 103 had the longest average delivery distance at 23.4 kilometers, indicating a greater geographical spread of delivery locations.
   - Customer 104 had a relatively shorter average delivery distance of 10 kilometers, suggesting closer proximity to Pizza Runner HQ or a more localized customer base.
   - Customer 105 had the highest average delivery distance of 25 kilometers, indicating deliveries to more distant locations or potentially serving customers across a wider geographic area.

### 5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT (MAX(duration) - MIN(duration)) AS diff
FROM runner_orders_temp;
```

Output:
| diff |
|-----------|
| 30 |

#### Analysis of Difference Between Longest and Shortest Delivery Times

1. **Delivery Time Range**:

   - The difference between the longest and shortest delivery times for all orders was 30 minutes.
   - This variability indicates fluctuations in delivery durations across different orders, reflecting diverse factors such as distance, traffic conditions, and order complexity.

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
| runner_id | order_id | average_speed_in_kmph |
|-----------|----------|------------------------|
| 1 | 1 | 37.5 |
| 1 | 2 | 44.44 |
| 1 | 3 | 40.2 |
| 1 | 10 | 60 |
| 2 | 4 | 35.1 |
| 2 | 7 | 60 |
| 2 | 8 | 93.6 |
| 3 | 5 | 40 |

#### Analysis of Average Speed for Each Runner

1. **Runner-Specific Speed Variability**:

   - The average speed for each runner varied across different deliveries, reflecting differences in route distance, traffic conditions, and delivery durations.
   - Runner 1 demonstrated varying speeds across deliveries, with average speeds ranging from 37.5 km/h to 60 km/h.
   - Runner 2 exhibited notable speed disparities, with average speeds ranging from 35.1 km/h to 93.6 km/h.
   - Runner 3 maintained a relatively consistent average speed of 40 km/h across deliveries.

### 7. What is the successful delivery percentage for each runner?

```sql
SELECT runner_id,
(ROUND(SUM(CASE WHEN duration IS NOT NULL THEN 1 ELSE 0 END)/COUNT(runner_id),2) \* 100) AS percentage
FROM runner_orders_temp
GROUP BY runner_id;
```

Output:
| runner_id | percentage |
|-----------|------------|
| 1 | 100.00 |
| 2 | 75.00 |
| 3 | 50.00 |

#### Analysis of Successful Delivery Percentage for Each Runner

1. **Runner-Specific Success Rates**:

   - Runner 1 achieved a perfect delivery success rate, with 100% of their deliveries completed successfully. This indicates consistent performance and reliability in fulfilling delivery commitments.
   - Runner 2 achieved a delivery success rate of 75%, indicating that 3 out of 4 deliveries were completed successfully. While the success rate is relatively high, there is room for improvement to enhance consistency and reliability.
   - Runner 3 achieved a delivery success rate of 50%, indicating that half of their deliveries were completed successfully. This suggests potential challenges or inconsistencies in delivery execution that may require attention.
