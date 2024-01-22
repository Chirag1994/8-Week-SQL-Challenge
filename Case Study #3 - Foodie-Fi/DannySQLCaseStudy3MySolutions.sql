  USE foodie_fi;
 /* --------------------------------- A. Customer Journey --------------------------------- */
 /* Based off the 8 sample customers provided in the sample from the subscriptions table, 
	write a brief description about each customer’s onboarding journey.
    Try to keep it as short as possible - you may also want to run some sort of join to 
    make your explanations a bit easier! */


 
 /* --------------------------------- B. Data Analysis Questions --------------------------------- */
 -- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS num_customers
FROM SUBSCRIPTIONS;
 
 -- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the 
	  -- start of the month as the group by value.
SELECT 
	MONTH(S.start_date) AS month_number,
	MONTHNAME(S.start_date) AS month_name,
    COUNT(S.customer_id) AS customer_cnt
FROM subscriptions AS S
JOIN plans AS P ON S.plan_id = P.plan_id
WHERE P.plan_name = 'trial'
GROUP BY month_number, month_name
ORDER BY MONTH(S.start_date);

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by 
	  -- count of events for each plan_name.
SELECT 
	P.plan_name,
    COUNT(S.customer_id) AS customer_cnt
FROM subscriptions AS S
JOIN plans AS P ON S.plan_id = P.plan_id
WHERE YEAR(S.start_date) > 2020
GROUP BY P.plan_name
ORDER BY P.plan_name;
      
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
	COUNT(DISTINCT S.customer_id) AS churn_cnt,
    ROUND(100.0 * COUNT(DISTINCT S.customer_id)
		/(SELECT COUNT(DISTINCT subscriptions.customer_id) 
			FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM subscriptions AS S
JOIN plans AS P
ON S.plan_id = P.plan_id
WHERE P.plan_name = 'churn';

-- 5. How many customers have churned straight after their initial free trial - what percentage is this 
	  -- rounded to the nearest whole number?
WITH next_plan_cte AS 
	(SELECT *, LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
		FROM subscriptions),
	churners AS 
		(SELECT * FROM next_plan_cte
			WHERE next_plan=4 AND plan_id = 0)
	SELECT COUNT(customer_id) AS 'churners_after_trail',
		ROUND(100.0 * COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) AS 'distinct_customers' 
				FROM subscriptions),2) AS 'churn_percentage_after_trial'
FROM churners;

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH next_plan_cte AS
	(SELECT subscriptions.customer_id,
		subscriptions.plan_id, plans.plan_name, start_date, 
		LEAD(subscriptions.plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
		FROM subscriptions 
		JOIN plans ON subscriptions.plan_id = plans.plan_id)
SELECT next_plan_cte.plan_name,
	COUNT(next_plan_cte.customer_id) AS customer_cnt,  -- Specify the table for clarity
    ROUND(100.0 * COUNT(next_plan_cte.customer_id) / (SELECT COUNT(DISTINCT customer_id) AS distinct_customers FROM subscriptions), 2) AS "percentage"  -- Use double quotes for aliases
FROM next_plan_cte
WHERE next_plan_cte.plan_name != 'trial'
GROUP BY next_plan_cte.plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT 
	COUNT(S.customer_id) AS num_of_customers
FROM subscriptions AS S
WHERE plan_id = 3 AND YEAR(start_date) = '2020';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_cte AS 
(SELECT customer_id, start_date AS trial_date FROM subscriptions WHERE plan_id = 0),
	annual_cte AS 
 (SELECT customer_id, start_date AS annual_date FROM subscriptions WHERE plan_id = 3)
SELECT ROUND(AVG(DATEDIFF(annual_date,trial_date)),0) AS 'avg_num_of_days'
FROM trial_cte JOIN annual_cte ON trial_cte.customer_id = annual_cte.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc).


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH downgraded_cte AS 
(SELECT customer_id, plan_id, start_date,
	LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM subscriptions)
SELECT COUNT(customer_id)
FROM downgraded_cte
WHERE plan_id = '2' and next_plan = '1' AND YEAR(start_date);
 
 /* --------------------------------- C. Challenge Payment Question --------------------------------- */
 /* The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts 
	paid by each customer in the subscriptions table with the following requirements:
    -- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
    -- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
    -- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
    -- once a customer churns they will no longer make payments
    Example outputs for this table might look like the following: */
    
 
 /* --------------------------------- D. Outside The Box Questions --------------------------------- */
 /* The following are open ended questions which might be asked during a technical interview for this case study 
	- there are no right or wrong answers, but answers that make sense from both a technical and a business 
    perspective make an amazing impression! */

-- 1. How would you calculate the rate of growth for Foodie-Fi?

-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of 
	 -- their overall business?

-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

-- 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, 
	 -- what questions would you include in the survey?

 -- 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate 
	 -- the effectiveness of your ideas?