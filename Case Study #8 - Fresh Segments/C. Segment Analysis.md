### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year.

Top 10 interests which have the largest values in any month_year

```sql
WITH max_composition_cte AS (
    SELECT
        month_year,
        interest_name,
        MAX(composition) OVER (PARTITION BY interest_id) AS max_composition
    FROM modified_interest_metrics JOIN interest_map
    ON modified_interest_metrics.interest_id = interest_map.id
    WHERE interest_name IS NOT NULL
    ), composition_rank_cte AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY max_composition DESC) AS max_composition_ranking
    FROM max_composition_cte
    )
    (
    SELECT
        DISTINCT interest_name,
        max_composition,
        max_composition_ranking FROM
    composition_rank_cte
    WHERE max_composition_ranking <= 10);
```

Output:
| interest_name | max_composition | max_composition_ranking |
|------------------------------------|-----------------|--------------------------|
| Work Comes First Travelers | 21.2 | 1 |
| Gym Equipment Owners | 18.82 | 2 |
| Furniture Shoppers | 17.44 | 3 |
| Luxury Retail Shoppers | 17.19 | 4 |
| Luxury Boutique Hotel Researchers | 15.15 | 5 |
| Luxury Bedding Shoppers | 15.05 | 6 |
| Shoe Shoppers | 14.91 | 7 |
| Cosmetics and Beauty Shoppers | 14.23 | 8 |
| Luxury Hotel Guests | 14.1 | 9 |
| Luxury Retail Researchers | 13.97 | 10 |

Bottom 10 interests which have the largest values in any month_year

```sql
WITH max_composition_cte AS (
    SELECT
        month_year,
        interest_name,
        MAX(composition) OVER (PARTITION BY interest_id) AS max_composition
    FROM modified_interest_metrics
    JOIN interest_map
    ON modified_interest_metrics.interest_id = interest_map.id
    WHERE interest_name IS NOT NULL
    ), composition_rank_cte AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY max_composition DESC) AS max_composition_ranking
    FROM max_composition_cte
)
(SELECT
    DISTINCT interest_name,
    max_composition,
    max_composition_ranking
    FROM composition_rank_cte
    ORDER BY max_composition_ranking DESC LIMIT 10);
```

Output:
| interest_name | max_composition | max_composition_ranking |
|--------------------------------------|-----------------|--------------------------|
| Astrology Enthusiasts | 1.88 | 555 |
| Medieval History Enthusiasts | 1.94 | 554 |
| Dodge Vehicle Shoppers | 1.97 | 553 |
| Xbox Enthusiasts | 2.05 | 552 |
| Camaro Enthusiasts | 2.08 | 551 |
| Budget Mobile Phone Researchers | 2.09 | 550 |
| League of Legends Video Game Fans | 2.09 | 550 |
| Super Mario Bros Fans | 2.12 | 549 |
| Oakland Raiders Fans | 2.14 | 548 |
| Budget Wireless Shoppers | 2.18 | 547 |

### 2. Which 5 interests had the lowest average ranking value?

```sql
SELECT
	DISTINCT IM.interest_name,
    ROUND(1.0 * AVG(MIM.ranking), 2) AS avg_ranking
FROM modified_interest_metrics AS MIM
JOIN interest_map AS IM
ON MIM.interest_id = IM.id
GROUP BY IM.interest_name
ORDER BY avg_ranking ASC
LIMIT 5;
```

Output:
| interest_name | avg_ranking |
|-----------------------------------|-------------|
| Winter Apparel Shoppers | 1.00 |
| Fitness Activity Tracker Users | 4.11 |
| Mens Shoe Shoppers | 5.93 |
| Shoe Shoppers | 9.36 |
| Preppy Clothing Shoppers | 11.86 |

### 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

```sql
SELECT
    DISTINCT MIM.interest_id,
    IM.interest_name,
    IM.interest_summary,
    ROUND(STDDEV(MIM.percentile_ranking) OVER (PARTITION BY MIM.interest_id),2) AS largest_std_percentile_ranking
FROM modified_interest_metrics AS MIM JOIN interest_map AS IM
ON MIM.interest_id = IM.id
ORDER BY largest_std_percentile_ranking DESC
LIMIT 5;
```

Output:
| interest_id | interest_name | interest_summary | largest_std_percentile_ranking |
|-------------|----------------------------------------|-----------------------------------------------------------------|--------------------------------|
| 23 | Techies | Readers of tech news and gadget reviews. | 27.55 |
| 38992 | Oregon Trip Planners | People researching attractions and accommodations in Oregon. These consumers are more likely to spend money on travel and local attractions. | 26.87 |
| 20764 | Entertainment Industry Decision Makers | Professionals reading industry news and researching trends in the entertainment industry. | 26.45 |
| 43546 | Personalized Gift Shoppers | Consumers shopping for gifts that can be personalized. | 24.55 |
| 103 | Live Concert Fans | Consumers researching live concerts and music festivals. | 23.45 |

### 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

```sql

```

Output:

### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

We will follow the following steps to solve this question:

- Step 1: Drop the temporary table after use
- Step 2: Create a temporary table to store intermediate results
- Step 3: Use the temporary table in the CTE

```sql
DROP TEMPORARY TABLE IF EXISTS interest_metrics_map_temp

CREATE TEMPORARY TABLE interest_metrics_map_temp AS
    SELECT
        MIM.interest_id,
        MI.interest_name,
        MI.interest_summary,
        MIM.percentile_ranking
    FROM modified_interest_metrics MIM
    JOIN interest_map MI
    ON MIM.interest_id = MI.id;

WITH largest_std_interests_cte AS (
    SELECT
        DISTINCT interest_id,
        interest_name,
        interest_summary,
        ROUND(STDDEV(percentile_ranking) OVER (PARTITION BY interest_id), 2) AS std_percentile_ranking
    FROM interest_metrics_map_temp
    ORDER BY std_percentile_ranking DESC
    LIMIT 5
), max_min_percentiles AS (
    SELECT
        LSIC.interest_id,
        LSIC.interest_name,
        LSIC.interest_summary,
        MIM.month_year,
        MIM.percentile_ranking,
        MAX(MIM.percentile_ranking) OVER (PARTITION BY LSIC.interest_id) AS max_pct_rnk,
        MIN(MIM.percentile_ranking) OVER (PARTITION BY LSIC.interest_id) AS min_pct_rnk
    FROM largest_std_interests_cte LSIC
    JOIN modified_interest_metrics MIM
    ON LSIC.interest_id = MIM.interest_id
)
	SELECT
        interest_id,
        interest_name,
        interest_summary,
        MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN month_year END) AS max_pct_month_year,
        MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN percentile_ranking END) AS max_pct_rnk,
        MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN month_year END) AS min_pct_month_year,
        MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN percentile_ranking END) AS min_pct_rnk
    FROM max_min_percentiles
    GROUP BY interest_id, interest_name, interest_summary;
```

Output:
| interest_id | interest_name | interest_summary | max_pct_month_year | max_pct_rank | min_pct_month_year | min_pct_rank |
|-------------|----------------------------------------|-----------------------------------------------------------------|--------------------|--------------|--------------------|--------------|
| 103 | Live Concert Fans | Consumers researching live concerts and music festivals. | 2018-07-01 | 95.61 | 2019-07-01 | 18.75 |
| 20764 | Entertainment Industry Decision Makers | Professionals reading industry news and researching trends in the entertainment industry. | 2018-07-01 | 86.15 | 2019-08-01 | 11.23 |
| 23 | Techies | Readers of tech news and gadget reviews. | 2018-07-01 | 86.69 | 2019-08-01 | 7.92 |
| 38992 | Oregon Trip Planners | People researching attractions and accommodations in Oregon. These consumers are more likely to spend money on travel and local attractions. | 2018-11-01 | 82.44 | 2019-07-01 | 2.20 |
| 43546 | Personalized Gift Shoppers | Consumers shopping for gifts that can be personalized. | 2019-03-01 | 73.15 | 2019-06-01 | 5.70 |
