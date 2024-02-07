### 1. What day of the week is used for each week_date value?

```sql
SELECT
	DISTINCT DAYNAME(week_date) AS Day_Name
FROM clean_weekly_sales;
```

Output:
| Day_name |
|----------|
| Monday |

#### Day of the Week Analysis for Weekly Sales Data

1. **Insight**:

   - The day of the week associated with each week_date value in the weekly_sales dataset is consistently Monday.

### 2. What range of week numbers are missing from the dataset?

```sql
WITH RECURSIVE NumbersSeries AS (
    SELECT 1 AS week_number
    UNION ALL
    SELECT week_number + 1
    FROM NumbersSeries
    WHERE week_number < 52
)
SELECT NumbersSeries.week_number
FROM NumbersSeries
WHERE NOT EXISTS (
    SELECT 1
    FROM clean_weekly_sales
    WHERE week_number = NumbersSeries.week_number
);
```

Output:
| week_number |
|-------------|
| 1 |
| 2 |
| 3 |
| 4 |
| 5 |
| 6 |
| 7 |
| 8 |
| 9 |
| 10 |
| 11 |
| 36 |
| 37 |
| 38 |
| 39 |
| 40 |
| 41 |
| 42 |
| 43 |
| 44 |
| 45 |
| 46 |
| 47 |
| 48 |
| 49 |
| 50 |
| 51 |
| 52 |

#### Missing Week Numbers in the Dataset

1. **Insight**:

   - Several week numbers are missing from the dataset, ranging from week 1 to week 11 and week 36 to week 52.

### 3. How many total transactions were there for each year in the dataset?

```sql
SELECT calendar_year,
	SUM(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
```

Output:
| calendar_year | total_transactions |
|---------------|---------------------|
| 2018 | 346,406,460 |
| 2019 | 365,639,285 |
| 2020 | 375,813,651 |

#### Total Transactions by Year

1. **Insight**:

   - The total number of transactions has shown a consistent upward trend over the years, with 2018 starting at a lower value compared to subsequent years.

### 4. What is the total sales for each region for each month?

```sql
SELECT region, month_number,
	SUM(sales) as total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
```

Output:
| region | month_number | total_sales |
|--------------|--------------|---------------|
| AFRICA | 3 | 567,767,480 |
| AFRICA | 4 | 1,911,783,504 |
| AFRICA | 5 | 1,647,244,738 |
| AFRICA | 6 | 1,767,559,760 |
| AFRICA | 7 | 1,960,219,710 |
| AFRICA | 8 | 1,809,596,890 |
| AFRICA | 9 | 276,320,987 |
| ASIA | 3 | 529,770,793 |
| ASIA | 4 | 1,804,628,707 |
| ASIA | 5 | 1,526,285,399 |
| ASIA | 6 | 1,619,482,889 |
| ASIA | 7 | 1,768,844,756 |
| ASIA | 8 | 1,663,320,609 |
| ASIA | 9 | 252,836,807 |
| CANADA | 3 | 144,634,329 |
| CANADA | 4 | 484,552,594 |
| CANADA | 5 | 412,378,365 |
| CANADA | 6 | 443,846,698 |
| CANADA | 7 | 477,134,947 |
| CANADA | 8 | 447,073,019 |
| CANADA | 9 | 69,067,959 |
| EUROPE | 3 | 35,337,093 |
| EUROPE | 4 | 127,334,255 |
| EUROPE | 5 | 109,338,389 |
| EUROPE | 6 | 122,813,826 |
| EUROPE | 7 | 136,757,466 |
| EUROPE | 8 | 122,102,995 |
| EUROPE | 9 | 18,877,433 |
| OCEANIA | 3 | 783,282,888 |
| OCEANIA | 4 | 2,599,767,620 |
| OCEANIA | 5 | 2,215,657,304 |
| OCEANIA | 6 | 2,371,884,744 |
| OCEANIA | 7 | 2,563,459,400 |
| OCEANIA | 8 | 2,432,313,652 |
| OCEANIA | 9 | 372,465,518 |
|SOUTH AMERICA | 3 | 71,023,109 |
|SOUTH AMERICA | 4 | 238,451,531 |
|SOUTH AMERICA | 5 | 201,391,809 |
|SOUTH AMERICA | 6 | 218,247,455 |
|SOUTH AMERICA | 7 | 235,582,776 |
|SOUTH AMERICA | 8 | 221,166,052 |
|SOUTH AMERICA | 9 | 34,175,583 |
| USA | 3 | 225,353,043 |
| USA | 4 | 759,786,323 |
| USA | 5 | 655,967,121 |
| USA | 6 | 703,878,990 |
| USA | 7 | 760,331,754 |
| USA | 8 | 712,002,790 |
| USA | 9 | 110,532,368 |

#### Total Sales by Region and Month

1. **Insight**:

   - Sales performance varies across regions and months, with some regions consistently outperforming others.

2. **Overview**:

   - Africa: Shows a consistent increase in sales from March to July before a slight decline in August and September.
   - Asia: Exhibits a similar trend to Africa, with increasing sales until July followed by a slight decrease in August and September.
   - Canada: Sales follow a pattern similar to Africa and Asia, with a peak in July followed by a decline in August and September.
   - Europe: Shows a steady increase in sales from March to July, followed by a slight decrease in August and September.
   - Oceania: Shows the highest sales among all regions, with a peak in July followed by a decline in August and September.
   - South America: Sales follow a similar pattern to other regions, with a peak in July followed by a decline in August and September.
   - USA: Shows a consistent increase in sales from March to July before a slight decline in August and September.

3. **Regional Variations**:

   - Oceania: consistently records the highest sales, indicating strong demand or market presence in that region.
   - Europe: Reports the lowest sales compared to other regions, suggesting potential opportunities for growth or market penetration strategies.

4. **Seasonal Trends**:

   - The months of March to July generally witness higher sales across all regions, suggesting potential seasonal factors or marketing campaigns driving increased consumer spending during this period.
   - The decline in sales observed in August and September across most regions could be attributed to seasonal factors, economic conditions, or specific market dynamics.

5. **Recommendations**:

   - Data Mart should analyze the factors contributing to the peak sales months to identify successful strategies and replicate them in other periods or regions.
   - Targeted marketing campaigns or promotions could be implemented during periods of lower sales to stimulate demand and boost revenue.
   - Understanding regional preferences and consumer behavior can help tailor marketing strategies and product offerings to maximize sales potential in each market.

### 5. What is the total count of transactions for each platform?

```sql
SELECT platform,
	SUM(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;
```

Output:
| platform | total_transactions |
|----------|---------------------|
| Retail | 1,081,934,227 |
| Shopify | 5,925,169 |

#### Total Transactions by Platform

1. **Insight**:

   - The majority of transactions occur through the Retail platform compared to the Shopify platform.

2. **Observations**:

   - The higher transaction count on the Retail platform suggests a strong presence in physical retail locations or a larger customer base utilizing traditional retail channels.
   - The lower transaction count on the Shopify platform may indicate a smaller but growing segment of customers preferring online shopping experiences.

3. **Opportunities**:

   - Data Mart could focus on enhancing its online platform to capture a larger share of the digital market and compete more effectively with traditional retail channels.
   - Leveraging data analytics and customer insights from both platforms can help optimize marketing strategies and product offerings to target specific customer segments more effectively.

### 6. What is the percentage of sales for Retail vs Shopify for each month?

```sql
WITH platform_sales AS
(SELECT calendar_year, month_number,
	SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) AS retail_sales,
    SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) AS shopify_sales,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number)
SELECT calendar_year, month_number,
	ROUND(100.0 * (retail_sales/total_sales), 2) AS retail_sales_pct,
    ROUND(100.0 * (shopify_sales/total_sales), 2) AS shopify_sales_pct
FROM platform_sales;
```

Output:
| calendar_year | month_number | retail_sales_pct | shopify_sales_pct |
|---------------|--------------|-------------------|---------------------|
| 2018 | 3 | 97.92 | 2.08 |
| 2018 | 4 | 97.93 | 2.07 |
| 2018 | 5 | 97.73 | 2.27 |
| 2018 | 6 | 97.76 | 2.24 |
| 2018 | 7 | 97.75 | 2.25 |
| 2018 | 8 | 97.71 | 2.29 |
| 2018 | 9 | 97.68 | 2.32 |
| 2019 | 3 | 97.71 | 2.29 |
| 2019 | 4 | 97.80 | 2.20 |
| 2019 | 5 | 97.52 | 2.48 |
| 2019 | 6 | 97.42 | 2.58 |
| 2019 | 7 | 97.35 | 2.65 |
| 2019 | 8 | 97.21 | 2.79 |
| 2019 | 9 | 97.09 | 2.91 |
| 2020 | 3 | 97.30 | 2.70 |
| 2020 | 4 | 96.96 | 3.04 |
| 2020 | 5 | 96.71 | 3.29 |
| 2020 | 6 | 96.80 | 3.20 |
| 2020 | 7 | 96.67 | 3.33 |
| 2020 | 8 | 96.51 | 3.49 |

#### Total Transactions by Platform

1. **Insight**:

   - The percentage of sales from the Retail platform consistently dominates over Shopify platform across monthsand years,indicatingthe continued siginificance of Physical stores. However, Shopify's contributionto total sales has been steadily increasing overtime, suggesting an opportunity to grow online sales.

### 7. What is the percentage of sales by demographic for each year in the dataset?

```sql
WITH demographic_sales AS
(SELECT calendar_year,
	SUM(CASE WHEN demographic = 'Couples' THEN sales ELSE 0 END) AS couples_sales,
    SUM(CASE WHEN demographic = 'Families' THEN sales ELSE 0 END) AS families_sales,
    SUM(CASE WHEN demographic = 'unknown' THEN sales ELSE 0 END) AS unknown_sales,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year)
SELECT calendar_year,
	ROUND(100.0 * (couples_sales/total_sales), 2) AS couples_sales_pct,
    ROUND(100.0 * (families_sales/total_sales), 2) AS families_sales_pct,
    ROUND(100.0 * (unknown_sales/total_sales), 2) AS unknown_sales_pct
FROM demographic_sales;
```

Output:
| calendar_year | couples_sales_pct | families_sales_pct | unknown_sales_pct |
|---------------|-------------------|--------------------|--------------------|
| 2018 | 26.38 | 31.99 | 41.63 |
| 2019 | 27.28 | 32.47 | 40.25 |
| 2020 | 28.72 | 32.73 | 38.55 |

#### Percentage of Sales by Demographic for Each Year

1. **Insight**:

   - Couples consistently contribute the least to total sales across all years, with families and unknown demographics making up the majority.

### 8. Which age_band and demographic values contribute the most to Retail sales?

```sql
SELECT age_band, demographic,
	ROUND(SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END),2) AS retail_sales
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY retail_sales DESC;
```

Output:
| age_band | demographic | retail_sales |
|----------------|-------------|----------------|
| unknown | unknown | 16067285533 |
| Retirees | Families | 6634686916 |
| Retirees | Couples | 6370580014 |
| Middle Aged | Families | 4354091554 |
| Young Adults | Couples | 2602922797 |
| Middle Aged | Couples | 1854160330 |
| Young Adults | Families | 1770889293 |

#### Retail Sales Contribution by Age Band and Demographic

1. **Insight**:

   - The demographic category "Unknown" contributes significantly more to retail sales compared to other age bands and demographics, indicating that a large portion of sales data lacks detailed demographic information.
   - Among known demographics, retirees, especially those in families, contribute significantly to retail sales, followed by middle-aged customers, primarily in families and couples.
   - Young adults, both in couples and families, contribute less compared to retirees and middle-aged individuals.

### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
SELECT calendar_year, platform,
        ROUND(AVG(avg_transaction), 2) AS avg_transactions_1,
        ROUND(SUM(sales)/SUM(transactions), 2) AS avg_transactions_2
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```

Output:
| calendar_year | platform | avg_transactions_1 | avg_transactions_2 |
|---------------|----------|--------------------|--------------------|
| 2018 | Retail | 42.91 | 36.56 |
| 2018 | Shopify | 188.28 | 192.48 |
| 2019 | Retail | 41.97 | 36.83 |
| 2019 | Shopify | 177.56 | 183.36 |
| 2020 | Retail | 40.64 | 36.56 |
| 2020 | Shopify | 174.87 | 179.03 |

#### Average Transaction Size Comparison

1. **Insights**:

   - Avg_Transactions_1: Represents the average value of the avg_transaction column directly. This approach yields different results for each platform, reflecting the variability in average transaction sizes within each platform.
   - Avg_Transactions_2: Calculated by dividing the total sales by the total number of transactions. This method provides a more accurate reflection of the average transaction size, considering the actual sales amounts and transaction counts. It ensures consistency in calculation across platforms, making it a more reliable metric for comparison.
