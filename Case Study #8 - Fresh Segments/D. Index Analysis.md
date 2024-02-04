### 1. What is the top 10 interests by the average composition for each month?

Creating the temporary table that combines interest_metrics and interest_map tables

```sql
CREATE TEMPORARY TABLE combined_tables AS
SELECT
    MIM.*,
    IM.*
FROM modified_interest_metrics AS MIM
JOIN interest_map AS IM
ON MIM.interest_id = IM.id;
```

```sql
WITH average_composition_cte AS (
SELECT
    CT._month,
    CT.interest_name,
    ROUND((CT.composition / CT.index_value), 2) AS avg_composition,
    DENSE_RANK() OVER (PARTITION BY CT._month ORDER BY CT.composition / CT.index_value DESC) AS rnk
FROM combined_tables AS CT
WHERE CT._month IS NOT NULL
)
SELECT
    *
FROM average_composition_cte
WHERE rnk <= 10;
```

Output:
| _month | interest_name | avg_composition | rnk |
|--------|----------------------------------------------------|-----------------|-----|
| 1 | Work Comes First Travelers | 7.66 | 1 |
| 1 | Solar Energy Researchers | 7.05 | 2 |
| 1 | Readers of Honduran Content | 6.67 | 3 |
| 1 | Luxury Bedding Shoppers | 6.46 | 4 |
| 1 | Nursing and Physicians Assistant Journal Researchers | 6.46 | 5 |
| ... | ... | ... | ... |
| 9 | Christmas Celebration Researchers | 6.47 | 8 |
| 9 | Restaurant Supply Shoppers | 6.25 | 9 |
| 9 | Solar Energy Researchers | 6.24 | 10 |

### 2. For all of these top 10 interests - which interest appears the most often?

```sql

```

Output:

### 3. What is the average of the average composition for the top 10 interests for each month?

```sql

```

Output:

### 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.

```sql

```

Output:

### 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

```sql

```

Output:
