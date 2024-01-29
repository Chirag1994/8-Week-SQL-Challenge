### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT
	SUM(CASE WHEN PN.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS Total_revenue
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO ON CO.order_id = RO.order_id
JOIN pizza_names AS PN ON CO.pizza_id = PN.pizza_id
WHERE RO.distance != 0;
```

Output:
| Total_revenue |
|-----------|
| 138 |

### 2. What if there was an additional $1 charge for any pizza extras? (Add cheese is $1 extra)

```sql
SELECT
	SUM(CASE WHEN pizza_name = 'Meatlovers' AND extra_one_dollar_charge = '1' THEN (12 + 1)
			WHEN pizza_name = 'Meatlovers' AND extra_one_dollar_charge = '2' THEN (12 + 2)
			WHEN pizza_name = 'Vegetarian' AND extra_one_dollar_charge = '1' THEN (10 + 1)
			WHEN pizza_name = 'Vegetarian' AND extra_one_dollar_charge = '2' THEN (10 + 2)
            END) AS Total_revenue
FROM (SELECT CO.order_id, CO.customer_id, CO.pizza_id, RO.distance,
    PN.pizza_name, (CASE WHEN extras LIKE '%4%' THEN 2 ELSE 1 END) AS extra_one_dollar_charge
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO
ON CO.order_id = RO.order_id
JOIN pizza_names AS PN
ON CO.pizza_id = PN.pizza_id
WHERE RO.distance != 0) AS temp_;
```

Output:
| Total_revenue |
|-----------|
| 151 |

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate

    -- their runner, how would you design an additional table for this new dataset - generate a schema for
    -- this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
	order_id INT,
    ratings INT
);
INSERT INTO ratings (order_id, ratings)
-- Inserting some random ratings
VALUES (1,4),
	   (2,3),
       (3,4),
       (4,1),
       (5,5),
       (7,2),
       (8,4),
       (10,3);
SELECT * FROM ratings;
```

Output:
| order_id | ratings |
|----------|---------|
| 1 | 4 |
| 2 | 3 |
| 3 | 4 |
| 4 | 1 |
| 5 | 5 |
| 7 | 2 |
| 8 | 4 |
| 10 | 3 |

### 4. Using your newly generated table - can you join all of the information together to form a table which

    -- has the following information for successful deliveries?
    -- customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup
    -- Delivery duration, Average speed, Total number of pizzas

```sql
SELECT
    CO.customer_id, CO.order_id, RO.runner_id,
    R.ratings, CO.order_time, RO.duration,
    ROUND(TIME_TO_SEC(TIMEDIFF(RO.pickup_time, CO.order_time))/60,0) AS time_between_order_and_pickup_in_minutes,
    ROUND(AVG(RO.distance/(RO.duration/60)),2) AS average_speed_in_kmph,
    COUNT(CO.order_id) AS pizza_count
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO ON CO.order_id = RO.order_id
JOIN ratings AS R ON RO.order_id = R.order_id
WHERE RO.distance != 0
GROUP BY CO.customer_id, CO.order_id, RO.runner_id, R.ratings, CO.order_time,
    RO.duration, time_between_order_and_pickup_in_minutes;
```

Output:
| customer_id | order_id | runner_id | ratings | order_time | distance | duration | time_between_order_and_pickup_in_minutes | average_speed_in_kmph | pizza_count |
|-------------|----------|-----------|---------|-----------------------|----------|----------|-------------------------------------------|-----------------------|-------------|
| 101 | 1 | 1 | 4 | 2020-01-01 18:05:02 | 32 | 11 | 37.5 | 1 | 1 |
| 101 | 2 | 1 | 3 | 2020-01-01 19:00:52 | 27 | 10 | 44.44 | 1 | 1 |
| 102 | 3 | 1 | 4 | 2020-01-02 23:51:23 | 20 | 21 | 40.2 | 2 | 2 |
| 103 | 4 | 2 | 1 | 2020-01-04 13:23:46 | 40 | 29 | 35.1 | 3 | 3 |
| 104 | 5 | 3 | 5 | 2020-01-08 21:00:29 | 15 | 10 | 40 | 1 | 1 |
| 105 | 7 | 2 | 2 | 2020-01-08 21:20:29 | 25 | 10 | 60 | 1 | 1 |
| 102 | 8 | 2 | 4 | 2020-01-09 23:54:33 | 15 | 20 | 93.6 | 1 | 1 |
| 104 | 10 | 1 | 3 | 2020-01-11 18:34:49 | 10 | 16 | 60 | 2 | 2 |

### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner

    -- is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over
    -- after these deliveries?

```sql
SELECT
    SUM(CASE WHEN PN.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS Total_revenue,
    ROUND(SUM(RO.distance) * 0.3, 2) AS runner_earned_amount,
    (SUM(CASE WHEN PN.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) - ROUND(SUM(RO.distance) * 0.3, 2))
		AS Profit_left_after_paying_to_runners
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO ON CO.order_id = RO.order_id
JOIN pizza_names AS PN ON CO.pizza_id = PN.pizza_id
WHERE RO.distance != 0;
```

Output:
| Total_revenue | runner_earned_amount | Profit_left_after_paying_to_runners |
|---------------|----------------------|--------------------------------------|
| 138 | 64.62 | 73.38 |

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
