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
| Region | Sales Before Baseline Date | Sales After Baseline Date | Difference | Percent Change |
|---------------|-----------------------------|----------------------------|------------|----------------|
| AFRICA | 4942976910 | 4997516159 | 54539249 | 1.10 |
| ASIA | 4613242689 | 4551927271 | -61315418 | -1.33 |
| CANADA | 1244662705 | 1234025206 | -10637499 | -0.85 |
| EUROPE | 328141414 | 344420043 | 16278629 | 4.96 |
| OCEANIA | 6698586333 | 6640244793 | -58341540 | -0.87 |
| SOUTH AMERICA | 611056923 | 608981392 | -2075531 | -0.34 |
| USA | 1967554887 | 1960297502 | -7257385 | -0.37 |

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
| Platform | Sales Before Baseline Date | Sales After Baseline Date | Difference | Percent Change |
|----------|-----------------------------|----------------------------|-------------|----------------|
| Retail | 19886040272 | 19768576165 | -117464107 | -0.59 |
| Shopify | 520181589 | 568836201 | 48654612 | 9.35 |

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
| Age Band | Sales Before Baseline Date | Sales After Baseline Date | Difference | Percent Change |
|--------------|-----------------------------|----------------------------|-------------|----------------|
| Middle Aged | 3276892347 | 3269748622 | -7143725 | -0.22 |
| Retirees | 6646865322 | 6634706880 | -12158442 | -0.18 |
| Unknown | 8191628826 | 8146983408 | -44645418 | -0.55 |
| Young Adults | 2290835366 | 2285973456 | -4861910 | -0.21 |

-- Sales metric performance across demographic.

```sql
WITH before_and_after_data AS
	   (SELECT demographic,
			week_number,
			SUM(sales) AS total_sales
			FROM clean_weekly_sales
		GROUP BY 1,2
		ORDER BY 1,2
	   ),
	   sales_calculation_table_before_and_after AS (
	   SELECT demographic,
			SUM(CASE WHEN week_number < 24 THEN total_sales ELSE 0 END) AS sales_before_baseline_date_value,
			SUM(CASE WHEN week_number >= 24 THEN total_sales ELSE 0 END) AS sales_after_baseline_date_value
			FROM before_and_after_data
			GROUP BY demographic
			)
		SELECT demographic,
			sales_before_baseline_date_value, sales_after_baseline_date_value,
			(sales_after_baseline_date_value - sales_before_baseline_date_value) AS difference,
			ROUND(100.0 * (sales_after_baseline_date_value - sales_before_baseline_date_value)/
				sales_before_baseline_date_value,2) AS pct
		FROM sales_calculation_table_before_and_after;
```

Output:
| Demographic | Sales Before Baseline Date | Sales After Baseline Date | Difference | Percent Change |
|-------------|----------------------------|---------------------------|-------------|----------------|
| Couples | 5608866131 | 5592341420 | -16524711 | -0.29 |
| Families | 6605726904 | 6598087538 | -7639366 | -0.12 |
| Unknown | 8191628826 | 8146983408 | -44645418 | -0.55 |

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

Output:
| Customer Type | Sales Before Baseline Date | Sales After Baseline Date | Difference | Percent Change |
|---------------|----------------------------|---------------------------|-------------|----------------|
| Existing | 10168877642 | 10117367239 | -51510403 | -0.51 |
| Guest | 7630353739 | 7595150744 | -35202995 | -0.46 |
| New | 2606990480 | 2624894383 | 17903903 | 0.69 |

#### Sales Metric Performance Analysis Across Different Business Areas

1. **Sales Metric Performance Across Regions**:

   - Africa: Experienced a slight increase in sales (1.10%) after the baseline date.
   - Asia: Witnessed a decrease in sales (-1.33%) after the baseline date, indicating a negative impact.
   - Canada: Saw a minor decrease in sales (-0.85%) after the baseline date.
   - Europe: Showed a significant increase in sales (4.96%) after the baseline date, indicating positive performance.
   - Oceania: Experienced a decrease in sales (-0.87%) after the baseline date.
   - South America: Saw a slight decrease in sales (-0.34%) after the baseline date.
   - USA: Witnessed a decrease in sales (-0.37%) after the baseline date.

2. **Sales Metric Performance Across Platforms**:

   - Retail: Experienced a decrease in sales (-0.59%) after the baseline date.
   - Shopify: Witnessed a significant increase in sales (9.35%) after the baseline date, indicating positive performance.

3. **Sales Metric Performance Across Age Bands**:

   - Middle Aged: Experienced a minor decrease in sales (-0.22%) after the baseline date.
   - Retirees: Saw a slight decrease in sales (-0.18%) after the baseline date.
   - Unknown: Witnessed a notable decrease in sales (-0.55%) after the baseline date.
   - Young Adults: Experienced a minor decrease in sales (-0.21%) after the baseline date.

4. **Sales Metric Performance Across Demographics**:

   - Couples: Experienced a slight decrease in sales (-0.29%) after the baseline date.
   - Families: Saw a minor decrease in sales (-0.12%) after the baseline date.
   - Unknown: Witnessed a notable decrease in sales (-0.55%) after the baseline date.

5. **Sales Metric Performance Across Customer Types**:

   - Existing Customers: Experienced a decrease in sales (-0.51%) after the baseline date.
   - Guest Customers: Witnessed a decrease in sales (-0.46%) after the baseline date.
   - New Customers: Saw an increase in sales (0.69%) after the baseline date, indicating positive performance.

#### Conclusion and Recommendations:

    - Overall Sales Performance: The analysis reveals mixed performance across different regions, platforms, age bands, demographics, and customer types.
    - Positive Trends: Europe and Shopify platform showed significant increases in sales, suggesting areas of potential growth.
    - Negative Trends: Asia, Oceania, and certain demographic segments experienced decreases in sales, requiring further investigation into underlying factors.

    - Recommendations: Danny’s team should focus on leveraging positive trends, such as expanding operations in regions with growing sales and optimizing sales strategies for specific customer segments. Additionally, they should address issues contributing to sales declines, such as exploring new marketing strategies or improving product offerings. Regular monitoring and analysis of sales metrics across different business areas will be crucial for identifying opportunities and addressing challenges in the future.
