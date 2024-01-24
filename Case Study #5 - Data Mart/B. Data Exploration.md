### 1. What day of the week is used for each week_date value?

```sql
SELECT DISTINCT DAYNAME(formatted_week_date) AS Day_Name
FROM clean_weekly_sales;
```

Output:

### 2. What range of week numbers are missing from the dataset?

```sql
WITH RECURSIVE NumbersSeries AS (
    SELECT 1 AS number
    UNION ALL
    SELECT number + 1
    FROM NumbersSeries
    WHERE number < 52
)
SELECT NumbersSeries.number
FROM NumbersSeries
WHERE NOT EXISTS (
    SELECT 1
    FROM clean_weekly_sales
    WHERE week_number = NumbersSeries.number);
```

Output:

### 3. How many total transactions were there for each year in the dataset?

```sql
SELECT calender_year,
	SUM(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY calender_year
ORDER BY calender_year;
```

Output:

### 4. What is the total sales for each region for each month?

```sql
SELECT region, month_number,
	SUM(sales) as total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
```

Output:

### 5. What is the total count of transactions for each platform?

```sql
SELECT platform,
	SUM(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;
```

Output:

### 6. What is the percentage of sales for Retail vs Shopify for each month?

```sql
WITH platform_sales AS
(SELECT calender_year, month_number,
	SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) AS retail_sales,
    SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) AS shopify_sales,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calender_year, month_number
ORDER BY calender_year, month_number)
SELECT calender_year, month_number,
	ROUND(100.0 * (retail_sales/total_sales), 2) AS retail_sales_pct,
    ROUND(100.0 * (shopify_sales/total_sales), 2) AS shopify_sales_pct
FROM platform_sales;
```

Output:

### 7. What is the percentage of sales by demographic for each year in the dataset?

```sql
WITH demographic_sales AS
(SELECT calender_year,
	SUM(CASE WHEN demographic = 'Couples' THEN sales ELSE 0 END) AS couples_sales,
    SUM(CASE WHEN demographic = 'Families' THEN sales ELSE 0 END) AS families_sales,
    SUM(CASE WHEN demographic = 'unknown' THEN sales ELSE 0 END) AS unknown_sales,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calender_year
ORDER BY calender_year)
SELECT calender_year,
	ROUND(100.0 * (couples_sales/total_sales), 2) AS couples_sales_pct,
    ROUND(100.0 * (families_sales/total_sales), 2) AS families_sales_pct,
    ROUND(100.0 * (unknown_sales/total_sales), 2) AS unknown_sales_pct
FROM demographic_sales;
```

Output:

### 8. Which age_band and demographic values contribute the most to Retail sales?

```sql
SELECT age_band, demographic,
	ROUND(SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END),2) AS retail_sales
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY retail_sales DESC;
```

Output:

### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
SELECT calender_year,
		platform,
        ROUND(AVG(avg_transactions), 2) AS avg_transactions_1,
        ROUND(SUM(sales)/SUM(transactions), 2) AS avg_transactions_2
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY 1,2;
```

Output:
