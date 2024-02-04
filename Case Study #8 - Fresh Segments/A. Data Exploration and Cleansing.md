### 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month.

We will follow the following steps to solve this question:
Step 1: Converting month_year column from Varchar(7) -> Varchar(10)
Step 2: Adding '01-' in front of the month_year column to make it a proper date in every row.
Step 3: Converting the month_year column into a Date column.
Step 4: Checking/Displaying the observations.

```sql
ALTER TABLE interest_metrics MODIFY COLUMN month_year VARCHAR(10)
UPDATE interest_metrics SET month_year = STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y')
ALTER TABLE interest_metrics MODIFY COLUMN month_year DATE

SELECT * FROM interest_metrics;
```

Output:
Some random records are shown below:
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
|--------|-------|-------------|-------------|-------------|-------------|---------|---------------------|
| 7 | 2018 | 2018-07-01 | 32486 | 11.89 | 6.19 | 1 | 99.86 |
| 7 | 2018 | 2018-07-01 | 6106 | 9.93 | 5.31 | 2 | 99.73 |
| 7 | 2018 | 2018-07-01 | 18923 | 10.85 | 5.29 | 3 | 99.59 |
| 7 | 2018 | 2018-07-01 | 6344 | 10.32 | 5.1 | 4 | 99.45 |
| 7 | 2018 | 2018-07-01 | 100 | 10.77 | 5.04 | 5 | 99.31 |
| 7 | 2018 | 2018-07-01 | 69 | 10.82 | 5.03 | 6 | 99.18 |
| 7 | 2018 | 2018-07-01 | 79 | 11.21 | 4.97 | 7 | 99.04 |
| 7 | 2018 | 2018-07-01 | 6111 | 10.71 | 4.83 | 8 | 98.9 |
| 7 | 2018 | 2018-07-01 | 6214 | 9.71 | 4.83 | 8 | 98.9 |
| 8 | 2018 | 2018-08-01 | 19619 | 4.54 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 6006 | 2.73 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 34088 | 3.5 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 10351 | 5.87 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 10364 | 2.83 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 17314 | 3.77 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 17452 | 4.49 | 1.41 | 260 | 66.1 |
| 8 | 2018 | 2018-08-01 | 7461 | 4.61 | 1.41 | 260 | 66.1 |

### 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

```sql
SELECT
    month_year,
    COUNT(interest_id) AS num_of_records
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year ASC;
```

Output:
| month_year | num_of_records |
|------------|-----------------|
| null | 1 |
| 2018-07-01 | 729 |
| 2018-08-01 | 767 |
| 2018-09-01 | 780 |
| 2018-10-01 | 857 |
| 2018-11-01 | 928 |
| 2018-12-01 | 995 |
| 2019-01-01 | 973 |
| 2019-02-01 | 1121 |
| 2019-03-01 | 1136 |
| 2019-04-01 | 1099 |
| 2019-05-01 | 857 |
| 2019-06-01 | 824 |
| 2019-07-01 | 864 |
| 2019-08-01 | 1149 |

### 3. What do you think we should do with these null values in the fresh_segments.interest_metrics.

We will follow the following steps to solve this question:
Step 1: Checking the null values in every column using the following code.
Step2: Since the values of composition, index_value, ranking and percentile_ranking columns do not make any sense without knowing the \_month, \_year, month_year & interest_id variables i.e., we cannot perform any analysis on these NULL values of these variables/columns/features. Hence, a wise choice would be to delete them from the interest_metrics table.

Do not touch this code: DELETE FROM interest_metrics WHERE interest_id = '21246';

Step 3: Re-Running the code in Step 1 to check.

```sql
SELECT * FROM interest_metrics WHERE month_year IS NULL ORDER BY interest_id DESC;

DELETE FROM interest_metrics WHERE (interest_id IS NULL);

SELECT * FROM interest_metrics WHERE month_year IS NULL ORDER BY interest_id DESC;
```

Output:
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
|--------|-------|------------|-------------|-------------|-------------|---------|---------------------|
| null | null | null | 21246 | 1.61 | 0.68 | 1191 | 0.25 |

### 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

```sql
SELECT
    MAX(metrics_interest_id_count) AS metrics_interest_id_count,
    MAX(map_id_count) AS map_id_count,
    MAX(interest_id_in_metrics_count) AS interest_id_in_metrics_count,
    MAX(id_in_map_count) AS id_in_map_count
	FROM (
		SELECT COUNT(DISTINCT IM1.interest_id) AS metrics_interest_id_count,
			COUNT(DISTINCT IM2.id) AS map_id_count,
			SUM(CASE WHEN IM1.interest_id IS NULL THEN 1 ELSE 0 END) AS interest_id_in_metrics_count,
			SUM(CASE WHEN IM2.id IS NULL THEN 1 ELSE 0 END) AS id_in_map_count
		FROM interest_metrics AS IM1 LEFT JOIN interest_map AS IM2 ON IM1.interest_id = IM2.id
		UNION
		SELECT COUNT(DISTINCT IM1.interest_id) AS metrics_interest_id_count,
			COUNT(DISTINCT IM2.id) AS map_id_count,
			SUM(CASE WHEN IM1.interest_id IS NULL THEN 1 ELSE 0 END) AS interest_id_in_metrics_count,
			SUM(CASE WHEN IM2.id IS NULL THEN 1 ELSE 0 END) AS id_in_map_count
		FROM interest_metrics AS IM1 RIGHT JOIN interest_map AS IM2 ON IM1.interest_id = IM2.id)
			AS combined_results;
```

Output:
| metrics_interest_id_count | map_id_count | interested_id_in_metric_count | id_in_map_count |
|---------------------------|--------------|---------------------------------|------------------|
| 1202 | 1209 | 7 | 0 |

### 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

```sql
SELECT
    COUNT(id) AS record_count
FROM interest_map;
```

Output:
| record_count |
|--------------|
| 1209 |

### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

```sql
SELECT
    IM1.*,
    IM2.interest_name,
    IM2.interest_summary,
	IM2.created_at,
    IM2.last_modified
FROM interest_metrics AS IM1
JOIN interest_map AS IM2
ON IM1.interest_id = IM2.id
WHERE IM1.interest_id = '21246';
```

Output:
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking | interest_name | interest_summary | created_at | last_modified |
|--------|-------|-------------|--------------|-------------|-------------|---------|---------------------|------------------------------------|-----------------------------------------------------------|--------------------------|--------------------------|
| 7 | 2018 | 2018-07-01 | 21246 | 2.26 | 0.65 | 722 | 0.96 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 8 | 2018 | 2018-08-01 | 21246 | 2.13 | 0.59 | 765 | 0.26 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 9 | 2018 | 2018-09-01 | 21246 | 2.06 | 0.61 | 774 | 0.77 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 10 | 2018 | 2018-10-01 | 21246 | 1.74 | 0.58 | 855 | 0.23 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 11 | 2018 | 2018-11-01 | 21246 | 2.25 | 0.78 | 908 | 2.16 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 12 | 2018 | 2018-12-01 | 21246 | 1.97 | 0.7 | 983 | 1.21 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 1 | 2019 | 2019-01-01 | 21246 | 2.05 | 0.76 | 954 | 1.95 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 2 | 2019 | 2019-02-01 | 21246 | 1.84 | 0.68 | 1109 | 1.07 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 3 | 2019 | 2019-03-01 | 21246 | 1.75 | 0.67 | 1123 | 1.14 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 4 | 2019 | 2019-04-01 | 21246 | 1.58 | 0.63 | 1092 | 0.64 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| null | null | null | 21246 | 1.61 | 0.68 | 1191 | 0.25 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |

### 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

```sql

```

Output:
