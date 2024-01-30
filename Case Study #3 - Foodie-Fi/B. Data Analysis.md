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

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql

```

Output:

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
