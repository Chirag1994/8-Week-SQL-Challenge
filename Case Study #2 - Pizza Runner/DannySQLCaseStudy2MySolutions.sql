USE pizza_runner;
/* ---------------------- Data Cleaning/Transformations --------------------- */
-- Cleaning Customer_Orders Table
-- Dropping table if already exists
DROP TABLE IF EXISTS customer_orders_temp;
-- Creating a temporary table customer_orders_temp
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id, customer_id, pizza_id,
    CASE WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
		ELSE exclusions END AS exclusions,
	CASE WHEN extras IS NULL OR extras LIKE 'null' THEN ''
		ELSE extras END AS extras,
	order_time
    FROM customer_orders;
    
-- Cleaning Runner_Orders Table
-- Dropping table if already exists
DROP TABLE IF EXISTS runner_orders_temp;
-- Creating a temporary table runner_orders_temp
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
    
-- Changing the Data Types of columns in runner_orders TABLE
ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration FLOAT;

/* ---------------------- A. Pizza Metrics --------------------- */
-- 1. How many pizzas were ordered?
SELECT COUNT(order_id) AS pizza_cnt
FROM customer_orders_temp;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders_temp;

-- 3. How many successful orders were delivered by each runner?
SELECT 
	runner_id,
	COUNT(order_id) AS `successful_delivery`
FROM runner_orders
WHERE distance != 0
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT 
	pizza_name,
	COUNT(runner_orders_temp.order_id) as pizza_cnt
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
JOIN pizza_names
ON pizza_names.pizza_id = customer_orders_temp.pizza_id
WHERE distance != 0
GROUP BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	customer_id,
    pizza_name,
    COUNT(order_id) as order_cnt
FROM customer_orders_temp
JOIN pizza_names
ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT customer_orders_temp.order_id,
		COUNT(runner_orders_temp.order_id) as pizza_cnt
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
GROUP BY customer_orders_temp.order_id
ORDER BY pizza_cnt DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	customer_orders_temp.customer_id,
    SUM(CASE WHEN exclusions <> '' OR extras <> '' THEN 1 ELSE 0 END) AS 'Change',
    SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS 'No_Change'
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.distance != 0
GROUP BY customer_orders_temp.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
	customer_orders_temp.customer_id,
    SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END) 
		AS 'pizza_with_exclusions_and_extras'
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.pickup_time IS NOT NULL AND exclusions != '' AND extras != ''
GROUP BY customer_orders_temp.customer_id
ORDER BY SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END)  DESC;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
	HOUR(order_time) as 'hour',
    COUNT(order_id)
FROM customer_orders_temp
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT 
	DAYNAME(order_time) as 'day_of_the_week',
    COUNT(order_id)
FROM customer_orders_temp
GROUP BY DAYNAME(order_time)
ORDER BY DAYNAME(order_time) DESC;

/* ---------------------- B. Runner and Customer Experience --------------------- */
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	WEEK(registration_date) AS 'week',
	COUNT(runner_id) as num_of_runners
FROM runners
GROUP BY WEEK(registration_date);

-- 2. What was the average time in minutes it took for each runner to arrive at the 
	-- Pizza Runner HQ to pickup the order?
WITH runners_pick_cte AS (
SELECT runner_id,
	ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)),2) AS avg_time
FROM runner_orders_temp
JOIN customer_orders_temp
ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE runner_orders_temp.distance != 0
GROUP BY runner_id)

SELECT ROUND(AVG(avg_time),0) AS avg_pick_time
FROM runners_pick_cte;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH order_count_cte AS (
SELECT 
	customer_orders_temp.order_id,
	COUNT(customer_orders_temp.order_id) AS pizza_order_count,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)),2) AS avg_time_to_prepare
FROM runner_orders_temp
JOIN customer_orders_temp
ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_orders_temp.order_id
)
SELECT pizza_order_count, ROUND(AVG(avg_time_to_prepare),2) AS avg_time_to_prepare
FROM order_count_cte
GROUP BY pizza_order_count;

-- 4. What was the average distance travelled for each customer?
SELECT 
	customer_orders_temp.customer_id,
	ROUND(AVG(distance),2) as avg_distance
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE runner_orders_temp.distance != 0
GROUP BY customer_orders_temp.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT (MAX(duration) - MIN(duration)) AS diff
FROM runner_orders_temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
	RO.runner_id, RO.order_id, 
    ROUND(AVG(RO.distance/(RO.duration/60)),2) AS average_speed_in_kmph
FROM runner_orders AS RO
JOIN customer_orders AS CO
ON RO.order_id = CO.order_id
WHERE RO.distance != 0
GROUP BY RO.runner_id, RO.order_id
ORDER BY RO.runner_id, RO.order_id ASC;

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id,
	(ROUND(SUM(CASE WHEN duration IS NOT NULL THEN 1 ELSE 0 END)/COUNT(runner_id),2) * 100) AS percentage
FROM runner_orders_temp
GROUP BY runner_id;

/* ---------------------- C. Ingredient Optimisation --------------------- */ 
/* ---------------------- DATA CLEANING pizza_recipes table --------------------- */ 
DROP TABLE IF EXISTS pizza_recipes_temp;
-- Create Temporary Table 
CREATE TEMPORARY TABLE pizza_recipes_temp AS 
SELECT pizza_id, SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1) AS topping_id
FROM pizza_recipes
JOIN (
    SELECT 1 AS n
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

-- Generating a unique row number to identify each record
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INT AUTO_INCREMENT PRIMARY KEY;

/* -------------- Breaking the Extras Column in Customer_Orders_Temp Table -------------- */
-- Dropping extrasBreak table if exists already.
DROP TABLE IF EXISTS extrasBreak;
-- Assuming your original table is named 'customer_orders_temp' and the column is 'extras'
-- Create a temporary table for the exploded extras using a subquery
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

-- Add rows with null or empty values
INSERT INTO extrasBreak (record_id, extra_id)
SELECT record_id, NULL AS extra_id
FROM customer_orders_temp
WHERE extras IS NULL OR TRIM(extras) = '';

-- Select the final result
CREATE TABLE extrasBreak_ AS
SELECT record_id,
    CASE WHEN extra_id IS NULL THEN '' ELSE extra_id END AS extra_id
FROM extrasBreak
ORDER BY record_id, extra_id;
/** --------------------------------------- */

/* -------------- Breaking the Exclusion Column in Customer_Orders_Temp Table -------------- */
-- Dropping exclusionsBreak table if exists already.
DROP TABLE IF EXISTS exclusionsBreak;
-- Assuming your original table is named 'customer_orders_temp' and the column is 'exclusions'
-- Create a temporary table for the exploded exclusions using a subquery
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

-- Add rows with null or empty values
INSERT INTO exclusionsBreak (record_id, exclusions_id)
SELECT record_id, NULL AS exclusions_id
FROM customer_orders_temp
WHERE exclusions IS NULL OR TRIM(exclusions) = '';

-- Select the final result
CREATE TABLE exclusionsBreak_ AS
SELECT record_id,
    CASE WHEN exclusions_id IS NULL THEN '' ELSE exclusions_id END AS exclusions_id
FROM exclusionsBreak
ORDER BY record_id, exclusions_id;
/** --------------------------------------- */

-- 1. What are the standard ingredients for each pizza?
SELECT 
	pizza_names.pizza_id,
	pizza_names.pizza_name,
    GROUP_CONCAT(DISTINCT topping_name) AS topping_name_
FROM pizza_names
JOIN pizza_recipes_temp ON pizza_names.pizza_id = pizza_recipes.pizza_id
JOIN pizza_toppings ON pizza_recipes.topping_id = pizza_toppings.topping_id
GROUP BY pizza_names.pizza_id,pizza_names.pizza_name
ORDER BY pizza_names.pizza_name;

-- 2. What was the most commonly added extra?
WITH cte AS (SELECT
    order_id,
    CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1)) AS UNSIGNED) AS topping_id
FROM 
    customer_orders
JOIN (
    SELECT 1 AS n
    UNION SELECT 2
    -- Add more numbers if needed
) AS numbers ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
WHERE
    extras IS NOT NULL
)
SELECT topping_name,
	COUNT(order_id) AS most_common_extras
    FROM cte
JOIN pizza_toppings ON pizza_toppings.topping_id = cte.topping_id
GROUP BY topping_name
LIMIT 1; 

-- 3. What was the most common exclusion?
WITH cte AS (SELECT
    order_id,
    CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1)) AS UNSIGNED) AS topping_id
FROM
    customer_orders
JOIN (
    SELECT 1 AS n
    UNION SELECT 2
    -- Add more numbers if needed
) AS numbers ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1
WHERE
    exclusions IS NOT NULL
)
SELECT topping_name,
	COUNT(order_id) AS most_common_exclusions
    FROM cte
JOIN pizza_toppings ON pizza_toppings.topping_id = cte.topping_id
GROUP BY topping_name
LIMIT 1; 

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	-- Meat Lovers
	-- Meat Lovers - Exclude Beef
	-- Meat Lovers - Extra Bacon
	-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
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

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the 
	-- customer_orders table and add a 2x in front of any relevant ingredients.
	-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
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

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
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

/* ---------------------- D. Pricing and Ratings --------------------- */  
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much
	--  money has Pizza Runner made so far if there are no delivery fees?
SELECT 
	SUM(CASE WHEN PN.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS Total_revenue
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO
ON CO.order_id = RO.order_id
JOIN pizza_names AS PN
ON CO.pizza_id = PN.pizza_id
WHERE RO.distance != 0;

-- 2. What if there was an additional $1 charge for any pizza extras? (Add cheese is $1 extra)
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

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate 
	-- their runner, how would you design an additional table for this new dataset - generate a schema for 
    -- this new table and insert your own data for ratings for each successful customer order between 1 to 5.
   
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

-- 4. Using your newly generated table - can you join all of the information together to form a table which 
	-- has the following information for successful deliveries?
	-- customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup
	-- Delivery duration, Average speed, Total number of pizzas
SELECT 
    CO.customer_id, CO.order_id, RO.runner_id,
    R.ratings, CO.order_time, RO.duration,
    ROUND(TIME_TO_SEC(TIMEDIFF(RO.pickup_time, CO.order_time))/60,0) AS time_between_order_and_pickup_in_minutes,
    ROUND(AVG(RO.distance/(RO.duration/60)),2) AS average_speed_in_kmph,
    COUNT(CO.order_id) AS pizza_count
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO
ON CO.order_id = RO.order_id
JOIN ratings AS R
ON RO.order_id = R.order_id
WHERE RO.distance != 0
GROUP BY CO.customer_id, CO.order_id, RO.runner_id, R.ratings, CO.order_time, 
    RO.duration, time_between_order_and_pickup_in_minutes;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner 
	-- is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over 
	-- after these deliveries?
SELECT 
    SUM(CASE WHEN PN.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS Total_revenue,
    ROUND(SUM(RO.distance) * 0.3, 2) AS runner_earned_amount,
    (SUM(CASE WHEN PN.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) - ROUND(SUM(RO.distance) * 0.3, 2))
		AS Profit_left_after_paying_to_runners
FROM customer_orders_temp AS CO
JOIN runner_orders_temp AS RO ON CO.order_id = RO.order_id
JOIN pizza_names AS PN ON CO.pizza_id = PN.pizza_id
WHERE RO.distance != 0;

/* ---------------------- E. Bonus Questions --------------------- */ 
/* If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings 
was added to the Pizza Runner menu? */
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

ALTER TABLE pizza_recipes
MODIFY COLUMN toppings VARCHAR(50);

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
