## Data Cleaning

### Cleaning clean_weekly_sales Table

```sql
DROP TABLE IF EXISTS data_mart.clean_weekly_sales

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

UPDATE data_mart.clean_weekly_sales
SET age_band = 'unknown'
WHERE age_band IS NULL;

UPDATE data_mart.clean_weekly_sales
SET demographic = 'unknown'
WHERE demographic IS NULL;

UPDATE data_mart.clean_weekly_sales
SET segment = 'unknown'
WHERE segment IS NULL;


SELECT * FROM clean_weekly_sales
LIMIT 15;
```

Output:

The first 15 records are shown as follows:

| week_date  | week_number | month_number | calendar_year | region        | platform | age_band     | demographic_segment | transactions | avg_transaction | sales   |
| ---------- | ----------- | ------------ | ------------- | ------------- | -------- | ------------ | ------------------- | ------------ | --------------- | ------- |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Retail   | Retirees     | Couples             | 120631       | 30.31           | 3656163 |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Retail   | Young Adults | Families            | 31574        | 31.56           | 996575  |
| 2020-08-31 | 35          | 8            | 2020          | USA           | Retail   | unknown      | unknown             | null         | 529151          | 31.20   |
| 2020-08-31 | 35          | 8            | 2020          | EUROPE        | Retail   | Young Adults | Couples             | 4517         | 31.42           | 141942  |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Retail   | Middle Aged  | Couples             | 58046        | 30.29           | 1758388 |
| 2020-08-31 | 35          | 8            | 2020          | CANADA        | Shopify  | Middle Aged  | Families            | 1336         | 182.54          | 243878  |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Shopify  | Retirees     | Families            | 2514         | 206.64          | 519502  |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Shopify  | Young Adults | Families            | 2158         | 172.11          | 371417  |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Shopify  | Middle Aged  | Families            | 318          | 155.84          | 49557   |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Retail   | Retirees     | Couples             | 111032       | 35.02           | 3888162 |
| 2020-08-31 | 35          | 8            | 2020          | USA           | Shopify  | Young Adults | Families            | 1398         | 186.53          | 260773  |
| 2020-08-31 | 35          | 8            | 2020          | OCEANIA       | Shopify  | Middle Aged  | Couples             | 4661         | 189.38          | 882690  |
| 2020-08-31 | 35          | 8            | 2020          | SOUTH AMERICA | Retail   | Middle Aged  | Couples             | 1029         | 37.67           | 38762   |
| 2020-08-31 | 35          | 8            | 2020          | SOUTH AMERICA | Shopify  | Retirees     | Couples             | 6            | 152.83          | 917     |
| 2020-08-31 | 35          | 8            | 2020          | EUROPE        | Shopify  | Retirees     | Families            | 115          | 306.22          | 35215   |
