### 1. How many users are there?

```sql
SELECT
	COUNT(DISTINCT user_id) AS number_of_unique_users
FROM users;
```

Output:

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

### 3. What is the unique number of visits by all users per month?

```sql
SELECT
	MONTH(event_time) AS 'month',
	COUNT(DISTINCT visit_id)
FROM events
GROUP BY MONTH(event_time);
```

Output:

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

### 5. What is the percentage of visits which have a purchase event?

```sql
SELECT
	ROUND(100.0 * COUNT(DISTINCT E.visit_id) / (SELECT COUNT(DISTINCT visit_id) FROM events),2)
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
WHERE EI.event_name = 'Purchase';
```

Output:

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

Output:

### 7. What are the top 3 pages by number of views?

```sql
WITH top_3_pages AS
(SELECT page_id, COUNT(DISTINCT visit_id) AS number_of_views
FROM events
WHERE event_type = '1'
GROUP BY page_id
ORDER BY number_of_views DESC
LIMIT 3)
SELECT page_name, number_of_views
FROM top_3_pages
JOIN page_hierarchy ON top_3_pages.page_id = page_hierarchy.page_id;
```

Output:

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

### 9. What are the top 3 products by purchases?

Output:
