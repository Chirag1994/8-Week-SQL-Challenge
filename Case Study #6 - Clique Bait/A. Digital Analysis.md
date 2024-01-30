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

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

Output:

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

### 9. What are the top 3 products by purchases?

Output:
