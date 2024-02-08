### 1. How many users are there?

```sql
SELECT
	COUNT(DISTINCT user_id) AS number_of_unique_users
FROM users;
```

Output:
| number_of_unique_users |
|------------------------|
| 500 |

#### Analysis of Number of Unique Users

1. **Insight**:

   - The dataset contains information about 500 unique users who have visited the Clique Bait website.

### 2. How many cookies does each user have on average?

```sql
WITH cookie AS (
SELECT user_id,
        COUNT(cookie_id) AS cookie_count
FROM users GROUP BY user_id
)
SELECT ROUND(AVG(cookie_count),0) AS average_cookie_per_user
FROM cookie;
```

Output:
| average_cookie_per_user |
|------------------------|
| 4 |

#### Analysis of Average Number of Cookies per User

1. **Insight**:

   - On average, each user has approximately 4 cookies associated with their user account.

### 3. What is the unique number of visits by all users per month?

```sql
SELECT
	MONTH(event_time) AS 'month',
	COUNT(DISTINCT visit_id) AS customer_count
FROM events
GROUP BY MONTH(event_time);
```

Output:
| month | customer_count |
|-------|----------------|
| 1 | 876 |
| 2 | 1488 |
| 3 | 916 |
| 4 | 248 |
| 5 | 36 |

#### Analysis of Unique Number of Visits per Month

1. **Insights**:

   - Seasonal Trends: The data shows fluctuations in customer visits across different months, indicating potential seasonal patterns or shifts in user behavior.
   - Peak Months: February witnessed the highest number of unique visits, suggesting increased activity or interest during that period.
   - Monthly Variability: There is variability in customer engagement across months, with some months experiencing higher or lower visit counts compared to others.

### 4. What is the number of events for each event type?

```sql
SELECT EI.event_name,
	COUNT(E.event_time) AS number_of_events
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
GROUP BY EI.event_name
ORDER BY number_of_events DESC;
```

Output:
| event_name | number_of_events |
|----------------|-------------------|
| Page View | 20928 |
| Add to Cart | 8451 |
| Purchase | 1777 |
| Ad Impression | 876 |
| Ad Click | 702 |

#### Analysis of Number of Events by Event Type

1. **Insights**:

   - Event Distribution: Page views constitute the majority of events, indicating high user engagement with various pages on the website.
   - Conversion Actions: While page views are common, fewer users proceed to add items to their cart or make purchases, as evidenced by the lower counts for "Add to Cart" and "Purchase" events.
   - Marketing Engagement: The number of ad impressions and ad clicks suggests user interaction with advertising content, which can provide insights into the effectiveness of marketing campaigns.

### 5. What is the percentage of visits which have a purchase event?

```sql
SELECT
	ROUND(100.0 * COUNT(DISTINCT E.visit_id) / (SELECT COUNT(DISTINCT visit_id) FROM events),2)
    AS vists_percentage
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
WHERE EI.event_name = 'Purchase';
```

Output:
| visits_percentage |
|------------------------|
| 49.86 |

#### Analysis of Percentage of Visits with Purchase Events

1. **Insights**:

   - Purchase Rate: Approximately 49.86% of visits result in a purchase event, indicating a moderate conversion rate.
   - Conversion Performance: Understanding the proportion of visits that lead to purchases provides insights into the effectiveness of the website in driving sales.
   - Potential Growth Opportunities: Identifying areas for improvement in the conversion funnel to increase the purchase rate and enhance overall revenue generation.

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

```sql
WITH view_purchase AS (
SELECT
	COUNT(E.visit_id) AS visit_count
FROM events AS E JOIN event_identifier AS EI ON E.event_type = EI.event_type
JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE PH.page_name = 'Checkout' and EI.event_name = 'Page View')
SELECT
	ROUND(100 - (100.0 * COUNT(DISTINCT E.visit_id) /
		(SELECT visit_count FROM view_purchase)),2) AS pct_of_checkout_visits_not_purchased
FROM events AS E JOIN event_identifier AS EI ON E.event_type = EI.event_type
WHERE EI.event_name = 'Purchase';
```

Output:
| pct_of_checkout_visits_not_purchased |
|------------------------|
| 15.50 |

#### Analysis of Percentage of Visits Viewing Checkout Page but Not Making a Purchase

1. **Insights**:

   - Checkout Abandonment: Approximately 15.50% of visits proceed to the checkout page but do not culminate in a purchase, indicating a significant dropout rate.
   - Potential Revenue Loss: Identifying and addressing factors contributing to checkout abandonment is crucial to mitigate potential revenue loss and maximize conversion rates.
   - User Experience Evaluation: Analyzing the user experience at the checkout stage, including ease of navigation, payment options, and shipping information, can provide insights into areas for improvement.

### 7. What are the top 3 pages by number of views?

```sql
WITH top_3_pages AS
(SELECT
	page_id, COUNT(DISTINCT visit_id) AS number_of_views
FROM events
WHERE event_type = '1'
GROUP BY page_id
ORDER BY number_of_views DESC
LIMIT 3
)
SELECT
	page_name, number_of_views
FROM top_3_pages
JOIN page_hierarchy ON top_3_pages.page_id = page_hierarchy.page_id;
```

Output:
| page_name | number_of_views |
|---------------|------------------|
| Home Page | 1782 |
| All Products | 3174 |
| Checkout | 2103 |

#### Analysis of Top 3 Pages by Number of Views

1. **Insights**:

   - User Engagement: The Home Page, All Products, and Checkout pages are pivotal in user navigation, as evidenced by their high view counts.
   - Browsing Behavior: Users frequently visit the All Products page, indicating a strong interest in exploring available products or services.
   - Checkout Process: The significant number of views on the Checkout page underscores its importance in the conversion journey, suggesting a substantial portion of users progress towards completing transactions.

### 8. What is the number of views and cart adds for each product category?

```sql
SELECT PH.product_category,
	   SUM(CASE WHEN E.event_type = '1' THEN 1 ELSE 0 END) AS number_of_views,
	   SUM(CASE WHEN E.event_type = '2' THEN 1 ELSE 0 END) AS number_of_cart_adds
FROM events as E
JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE PH.product_category IS NOT NULL
GROUP BY PH.product_category
ORDER BY PH.product_category;
```

Output:
| product_category | number_of_views | number_of_cart_adds |
|------------------|------------------|----------------------|
| Fish | 4633 | 2789 |
| Luxury | 3032 | 1870 |
| Shellfish | 6204 | 3792 |

#### Analysis of Product Category Views and Cart Adds

1. **Insights**:

   - Popular Categories: Shellfish has the highest number of views and cart additions, followed by Fish and Luxury categories.
   - Engagement Discrepancy: Despite Fish having fewer views compared to Shellfish, it has a relatively higher cart addition rate, indicating stronger user intent or interest in purchasing Fish products.
   - Conversion Opportunities: Analyzing user behavior within each category can help identify opportunities to optimize product pages, pricing strategies, or promotional efforts to drive conversions.

### 9. What are the top 3 products by purchases?

```sql
SELECT
	PH.product_id,
    PH.page_name,
    PH.product_category,
    COUNT(PH.product_id) AS product_count
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
JOIN page_hierarchy AS PH ON PH.page_id = E.page_id
WHERE EI.event_name = 'Add to Cart' AND E.visit_id IN
	(SELECT E.visit_id FROM events as E
     JOIN event_identifier AS EI ON E.event_type = EI.event_type WHERE EI.event_name = 'Purchase')
GROUP BY PH.product_id, PH.page_name, PH.product_category
ORDER BY product_count DESC
LIMIT 3;
```

Output:
| product_id | product_name | product_category | product_count |
|------------|--------------|-------------------|---------------|
| 7 | Lobster | Shellfish | 754 |
| 9 | Oyster | Shellfish | 726 |
| 8 | Crab | Shellfish | 719 |

#### Analysis of Top 3 Products by Purchases

1. **Insights**:

   - Shellfish Dominance: All top 3 products belong to the Shellfish category, indicating its popularity among customers.
   - High Demand Items: Lobster, Oyster, and Crab are evidently high-demand items within the Shellfish category, likely due to factors such as taste, availability, and pricing.
   - Cross-Promotion Opportunities: Identifying complementary products or bundle offers with these top-selling items can help increase average order value and enhance customer satisfaction.
