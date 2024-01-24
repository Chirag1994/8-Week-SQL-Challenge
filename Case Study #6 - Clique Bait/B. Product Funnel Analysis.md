### PART 1

Use temporary table instead of INTO for CTEs

```sql
CREATE TEMPORARY TABLE view_add_to_cart_cte AS
SELECT
    PH.product_id,
    PH.page_name AS product_name,
    PH.product_category,
    SUM(CASE WHEN EI.event_name = 'Page View' THEN 1 ELSE 0 END) AS view_counts,
    SUM(CASE WHEN EI.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS add_to_cart_counts
FROM
    events AS E
    JOIN event_identifier AS EI ON E.event_type = EI.event_type
    JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE
    PH.product_category IS NOT NULL
GROUP BY
    PH.product_id, PH.page_name, PH.product_category;
```

```sql
CREATE TEMPORARY TABLE products_abandoned_cte AS
SELECT
    PH.product_id,
    PH.page_name AS product_name,
    PH.product_category,
    COUNT(*) AS abandoned
FROM
    events AS E
    JOIN event_identifier AS EI ON E.event_type = EI.event_type
    JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE
    EI.event_name = 'Add to Cart'
    AND E.visit_id NOT IN (
        SELECT E.visit_id
        FROM events AS E
        JOIN event_identifier AS EI ON E.event_type = EI.event_type
        WHERE EI.event_name = 'Purchase'
    )
GROUP BY
    PH.product_id, PH.page_name, PH.product_category;
```

```sql
CREATE TEMPORARY TABLE products_purchased_cte AS
SELECT
    PH.product_id,
    PH.page_name AS product_name,
    PH.product_category,
    COUNT(\*) AS purchased
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE EI.event_name = 'Add to Cart' AND E.visit_id IN (
        SELECT E.visit_id
        FROM events AS E
        JOIN event_identifier AS EI ON E.event_type = EI.event_type
        WHERE EI.event_name = 'Purchase')
GROUP BY
PH.product_id, PH.page_name, PH.product_category;
```

Use temporary table instead of INTO for the final result

```sql
CREATE TEMPORARY TABLE product_information AS
SELECT
    VATC.*,
    AB.abandoned,
    PP.purchased
FROM
view_add_to_cart_cte AS VATC
JOIN products_abandoned_cte AS AB ON VATC.product_id = AB.product_id
JOIN products_purchased_cte AS PP ON VATC.product_id = PP.product_id;
```

-- Select from the temporary table

```sql
SELECT * FROM product_information
ORDER BY product_id;
```

-- Drop the temporary tables when done

```sql
DROP TEMPORARY TABLE IF EXISTS view_add_to_cart_cte, products_abandoned_cte, products_purchased_cte;
```

Output:

### PART 2

Use temporary table instead of INTO for CTEs

```sql
CREATE TEMPORARY TABLE category_view_add_to_cart_cte AS
SELECT
    PH.product_category,
    SUM(CASE WHEN EI.event_name = 'Page View' THEN 1 ELSE 0 END) AS view_counts,
    SUM(CASE WHEN EI.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS add_to_cart_counts
FROM events AS E
    JOIN event_identifier AS EI ON E.event_type = EI.event_type
    JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE PH.product_category IS NOT NULL
GROUP BY PH.product_category;
```

```sql
CREATE TEMPORARY TABLE category_products_abandoned_cte AS
SELECT
    PH.product_category,
    COUNT(\*) AS abandoned
    FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE EI.event_name = 'Add to Cart' AND E.visit_id NOT IN (
        SELECT E.visit_id
        FROM events AS E
        JOIN event_identifier AS EI ON E.event_type = EI.event_type
        WHERE EI.event_name = 'Purchase')
GROUP BY PH.product_category;
```

```sql
CREATE TEMPORARY TABLE category_products_purchased_cte AS
SELECT
    PH.product_category,
    COUNT(\*) AS purchased
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
JOIN page_hierarchy AS PH ON E.page_id = PH.page_id
WHERE EI.event_name = 'Add to Cart'
AND E.visit_id IN (SELECT E.visit_id
    FROM events AS E
    JOIN event_identifier AS EI ON E.event_type = EI.event_type
    WHERE EI.event_name = 'Purchase')
GROUP BY PH.product_category;
```

Use temporary table instead of INTO for the final result

```sql
CREATE TEMPORARY TABLE category_product_information AS
SELECT
    VATC.*, AB.abandoned, PP.purchased
FROM category_view_add_to_cart_cte AS VATC
JOIN category_products_abandoned_cte AS AB ON VATC.product_category = AB.product_category
JOIN category_products_purchased_cte AS PP ON VATC.product_category = PP.product_category;
```

Select from the temporary table

```sql
SELECT *
FROM category_product_information
ORDER BY product_category;
```

Drop the temporary tables when done

```sql
DROP TEMPORARY TABLE IF EXISTS category_view_add_to_cart_cte, category_products_abandoned_cte, category_products_purchased_cte;
```

Output:

### 1. Which product had the most views, cart adds and purchases?

```sql
SELECT *
FROM product_information
ORDER BY view_counts DESC
LIMIT 1;
```

Output:

```sql
SELECT *
FROM product_information
ORDER BY add_to_cart_counts DESC
LIMIT 1;
```

Output:

```sql
SELECT *
FROM product_information
ORDER BY purchased DESC
LIMIT 1;
```

Output:

### 2. Which product was most likely to be abandoned?

```sql
SELECT * FROM product_information
ORDER BY abandoned DESC
LIMIT 1;
```

Output:

### 3. Which product had the highest view to purchase percentage?

```sql
SELECT product_name,
    ROUND(100.0 * (purchased/view_counts),2) AS purchase_to_view_pct
FROM product_information
ORDER BY purchase_to_view_pct DESC
LIMIT 1;
```

Output:

### 4. What is the average conversion rate from view to cart add?

```sql
SELECT ROUND(AVG(100.0 * (add_to_cart_counts/view_counts)),2) AS avg_conversion_rate
FROM product_information;
```

Output:

### 5. What is the average conversion rate from cart add to purchase?

```sql
SELECT ROUND(AVG(100.0 * (purchased/add_to_cart_counts)),2) AS avg_conversion_rate
FROM product_information;
```

Output:
