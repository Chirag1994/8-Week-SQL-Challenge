  USE foodie_fi;
 /* --------------------------------- A. Customer Journey --------------------------------- */
 /* Based off the 8 sample customers provided in the sample from the subscriptions table, 
	write a brief description about each customer’s onboarding journey.
    Try to keep it as short as possible - you may also want to run some sort of join to 
    make your explanations a bit easier! */

SELECT
	S.customer_id, P.plan_name, P.price, S.start_date
FROM Subscriptions AS S
JOIN Plans AS P ON P.plan_id = S.plan_id
WHERE customer_id IN (1,2,3,4,5,6,7,8);

/* Customer 1 signed up on '2020-08-01' for free-trial and on '2020-08-08' customer took the basic monthly 
plan as the system automatically upgrades to pro monthly plan.

Customer 2 signed up on '2020-09-20' for free trial and on '2020-09-27' customer upgraded to pro annual subscription.

Customer 3 signed up on '2020-01-13' for free trial and on '2020-01-20' customer took the basic monthly 
plan instead of going for the pro monthly plan as what system automatically upgrades to.

Customer 4 signed up on '2020-01-17' for free trial, on '2020-01-24' customer took the basic monthly plan 
and then churned out on '2020-0421' (after 3 months of free-trial).

Customer 5 signed up on '2020-08-03' for free-trial and on '2020-08-10' customer took the basic monthly 
plan instead of going for the pro monthly plan as what system automatically upgrades to.

Customer 6 signed up on '2020-12-23' for free trial, on '2020-12-30' customer took the basic monthly plan 
and then churned out on '2021-02-26' (after 2 months of free-trial).

Customer 7 signed up on '2020-02-05' for free-trial, on '2020-02-12' customer took the basic monthly plan 
and then using the basic monthly plan for 3 months upgraded his plan to pro monthly on '2020-05-22'.

Same goes to customer 8, customer signed up on '2020-06-11' for free-trial, on '2020-06-18' customer took 
the basic monthly plan and then using the basic monthly plan for 2 months upgraded his plan to pro monthly 
on '2020-08-03'. */

 
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
WITH activeSubscriptions AS (
SELECT S.customer_id, S.start_date,
    P.plan_name,
    LEAD(S.start_date) OVER (PARTITION BY S.customer_id ORDER BY S.start_date) AS next_date
FROM Plans AS P JOIN Subscriptions AS S
ON P.plan_id = S.plan_id)
SELECT A.plan_name,
	COUNT(A.customer_id) AS customer_count,
    ROUND(100.0 * (COUNT(A.customer_id))/(SELECT COUNT(DISTINCT customer_id) FROM Subscriptions),2) AS customer_percentage
FROM activeSubscriptions AS A
WHERE (next_date IS NOT NULL AND (A.start_date < '2020-12-31' AND A.next_date > '2020-12-31')
	OR (A.start_date < '2020-12-31' AND A.next_date IS NULL))
GROUP BY A.plan_name
ORDER BY A.plan_name;

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
WITH trial_plan AS (
  SELECT customer_id, start_date AS trial_date
  FROM foodie_fi.subscriptions WHERE plan_id = 0
), annual_plan AS (
  SELECT 
    customer_id, start_date AS annual_date
  FROM foodie_fi.subscriptions WHERE plan_id = 3
), bins AS (
  -- bins CTE: Put customers in 30-day buckets based on the average number of days taken to upgrade to a pro annual plan.
  SELECT 
    FLOOR((DATEDIFF(annual.annual_date, trial.trial_date) - 1) / 30) + 1 AS avg_days_to_upgrade
  FROM trial_plan AS trial
  JOIN annual_plan AS annual
    ON trial.customer_id = annual.customer_id
)
SELECT 
  CONCAT(((avg_days_to_upgrade - 1) * 30 + 1), ' - ', (avg_days_to_upgrade * 30), ' days') AS day_period_bucket, 
  COUNT(*) AS num_of_customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;

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
    
-- Use a recursive CTE to increment rows for all monthly paid plans until customers changing the plan, except 'pro annual'
WITH RECURSIVE dateRecursion AS (
    SELECT 
        s.customer_id, s.plan_id, p.plan_name, s.start_date AS payment_date,
        -- column last_date: last day of the current plan
        CASE 
            -- if a customer kept using the current plan, last_date = '2020-12-31'
            WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
            -- if a customer changed the plan, last_date = (month difference between start_date and changing date) + start_date
            ELSE DATE_ADD(
                start_date, 
                INTERVAL DATEDIFF(LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date), start_date) MONTH
            ) END AS last_date,
        p.price AS amount
    FROM subscriptions s
    JOIN plans p ON s.plan_id = p.plan_id
    -- exclude trials because they didn't generate payments 
    WHERE p.plan_name NOT IN ('trial')
        AND YEAR(start_date) = 2020

    UNION ALL

    SELECT 
        customer_id,
        plan_id,
        plan_name,
        -- increment payment_date by monthly
        DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
        last_date,
        amount
    FROM dateRecursion
    -- stop incrementing when payment_date = last_date
    WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) <= last_date
        AND plan_name != 'pro annual'
)
-- Create a new table [payments]
SELECT 
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM dateRecursion
-- exclude churns
WHERE amount IS NOT NULL
ORDER BY customer_id;    
 
 /* --------------------------------- D. Outside The Box Questions --------------------------------- */
 /* The following are open ended questions which might be asked during a technical interview for this case study 
	- there are no right or wrong answers, but answers that make sense from both a technical and a business 
    perspective make an amazing impression! */

-- 1. How would you calculate the rate of growth for Foodie-Fi?
/*
**Answer:**

To assess the rate of growth for Foodie-Fi, we should analyze the following multiple key indicators:

1. Customer Base Growth:
   - Calculate the overall growth in the customer base over specific time periods 
	 (for instance, monthly or quarterly.),.
   - Monitor the acquisition of new customers and the retention of the existing ones.
2. Subscription Plan Adoption:
   - Analyze the uptake of different subscription plans (Basic, Pro Monthly, Pro Annual) to 
     understand the customer preferences.
   - Evaluate the growth rate of Pro Plans compared to the overall customer base.
3. Churn Reduction:
   - Investigate the reduction in churn by assessing the number of customers downgrading or 
     canceling their subscriptions.
   - Calculate the churn rate and observe its trend over time.
4. Revenue Growth:
   - Monitor the revenue growth over time, by considering both the increase in the customer base 
     and potential changes in subscription plans.
5. Conversion Rates:
   - Analyze the conversion rates from Trial users to Paid subscribers, providing insights into the 
     effectiveness of the trial period in conversting users.
*/
-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of 
	 -- their overall business?
/*
**Answer:**

To comprehensively assess the performance of Foodie-Fi, it is recommended to track the following metrics over time.

1. Customer Base Growth:
   - Monitor the overall growth or contraction of the customer base on a regular basis 
     (for instance, monthly, or quarterly or annually).
2. Revenue Breakdown:
   - Analyze the revenue streams from different subscription plans, with a focus on Pro plan customers. 
     This breakdown helps understand the contribution of various plans to the overall revenue.
3. Churn Rate:
   - Calculate and track the churn rate over time. Identifying patterns in customer attrition provides 
     insights into service quality, and customer statisfaction and hence, increase in the customer base.
4. Customer Acquisition and Conversion Rates:
   - Assess the effectiveness of marketing strategies by tracking customer acquisition rates. Additionally, 
     monitor the conversion rates from tria to paid subscriptions.
5. Average Revenue Per User (ARPU):
   - Calculate the average revenue generated by each user to understand the averae contribution of each 
     customers to the overall revenue.
*/
-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
/*
**Answer:**

The key areas to understand the customer retention are the following ones:

1. Plan Changes:
   - Understand the specific triggers that lead the customers to changes their plans. This could involve 
     analyzing the benefits they seek, such as unlimited streaming or offline access. Additionally, explore 
     whether promotional offers or plan-specific features influences plan changes.
   - Implement an exit survey strategy for users who either downgrade or cancel their plans. Collecting feedback 
     directly from users can uncover nuanced insights into their decision making process.

2. Customer Support:
   - We can identify the common queries, concerns, or issues faced by customers from the customer support 
     interactions. Additionally track how effectively customer issues are resolved over time. This helps us 
	 understand if the customers are unhappy with the resolutions and our services, thereby leading them to churn out.

3. Content Preferences:
   - Explore not only what customers are looking for but also gather insights into why certain content might 
     not meet their expectations. Are there any programs that are not in the video library because of which 
	 customers are looking for? Conducting surveys of feedback sessions helps to understand specific content 
     preferences and expectations.

4. Platform Comparison:
   - Consider comparing Foodie-Fi with other platforms. Identify features, shows that competitors offer and 
     where Foodie-Fi might lack. This competitive analysis can reveal opportunities for improvement. Additionally 
	 assess user perceptions of Foodie-Fi to competitors through surveys or reviews.

5. Personalized Recommendations:
   - Understand how personalized recommendation can positively impact retention. Analyze successful cases where 
     tailored content suggestions lead to increased engagement. Implement ML algorithms to enhance recommendation 
     precision, ensuring users receive content aligned with their preferences.
   - Implement a feedback mechanism for users to provide explicit feedback on recommended content. This can 
     refine algorithms and enhance the accuracy of personalized suggestions.
*/
-- 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, 
	 -- what questions would you include in the survey?
/*
**Answer:**

Some valuable questions to include in the exit survey shown to customers who wish to cancel their subscription 
could be the following:

1. What did you like most about Foodie-Fi, and is there anything specific you would like to see changed or 
   improved on the program?

2. Are you satisfied with the current pricing of our plans?

3. How would you rate your satisfaction with our customer support? If not entirely satisfied, please provide 
   details on areas for improvement.

4. Did you find the specific program you were looking for for in our Video Library? If not, could you share some 
   details about the content you were seeking?

5. What is the primary reason for canceling your subscription? (Include options related to content, pricing, 
   customer service, etc.)

6. Is there anything else you would like to share or any feedback that hasn't been covered in the previous questions?
*/
 -- 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate 
	 -- the effectiveness of your ideas?
/*
**Answer:**

1. Enhanced Content Library:

   - Idea: Regularly update and expand the content library with exclusive shows and programs.
   - Validation: Monitor the time spent by the customers on the platform, and the frequency of login hours, 
	 and take direct feedback in the form of a question like, Is this the show you were looking for?

2. Personalized Recommendations:

   - Idea: Implement advanced algorithms to provide personalized content recommendations based on Individual 
     preferences and viewing history.
   - Validation: Track the percentage of users following the personalized recommendations and ask for feedback 
     to check the satisfaction of the customers.

3. Promotional Offers and Discounts:

   - Idea: Introduce limited-time promotions, discounts, or bundled subscription options to incentivize customer 
     retention.
   - Validation: Analyze the impact on customer retention by doing the before and after analysis.

4. Improved Customer Support:

   - Idea: Enhance customer support services by reducing response times, resolving queries effectively in a 
     short period, and gathering feedback for continuous improvement.
   - Validation: Guage the customer churn percentage, and customer satisfaction scores, and collect feedback on 
     customer support interactions.

5. Exit Surveys and Feedback Analysis:

   - Idea: Implement an exit survey for customers canceling their subscriptions to gather insights into reasons 
     for leaving.
   - Validation: Analyze any common reason to leave the platform and work on it.

*/