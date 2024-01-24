## Data Cleaning

### Cleaning clean_weekly_sales Table

```sql
DROP TABLE IF EXISTS data_mart.clean_weekly_sales;
CREATE TABLE data_mart.clean_weekly_sales AS (
SELECT
  STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
  WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
  MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
  YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
  region,
  platform,
  CASE
    WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE
    WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
    WHEN LEFT(segment, 1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  COALESCE(NULLIF(segment, ''), 'unknown') AS segment,
  transactions,
  ROUND((sales / transactions), 2) AS avg_transaction,
  sales
FROM data_mart.weekly_sales
);

-- Ensure that all null string values are replaced with "unknown" in the new age_band, demographic, and segment columns
UPDATE data_mart.clean_weekly_sales
SET age_band = 'unknown'
WHERE age_band IS NULL;

UPDATE data_mart.clean_weekly_sales
SET demographic = 'unknown'
WHERE demographic IS NULL;

UPDATE data_mart.clean_weekly_sales
SET segment = 'unknown'
WHERE segment IS NULL;

-- Displaying the final cleaned table
SELECT * FROM clean_weekly_sales;
```

Output:
