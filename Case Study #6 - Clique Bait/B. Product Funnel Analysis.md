### PART 1

Creating a Temporary table view_add_to_cart

```sql
CREATE TEMPORARY TABLE view_add_to_cart AS
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

Creating a Temporary table products_abandoned

```sql
CREATE TEMPORARY TABLE products_abandoned AS
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

Creating a Temporary table products_purchased

```sql
CREATE TEMPORARY TABLE products_purchased AS
SELECT
    PH.product_id,
    PH.page_name AS product_name,
    PH.product_category,
    COUNT(*) AS purchased
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

Creating a Temporary table product_information that combines all the above tables created above.

```sql
CREATE TEMPORARY TABLE product_information AS
SELECT
    VATC.*,
    AB.abandoned,
    PP.purchased
FROM
view_add_to_cart AS VATC
JOIN products_abandoned AS AB ON VATC.product_id = AB.product_id
JOIN products_purchased AS PP ON VATC.product_id = PP.product_id;
```

Dropping the created temporary tables, since they are not required anymore.

```sql
DROP TEMPORARY TABLE IF EXISTS view_add_to_cart, products_abandoned, products_purchased;
```

Displaying the Final resulting table product_information records..

```sql
SELECT * FROM product_information
ORDER BY product_id;
```

Output:
| product_id | product_name | product_category | view_counts | add_to_cart_counts | abandoned | purchased |
|------------|-------------------|-------------------|-------------|---------------------|-----------|-----------|
| 1 | Salmon | Fish | 1559 | 938 | 227 | 711 |
| 2 | Kingfish | Fish | 1559 | 920 | 213 | 707 |
| 3 | Tuna | Fish | 1515 | 931 | 234 | 697 |
| 4 | Russian Caviar | Luxury | 1563 | 946 | 249 | 697 |
| 5 | Black Truffle | Luxury | 1469 | 924 | 217 | 707 |
| 6 | Abalone | Shellfish | 1525 | 932 | 233 | 699 |
| 7 | Lobster | Shellfish | 1547 | 968 | 214 | 754 |
| 8 | Crab | Shellfish | 1564 | 949 | 230 | 719 |
| 9 | Oyster | Shellfish | 1568 | 943 | 217 | 726 |

### PART 2

Creating a Temporary table category_view_add_to_cart

```sql
CREATE TEMPORARY TABLE category_view_add_to_cart AS
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

Creating a Temporary table category_products_abandoned

```sql
CREATE TEMPORARY TABLE category_products_abandoned AS
SELECT
    PH.product_category,
    COUNT(*) AS abandoned
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

Creating a Temporary table category_products_purchased

```sql
CREATE TEMPORARY TABLE category_products_purchased AS
SELECT
    PH.product_category,
    COUNT(*) AS purchased
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

Creating a Temporary table category_product_information that combines all the above tables created above.

```sql
CREATE TEMPORARY TABLE category_product_information AS
SELECT
    VATC.*, AB.abandoned, PP.purchased
FROM category_view_add_to_cart AS VATC
JOIN category_products_abandoned AS AB ON VATC.product_category = AB.product_category
JOIN category_products_purchased AS PP ON VATC.product_category = PP.product_category;
```

Drop the temporary tables, since they are not needed anymore

```sql
DROP TEMPORARY TABLE IF EXISTS category_view_add_to_cart, category_products_abandoned, category_products_purchased;
```

Displaying the final resulting category_product_information table records

```sql
SELECT *
FROM category_product_information
ORDER BY product_category;
```

Output:
| product_category | view_counts | add_to_cart_counts | abandoned | purchased |
|------------------|-------------|---------------------|-----------|-----------|
| Luxury | 3032 | 1870 | 466 | 1404 |
| Fish | 4633 | 2789 | 674 | 2115 |
| Shellfish | 6204 | 3792 | 894 | 2898 |

### 1. Which product had the most views, cart adds and purchases?

```sql
SELECT *
FROM product_information
ORDER BY view_counts DESC
LIMIT 1;
```

Output:
| product_id | product_name | product_category | view_counts | add_to_cart_counts | abandoned | purchased |
|------------|---------------|-------------------|-------------|---------------------|-----------|-----------|
| 9 | Oyster | Shellfish | 1568 | 943 | 217 | 726 |

```sql
SELECT *
FROM product_information
ORDER BY add_to_cart_counts DESC
LIMIT 1;
```

Output:
| product_id | product_name | product_category | view_counts | add_to_cart_counts | abandoned | purchased |
|------------|---------------|-------------------|-------------|---------------------|-----------|-----------|
| 7 | Lobster | Shellfish | 1547 | 968 | 214 | 754 |

```sql
SELECT *
FROM product_information
ORDER BY purchased DESC
LIMIT 1;
```

Output:
| product_id | product_name | product_category | view_counts | add_to_cart_counts | abandoned | purchased |
|------------|---------------|-------------------|-------------|---------------------|-----------|-----------|
| 7 | Lobster | Shellfish | 1547 | 968 | 214 | 754 |

#### Analysis of Product Performance Summary

1. **Insights**:

   - Shellfish Dominance: Both the product with the most views and the product with the most cart adds and purchases belong to the Shellfish category, indicating its popularity among customers.
   - Lobster Dominance: The product with the most cart adds and purchases is Lobster, suggesting that it is not only popular but also highly sought-after for purchase among customers.
   - Oyster Engagement: Although Oyster has the most views, it has a relatively lower number of cart adds and purchases compared to Lobster, indicating potential areas for improvement in conversion rate or marketing strategies.

### 2. Which product was most likely to be abandoned?

```sql
SELECT * FROM product_information
ORDER BY abandoned DESC
LIMIT 1;
```

Output:
| product_id | product_name | product_category | view_counts | add_to_cart_counts | abandoned | purchased |
|------------|---------------|-------------------|-------------|---------------------|-----------|-----------|
| 4 | Russian Caviar | Luxury | 1563 | 946 | 249 | 697 |

#### Analysis of Product Most Likely to Be Abandoned

1. **Insights**:

   - Luxury Product: Russian Caviar falls under the Luxury category, which may imply a higher price point or more exclusive nature compared to other products.
   - High Abandonment Rate: The relatively high number of abandonments suggests that customers might have shown interest in the product but ultimately decided not to proceed with the purchase.
   - Potential Improvements: Analyzing the reasons behind abandonment, such as pricing concerns, shipping costs, or checkout process issues, could provide insights into areas for improvement to reduce abandonment rates and increase conversions. Additionally, targeted marketing or promotional strategies could be employed to encourage customers to complete their purchase of Russian Caviar.

### 3. Which product had the highest view to purchase percentage?

```sql
SELECT product_name,
    ROUND(100.0 * (purchased/view_counts),2) AS purchase_to_view_pct
FROM product_information
ORDER BY purchase_to_view_pct DESC
LIMIT 1;
```

Output:
| product_name | purchase_to_view_pct |
|--------------|-------------------------|
| Lobster | 48.74 |

#### Analysis of Product with Highest View-to-Purchase Percentage

1. **Insights**:

   - High Conversion Rate: The high purchase-to-view percentage indicates that a significant portion of customers who viewed the Lobster product ultimately made a purchase.
   - Appealing Product: Lobster seems to be particularly appealing to customers, leading to a relatively high conversion rate compared to other products.
   - Market Demand: The high conversion rate may suggest strong market demand for Lobster, potentially due to factors such as its taste, quality, or perceived value.

### 4. What is the average conversion rate from view to cart add?

```sql
SELECT
    ROUND(AVG(100.0 * (add_to_cart_counts/view_counts)),2) AS avg_conversion_rate
FROM product_information;
```

Output:
| avg_conversion_rate |
|----------------------|
| 60.95 |

#### Analysis of Average Conversion Rate from View to Cart Add

1. **Insights**:

   - Conversion Funnel Efficiency: The high average conversion rate indicates that a significant proportion of customers who view products proceed to add them to their cart.

### 5. What is the average conversion rate from cart add to purchase?

```sql
SELECT
    ROUND(AVG(100.0 * (purchased/add_to_cart_counts)),2) AS avg_conversion_rate
FROM product_information;
```

Output:
| avg_conversion_rate |
|----------------------|
| 75.93 |

#### Analysis of Average Conversion Rate from Cart Add to Purchase

1. **Insights**:

   - Conversion Funnel Efficiency: This high average conversion rate indicates that a significant proportion of customers who add products to their cart ultimately proceed to make a purchase.
