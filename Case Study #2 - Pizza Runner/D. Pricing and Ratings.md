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
