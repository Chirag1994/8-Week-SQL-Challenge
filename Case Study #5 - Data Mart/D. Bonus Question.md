### Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

    -- region
    -- platform
    -- age_band
    -- demographic
    -- customer_type

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

-- Sales metric performance across region.

```sql
WITH before_and_after_data AS
	   (SELECT region,
			week_number,
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		GROUP BY 1,2
		ORDER BY 1,2
	   ),
	   sales_calculation_table_before_and_after AS (
	   SELECT region,
			SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
			SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
			FROM before_and_after_data
			GROUP BY region
			)
		SELECT region,
			sales_before_baseline_date_value, sales_after_baseline_date_value,
			(sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
			ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/
				sales_before_baseline_date_value,2) AS pct
		FROM sales_calculation_table_before_and_after;
```

Output:

-- Sales metric performance across platform.

```sql
WITH before_and_after_data AS
	   (SELECT platform,
			week_number,
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		GROUP BY 1,2
		ORDER BY 1,2
	   ),
	   sales_calculation_table_before_and_after AS (
	   SELECT platform,
			SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
			SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
			FROM before_and_after_data
			GROUP BY platform
			)
		SELECT platform,
			sales_before_baseline_date_value, sales_after_baseline_date_value,
			(sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
			ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/
				sales_before_baseline_date_value,2) AS pct
		FROM sales_calculation_table_before_and_after;
```

Output:

-- Sales metric performance across age_band.

```sql
WITH before_and_after_data AS
	   (SELECT age_band,
			week_number,
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		GROUP BY 1,2
		ORDER BY 1,2
	   ),
	   sales_calculation_table_before_and_after AS (
	   SELECT age_band,
			SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
			SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
			FROM before_and_after_data
			GROUP BY age_band
			)
		SELECT age_band,
			sales_before_baseline_date_value, sales_after_baseline_date_value,
			(sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
			ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/
				sales_before_baseline_date_value,2) AS pct
		FROM sales_calculation_table_before_and_after;
```

Output:

-- Sales metric performance across customer_type.

```sql
WITH before_and_after_data AS
	   (SELECT customer_type,
			week_number,
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		GROUP BY 1,2
		ORDER BY 1,2
	   ),
	   sales_calculation_table_before_and_after AS (
	   SELECT customer_type,
			SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
			SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
			FROM before_and_after_data
			GROUP BY customer_type
			)
		SELECT customer_type,
			sales_before_baseline_date_value, sales_after_baseline_date_value,
			(sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
			ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/
				sales_before_baseline_date_value,2) AS pct
		FROM sales_calculation_table_before_and_after;
```
