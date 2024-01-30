### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales? \*/

```sql
SELECT DISTINCT(week_number) AS baseline_week_number FROM clean_weekly_sales
WHERE week_date = '2020-06-15' AND calendar_year = '2020';

WITH before_and_after_data AS
(SELECT week_date,
        week_number,
        SUM(sales) AS total_sales
        FROM clean_weekly_sales
    WHERE (week_number BETWEEN 20 AND 27) AND (calendar_year = '2020')
    GROUP BY 1,2
    ORDER BY 1,2
),
sales_calculation_table_before_and_after AS (
SELECT
        SUM(CASE WHEN week_number IN (20,21,22,23) THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
        SUM(CASE WHEN week_number IN (24,25,26,27) THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
        FROM before_and_after_data
        )
    SELECT
        sales_before_baseline_date_value, sales_after_baseline_date_value,
        (sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
        ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/sales_before_baseline_date_value,2) AS pct
    FROM sales_calculation_table_before_and_after;
```

Output:
The Baseline week_number is `24`.

| sales_before_baseline_date_value | sales_after_baseline_date_value | difference | pct   |
| -------------------------------- | ------------------------------- | ---------- | ----- |
| 2345878357                       | 2318994169                      | -26884188  | -1.15 |

### 2. What about the entire 12 weeks before and after?

```sql
WITH before_and_after_data AS
(SELECT week_date, week_number, SUM(sales) AS total_sales
    FROM clean_weekly_sales
WHERE calendar_year = '2020'
GROUP BY week_date, week_number
ORDER BY week_date, week_number
),
sales_calculation_table_before_and_after AS (
    SELECT
        SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
        SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
    FROM before_and_after_data)
SELECT
    sales_before_baseline_date_value, sales_after_baseline_date_value,
    (sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
    ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/sales_before_baseline_date_value,2) AS pct
FROM sales_calculation_table_before_and_after;
```

Output:
| sales_before_baseline_date_value | sales_after_baseline_date_value | difference | pct |
| -------------------------------- | ------------------------------- | ---------- | ----- |
| 7126273147 | 6973947753 | -152325394 | -2.14 |

### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019 for 4 weeks period?

Part 3.1: How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019 for 4 weeks period?

```sql
WITH before_and_after_data AS
(SELECT calendar_year, week_number,
    SUM(sales) AS total_sales
    FROM clean_weekly_sales
WHERE (week_number BETWEEN 20 AND 27)
GROUP BY calendar_year, week_number
ORDER BY calendar_year, week_number
),
sales_calculation_table_before_and_after AS (
    SELECT calendar_year,
        SUM(CASE WHEN week_number IN (20,21,22,23) THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
        SUM(CASE WHEN week_number IN (24,25,26,27) THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
    FROM before_and_after_data
    GROUP BY calendar_year
    )
SELECT calendar_year,
    sales_before_baseline_date_value, sales_after_baseline_date_value,
    (sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
    ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)
    /sales_before_baseline_date_value,2) AS pct
FROM sales_calculation_table_before_and_after;
```

Output:
| calendar_year | sales_before_baseline_date_value | sales_after_baseline_date_value | difference | pct |
|---------------|----------------------------------|----------------------------------|------------|--------|
| 2018 | 2125140809 | 2129242914 | 4102105 | 0.19 |
| 2019 | 2249989796 | 2252326390 | 2336594 | 0.10 |
| 2020 | 2345878357 | 2318994169 | -26884188 | -1.15 |

### Part 3.2: How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019 for 12 weeks period?

```sql
WITH before_and_after_data AS
    (SELECT calendar_year, week_number,
        SUM(sales) AS total_sales
        FROM clean_weekly_sales
    GROUP BY calendar_year, week_number
    ORDER BY calendar_year, week_number
    ), sales_calculation_table_before_and_after AS (
        SELECT calendar_year,
            SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
            SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
        FROM before_and_after_data
        GROUP BY calendar_year
        )
    SELECT calendar_year,
        sales_before_baseline_date_value, sales_after_baseline_date_value,
        (sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
        ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/
            sales_before_baseline_date_value,2) AS pct
    FROM sales_calculation_table_before_and_after;
```

Output:
| calendar_year | sales_before_baseline_date_value | sales_after_baseline_date_value | difference | pct |
|---------------|----------------------------------|----------------------------------|------------|--------|
| 2018 | 6396562317 | 6500818510 | 104256193 | 1.63 |
| 2019 | 6883386397 | 6862646103 | -20740294 | -0.30 |
| 2020 | 7126273147 | 6973947753 | -152325394 | -2.14 |
