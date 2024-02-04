### 1. Which interests have been present in all month_year dates in our dataset?

Counting distinct interest_id's present in the interest_metrics table

```sql
SELECT
    COUNT(DISTINCT interest_id) AS distinct_interest_metrics
FROM interest_metrics;
```

Answer: 1202 distinct interest_id's are present in our dataset.

Counting distinct interest_id's present in all month_year dates in our dataset

```sql
SELECT
    COUNT(interest_id)
FROM (
    SELECT
        interest_id,
        COUNT(month_year) AS month_year_cnt
	FROM interest_metrics
	GROUP BY interest_id
	HAVING COUNT(month_year) = (
	    SELECT
            COUNT(DISTINCT month_year) AS distinct_month_year_combination
	    FROM interest_metrics
        )
    ) AS T;
```

Answer: 480 distinct interest_id's are present in all the month_year dates in our dataset.

Selecting/Displaying the interest_id's present in all month_year dates in our dataset

```sql
 SELECT
    interest_id,
    COUNT(month_year) AS month_year_cnt
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(month_year) = (
	SELECT
        COUNT(DISTINCT month_year) AS distinct_month_year_combination
	FROM interest_metrics
);
```

Output:

The first few rows are:

| interest_id | month_year|
| 32486 | 14 |
| 18923 | 14 |
| 100 | 14 |
| 79 | 14 |
| 6110 | 14 |
| 6217 | 14 |
| 4 | 14 |
| 6218 | 14 |
| 171 | 14 |
| 19613 | 14 |
| 17 | 14 |
| 6 | 14 |

### 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

```sql
WITH interest_id_month_year_cte AS (
		SELECT
			interest_id,
            COUNT(DISTINCT month_year) AS total_months
		FROM interest_metrics
		WHERE interest_id IS NOT NULL
		GROUP BY interest_id
    ),
    interest_id_counts_cte AS (
		SELECT
			total_months,
            COUNT(interest_id) AS interest_cnt
		FROM interest_id_month_year_cte
		GROUP BY total_months
    )
    SELECT
		total_months,
        interest_cnt,
		ROUND(100.0 * ((SUM(interest_cnt) OVER (ORDER BY total_months DESC) /SUM(interest_cnt) OVER ()))
		,2) AS cumulative_percentage
    FROM interest_id_counts_cte;
```

Output:
| total_months | interest_cnt | cumulative_percentage |
|--------------|--------------|------------------------|
| 14 | 480 | 39.93 |
| 13 | 82 | 46.76 |
| 12 | 65 | 52.16 |
| 11 | 94 | 59.98 |
| 10 | 86 | 67.14 |
| 9 | 95 | 75.04 |
| 8 | 67 | 80.62 |
| 7 | 90 | 88.10 |
| 6 | 33 | 90.85 |
| 5 | 38 | 94.01 |
| 4 | 32 | 96.67 |
| 3 | 15 | 97.92 |
| 2 | 12 | 98.92 |
| 1 | 13 | 100.00 |

Answer: Interest with total_months = 6 reached the cumulative percentage of 90%.

### 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

```sql
WITH interest_id_month_year_cte AS (
		SELECT
			interest_id,
			COUNT(DISTINCT month_year) AS total_months
		FROM interest_metrics
		WHERE interest_id IS NOT NULL
		GROUP BY interest_id
    )
    SELECT
		COUNT(interest_id) AS total_interest_id_counts,
		COUNT(DISTINCT interest_id) AS unique_interest_id_counts
	FROM interest_metrics
    WHERE interest_id IN (
		SELECT
			interest_id
		FROM interest_id_month_year_cte
        WHERE total_months < 6);
```

Output:
| total_interest_id_counts | unique_interest_id_counts |
|--------------------------|---------------------------|
| 400 | 110 |

### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

```sql

```

Output:

### 5. After removing these interests - how many unique interests are there for each month?

We will follow the following steps to solve this question:

- Step 1: Dropping the temporary table modified_interest_metrics if it already exists.
- Step 2: Creating a temporary table named as modified_interest_metrics after removing these data points
- Step 3: Selecting/Displaying the total_interest_ids and unique_interest_ids left after removing those datapoints.

```sql
DROP TABLE IF EXISTS modified_interest_metrics

CREATE TEMPORARY TABLE modified_interest_metrics AS
		SELECT * FROM
			interest_metrics
		WHERE interest_id NOT IN (
			SELECT
				interest_id
			FROM interest_metrics
			WHERE interest_id IS NOT NULL
			GROUP BY interest_id
			HAVING COUNT(DISTINCT month_year) < 6
    )

SELECT COUNT(interest_id) AS total_interest_id_counts,
		COUNT(DISTINCT interest_id) AS unique_interest_id_counts
    FROM modified_interest_metrics;
```

Output:
| total_interest_id_counts | unique_interest_id_counts |
|--------------------------|---------------------------|
| 12680 | 1092|
