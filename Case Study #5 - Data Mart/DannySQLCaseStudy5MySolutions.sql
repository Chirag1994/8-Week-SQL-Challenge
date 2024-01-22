/* ------------------------- 1. Data Cleansing Steps ------------------------- */
  USE data_mart;
  /* In a single query, perform the following operations and generate a new table in the data_mart 
	schema named clean_weekly_sales:
    -- Convert the week_date to a DATE format
    -- Add a week_number as the second column for each week_date value, for example any value from the 1st of 
       January to 7th of January will be 1, 8th to 14th will be 2 etc.
	-- Add a month_number with the calendar month for each week_date value as the 3rd column
    -- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
    -- Add a new column called age_band after the original segment column using the following mapping on 
       the number inside the segment value:
			____________________
			|segment | age_band|
            ____________________
			|1	| Young Adults |
			|2	| Middle Aged  |
			|3 or 4	| Retirees | */
	/* Add a new demographic column using the following mapping for the first letter in the segment values:
	____________________
	|segment | demographic|
    ____________________
	|C	| Couples|
	|F	| Families| */

-- Ensure all null string values with an "unknown" string value in the original segment column as well as 
	-- the new age_band and demographic columns
-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places 
	-- for each record
            
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

SELECT * FROM clean_weekly_sales;

/* ------------------------- 2. Data Exploration ------------------------- */
-- 1. What day of the week is used for each week_date value?
SELECT DISTINCT DAYNAME(formatted_week_date) AS Day_Name FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?
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
    WHERE week_number = NumbersSeries.number
);

-- 3. How many total transactions were there for each year in the dataset?
SELECT calender_year,
	SUM(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY calender_year
ORDER BY calender_year;

-- 4. What is the total sales for each region for each month?
SELECT region, month_number,
	SUM(sales) as total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- 5. What is the total count of transactions for each platform?
SELECT platform,
	SUM(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
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

-- 7. What is the percentage of sales by demographic for each year in the dataset?
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

-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band, demographic,
	ROUND(SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END),2) AS retail_sales
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY retail_sales DESC;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
	-- If not - how would you calculate it instead?
SELECT calender_year,
		platform,
        ROUND(AVG(avg_transactions), 2) AS avg_transactions_1,
        ROUND(SUM(sales)/SUM(transactions), 2) AS avg_transactions_2
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY 1,2;

/* ------------------------- 3. Before & After Analysis ------------------------- */       
/* This technique is usually used when we inspect an important event and want to inspect the impact before and 
   after a certain point in time.
   Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging 
   changes came into effect.
   We would include all week_date values for 2020-06-15 as the start of the period after the change and the 
   previous week_date values would be before    
   Using this analysis approach - answer the following questions:
   -- 1. What is the total sales for the 4 weeks before and after 2020-06-15? 
		 What is the growth or reduction rate in actual values and percentage of sales? */
         
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
         
   -- 2. What about the entire 12 weeks before and after?
    WITH before_and_after_data AS
   (SELECT week_date,
		week_number, 
        SUM(sales) AS total_sales
        FROM clean_weekly_sales
    WHERE calendar_year = '2020'
    GROUP BY 1,2
    ORDER BY 1,2
   ),
   sales_calculation_table_before_and_after AS (
   SELECT 
		SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
        SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
        FROM before_and_after_data
        )
    SELECT 
		sales_before_baseline_date_value, sales_after_baseline_date_value,
        (sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
        ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/sales_before_baseline_date_value,2) AS pct
	FROM sales_calculation_table_before_and_after;   
   
   -- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
   -- Part 3.1: How do the sale metrics for these 2 periods before and after compare with the previous years 
   -- in 2018 and 2019 for 4 weeks period?
	WITH before_and_after_data AS
	   (SELECT calendar_year,
			week_number, 
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		WHERE (week_number BETWEEN 20 AND 27)
		GROUP BY 1,2
		ORDER BY 1,2
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
   
-- Part 3.2: How do the sale metrics for these 2 periods before and after compare with the previous years 
-- in 2018 and 2019 for 12 weeks period?
	WITH before_and_after_data AS
	   (SELECT calendar_year,
			week_number, 
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		GROUP BY 1,2
		ORDER BY 1,2
	   ),
	   sales_calculation_table_before_and_after AS (
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
   
/* ------------------------- 4. Bonus Question ------------------------- */ 
/* Which areas of the business have the highest negative impact in sales metrics performance in 2020 for 
   the 12 week before and after period?
   -- region
   -- platform
   -- age_band
   -- demographic
   -- customer_type
   Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights 
   based off this analysis? */