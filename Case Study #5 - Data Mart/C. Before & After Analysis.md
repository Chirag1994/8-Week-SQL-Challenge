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

#### Total Sales Comparison: 4 Weeks Before and After 2020-06-15

1. **Insights**:

   - The total sales decreased by approximately $26.88 million after the baseline date compared to the four weeks before.
   - This corresponds to a reduction of approximately 1.15% in sales during the four weeks after the baseline date compared to the four weeks before.

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

#### Total Sales Comparison: 12 Weeks Before and After 2020-06-15

1. **Insights**:

   - The total sales decreased by approximately $152.33 million over the entire 12 weeks after the baseline date compared to the 12 weeks before.
   - This corresponds to a reduction of approximately 2.14% in sales during the 12 weeks after the baseline date compared to the 12 weeks before.

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

#### Sale Metrics Comparison: 4 Weeks Before and After 2020-06-15 Across Years (2018, 2019, and 2020)

1. **Overall Trend**:

   - While there were slight increases in sales in the 4 weeks after compared to before for both 2018 and 2019, there was a noticeable decrease in sales in 2020, indicating a negative impact on sales during this period compared to previous years.

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

#### Sale Metrics Comparison: 12 Weeks Before and After 2020-06-15 Across Years (2018, 2019, and 2020)

1. **Overall Trend**:

   - While there was a significant increase in sales in 2018 and a slight decrease in 2019, 2020 saw a notable decrease in sales during this period compared to previous years. This suggests a significant negative impact on sales in 2020 compared to earlier years.
