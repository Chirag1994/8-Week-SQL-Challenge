## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT COUNT(DISTINCT customer_id) AS num_customers
FROM SUBSCRIPTIONS;
```

Output:
| num_customers |
|-----------|
| 1000 |

#### Insights: Number of Customers in Foodie-Fi

1. **Customer Acquisition/Total Number of Customers**:

   - The platform has successfully onboarded 1000 customers, indicating a healthy level of customer acquisition.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.

```sql
SELECT
	MONTH(S.start_date) AS month_number,
	MONTHNAME(S.start_date) AS month_name,
    COUNT(S.customer_id) AS customer_cnt
FROM subscriptions AS S
JOIN plans AS P ON S.plan_id = P.plan_id
WHERE P.plan_name = 'trial'
GROUP BY month_number, month_name
ORDER BY MONTH(S.start_date);
```

Output:
| month_number | month_name | customer_cnt |
|--------------|------------|--------------|
| 1 | January | 88 |
| 2 | February | 68 |
| 3 | March | 94 |
| 4 | April | 81 |
| 5 | May | 88 |
| 6 | June | 79 |
| 7 | July | 89 |
| 8 | August | 88 |
| 9 | September | 87 |
| 10 | October | 79 |
| 11 | November | 75 |
| 12 | December | 84 |

#### Insights: Monthly Distribution of Trial Plan Start Dates

1. **Monthly Breakdown**:

   - The number of customers starting trial plans shows variations across different months.
   - Months like March, July, and August witnessed relatively higher numbers of trial plan initiations.
   - The distribution highlights potential seasonal patterns or promotional activities that may have influenced trial plan sign-ups.
   - Understanding the monthly distribution helps in identifying trends and seasonality in customer acquisition.

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

```sql
SELECT
	P.plan_name,
    COUNT(S.customer_id) AS customer_cnt
FROM subscriptions AS S
JOIN plans AS P ON S.plan_id = P.plan_id
WHERE YEAR(S.start_date) > 2020
GROUP BY P.plan_name
ORDER BY P.plan_name;
```

Output:
| plan_name | customer_cnt |
|----------------|--------------|
| basic monthly | 8 |
| churn | 71 |
| pro annual | 63 |
| pro monthly | 60 |

#### Insights: Plan Start Dates after 2020

1. **Breakdown by Plan Name**:

   - Basic Monthly: 8 events started after 2020 for the basic monthly plan.
   - Churn: There are 71 churn events recorded after 2020.
   - Pro Annual: 63 customers started their pro annual plans after 2020.
   - Pro Monthly: 60 customers initiated their pro monthly plans after 2020.

2. **Observations**:

   - The majority of events after 2020 are churn events, indicating customers canceling their subscriptions.
   - Pro annual and pro monthly plans also have significant post-2020 start dates, suggesting continued subscription renewals and new sign-ups.
   - Monitoring churn rates and understanding the reasons behind churn events is crucial for retaining customers.

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
SELECT
	COUNT(DISTINCT S.customer_id) AS churn_cnt,
    ROUND(100.0 * COUNT(DISTINCT S.customer_id)
		/(SELECT COUNT(DISTINCT subscriptions.customer_id)
			FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM subscriptions AS S
JOIN plans AS P
ON S.plan_id = P.plan_id
WHERE P.plan_name = 'churn';
```

Output:
| churn_cnt | churn_percentage |
|-----------|-------------------|
| 307 | 30.7 |

#### Insights: Churn Rate Analysis

1. **Churn Count and Percentage**:

   - Churn Count: The total number of customers who have churned is 307.
   - Churn Percentage: The churn rate, rounded to one decimal place, is 30.7%.

2. **Observations**:

   - Churn is a significant factor impacting Foodie-Fi's customer base, with almost one-third of customers canceling their subscriptions.
   - Understanding the reasons behind churn and implementing strategies to reduce it is essential for maintaining a stable and growing subscriber base.

3. **Implications**:

   - Monitoring and analyzing churn metrics regularly is crucial for identifying trends and implementing proactive measures to mitigate churn.
   - Implementing retention strategies such as personalized offers, improved customer support, and content recommendations can help reduce churn and improve customer satisfaction.
   - Continuous evaluation of churn metrics and adjustment of retention strategies based on insights gained will be essential for long-term business success.

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
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
```

Output:
| churners_cnt_after_trial | churners_percentage_after_trial |
|--------------------------|---------------------------------|
| 92 | 9.20 |

#### Insights: Churn Rate after Free Trial

1. **Churners after Free Trial**:

   - Churners Count after Trial: There are 92 customers who have churned immediately after their initial free trial period.
   - Churn Percentage after Trial: The percentage of customers who churned after their free trial, rounded to the nearest whole number, is 9%.

2. **Observations**:

   - The churn rate after the free trial period is a critical metric for understanding the effectiveness of the trial in converting users to paid subscribers.
   - A churn rate of 9% suggests that a significant portion of customers are not converting to paid plans after their trial period.

3. **Implications**:

   - Analyzing the reasons why customers churn after the trial period and addressing any pain points or barriers to subscription conversion is essential.
     -Implementing strategies to improve the trial experience, provide value during the trial period, and incentivize conversion to paid plans can help reduce churn after the trial.
   - Continuous monitoring of churn metrics post-trial and iterating on trial offerings based on customer feedback and behavior will be crucial for improving conversion rates and overall subscriber retention.

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
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
```

Output:
| plan_name | customer_cnt | percentage |
|----------------|--------------|------------|
| basic monthly | 546 | 54.60 |
| pro annual | 258 | 25.80 |
| churn | 307 | 30.70 |
| pro monthly | 539 | 53.90 |

#### Insights: Customer Plans after Free Trial

1. **Customer Plan Distribution**:

   - Basic Monthly: 546 customers (54.60%) opted for the Basic Monthly plan after their free trial.
   - Pro Annual: 258 customers (25.80%) chose the Pro Annual plan after their free trial.
   - Churn: 307 customers (30.70%) churned after their free trial, indicating that they did not continue with any paid subscription.
   - Pro Monthly: 539 customers (53.90%) selected the Pro Monthly plan after their free trial.

2. **Observations**:

   - The majority of customers opt for either the Basic Monthly or Pro Monthly plans after the free trial, accounting for approximately 54.60% and 53.90%, respectively.
   - A significant portion of customers (25.80%) choose the Pro Annual plan, indicating a preference for longer-term commitments.
   - The churn rate after the free trial is notably high, with 30.70% of customers opting out of any paid subscription.

3. **Implications**:

   - Offering a variety of subscription plans caters to different customer preferences and financial capabilities.
   - Understanding the reasons behind churn after the trial period is crucial for improving retention and conversion rates.
   - Implementing targeted marketing strategies, personalized offers, and enhancing the value proposition for paid plans can help reduce churn and increase subscription conversions post-trial.

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
WITH activeSubscriptions AS (
SELECT S.customer_id, S.start_date, P.plan_name,
    LEAD(S.start_date) OVER (PARTITION BY S.customer_id ORDER BY S.start_date) AS next_date
FROM Plans AS P JOIN Subscriptions AS S
ON P.plan_id = S.plan_id)
SELECT A.plan_name, COUNT(A.customer_id) AS customer_count,
    ROUND(100.0 * (COUNT(A.customer_id))/(SELECT COUNT(DISTINCT customer_id) FROM Subscriptions),2) AS customer_percentage
FROM activeSubscriptions AS A
WHERE (next_date IS NOT NULL AND (A.start_date < '2020-12-31' AND A.next_date > '2020-12-31')
	OR (A.start_date < '2020-12-31' AND A.next_date IS NULL))
GROUP BY A.plan_name
ORDER BY A.plan_name;
```

Output:
| plan_name | customer_count | customer_percentage |
|----------------|----------------|---------------------|
| basic monthly | 224 | 22.40 |
| churn | 235 | 23.50 |
| pro annual | 195 | 19.50 |
| pro monthly | 326 | 32.60 |
| trial | 19 | 1.90 |

#### Insights: Customer Breakdown by Plan at 2020-12-31

1. **Customer Distribution**:

   - Basic Monthly: There are 224 customers (22.40%) subscribed to the Basic Monthly plan.
   - Churn: 235 customers (23.50%) have churned, meaning they no longer have an active subscription.
   - Pro Annual: 195 customers (19.50%) are subscribed to the Pro Annual plan.
   - Pro Monthly: 326 customers (32.60%) have opted for the Pro Monthly plan.
   - Trial: A small portion of customers, 19 (1.90%), are still in the trial phase as of December 31, 2020.

2. **Observations**:

   - The Pro Monthly plan has the highest customer count at 32.60%, indicating its popularity among subscribers.
   - Basic Monthly and Churn plans have relatively similar customer counts, with 22.40% and 23.50%, respectively.
   - The Pro Annual plan has a lower customer count compared to Pro Monthly but still maintains a significant portion at 19.50%.
   - The Trial phase has a minimal impact on the customer base, with only 1.90% of customers still in the trial period.

3. **Implications**:

   - Understanding the distribution of customers across different plans helps in evaluating the effectiveness of pricing strategies and plan offerings.
   - Analyzing churn rates alongside active subscriptions provides insights into customer retention and satisfaction levels.
   - Targeted marketing and retention efforts can be tailored based on plan preferences and customer behavior to maximize subscription revenue and minimize churn.

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT
	COUNT(S.customer_id) AS num_of_customers
FROM subscriptions AS S
WHERE plan_id = 3 AND YEAR(start_date) = '2020';
```

Output:
| num_of_customers |
|-----------|
| 195 |

#### Insights: Customer Upgrades to Annual Plan in 2020

1. **Number of Upgrades**:

   - Annual Plan Upgrades: In 2020, a total of 195 customers upgraded to the annual subscription plan.

2. **Observations**:

   - The annual subscription plan attracted a considerable number of customers, indicating its appeal and value proposition.

3. **Implications**:

   - The popularity of the annual plan upgrade suggests that customers are interested in committing to Foodie-Fi for a longer duration, possibly due to cost savings or enhanced benefits offered by the annual subscription.

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
WITH trial_cte AS
(SELECT customer_id, start_date AS trial_date FROM subscriptions WHERE plan_id = 0),
	annual_cte AS
 (SELECT customer_id, start_date AS annual_date FROM subscriptions WHERE plan_id = 3)
SELECT ROUND(AVG(DATEDIFF(annual_date,trial_date)),0) AS 'avg_num_of_days'
FROM trial_cte JOIN annual_cte ON trial_cte.customer_id = annual_cte.customer_id;
```

Output:
| avg_num_of_days |
|-----------|
| 105 |

#### Insights: Average Time to Upgrade to Annual Plan

1. **Average Time to Upgrade**:

   - Average Duration: On average, it takes approximately 105 days for customers to upgrade from the trial plan to an annual subscription plan.

2. **Observations**:

   - Customers typically take over three months to transition from the trial plan to the annual subscription, indicating a deliberative decision-making process or possibly a trial period evaluation.

3. **Implications**:

   - Foodie-Fi can implement targeted campaigns or incentives to prompt trial users to upgrade sooner, thereby increasing conversion rates and revenue. Additionally, personalized communication or offers tailored to users' preferences can expedite the upgrade process.

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
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
```

Output:
| day_period_bucket | num_of_customers |
|-------------------|-------------------|
| 1 - 30 days | 49 |
| 31 - 60 days | 24 |
| 61 - 90 days | 34 |
| 91 - 120 days | 35 |
| 121 - 150 days | 42 |
| 151 - 180 days | 36 |
| 181 - 210 days | 26 |
| 211 - 240 days | 4 |
| 241 - 270 days | 5 |
| 271 - 300 days | 1 |
| 301 - 330 days | 1 |
| 331 - 360 days | 1 |

#### Insights: Breakdown of Average Time to Upgrade by 30-Day Periods

1. **Key Findings**:

   - Initial Upgrade Activity: The majority of customers (49) upgrade within the first month (1 - 30 days) after their trial period ends, indicating prompt conversion for a significant portion of users.
   - Gradual Adoption: A notable number of customers continue to upgrade gradually over time, with 24 customers upgrading between 31 to 60 days, and 34 between 61 to 90 days.
   - Steady Conversion: Conversion remains consistent over time, with a relatively even distribution of customers upgrading across subsequent 30-day intervals, until a decline observed after 180 days.

2. **Observations**:

   - Quick Conversions: The early spike in upgrades suggests that a substantial portion of customers are convinced of the value proposition shortly after their trial ends.
   - Longer Adoption Period: Some customers take longer to convert, possibly indicating a longer evaluation or decision-making process, necessitating ongoing engagement strategies during this period.
   - Late Adopters: A few customers upgrade much later, highlighting the importance of persistent engagement efforts to encourage conversion even beyond the initial months.

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH downgraded_cte AS
(SELECT customer_id, plan_id, start_date,
	LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM subscriptions)
SELECT COUNT(customer_id)
FROM downgraded_cte
WHERE plan_id = '2' and next_plan = '1' AND YEAR(start_date);
```

Output:
| customer_cnt |
|-----------|
| 0 |

#### Insights: Downgrade from Pro Monthly to Basic Monthly in 2020

1. **Key Finding**:

   - No Downgrades Detected: There were no instances of customers downgrading from the pro monthly plan to the basic monthly plan in 2020, indicating a retention of pro monthly subscribers or a lack of documented downgrades during this period.
