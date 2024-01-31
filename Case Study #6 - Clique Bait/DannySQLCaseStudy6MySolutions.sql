USE clique_bait;
  
/* 1. Enterprise Relationship Diagram */

/* 2. Digital Analysis */
-- Using the available datasets - answer the following questions using a single query for each one:

-- 1. How many users are there?
SELECT 
	COUNT(DISTINCT user_id) AS number_of_unique_users
FROM users;

-- 2. How many cookies does each user have on average?
WITH cookie AS (
SELECT user_id,
        COUNT(cookie_id) AS cookie_count
FROM users GROUP BY user_id
)
SELECT ROUND(AVG(cookie_count),0) AS average_cookie_per_user
FROM cookie;

-- 3. What is the unique number of visits by all users per month?
SELECT
	MONTH(event_time) AS 'month',
	COUNT(DISTINCT visit_id) AS customer_count
FROM events
GROUP BY MONTH(event_time);

-- 4. What is the number of events for each event type?
SELECT EI.event_name,
	COUNT(E.event_time) AS number_of_events
FROM events AS E
JOIN event_identifier AS EI
ON E.event_type = EI.event_type
GROUP BY EI.event_name
ORDER BY number_of_events DESC;

-- 5. What is the percentage of visits which have a purchase event?
SELECT
	ROUND(100.0 * COUNT(DISTINCT E.visit_id) / (SELECT COUNT(DISTINCT visit_id) FROM events),2)
    AS vists_percentage
FROM events AS E
JOIN event_identifier AS EI ON E.event_type = EI.event_type
WHERE EI.event_name = 'Purchase';

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?


-- 7. What are the top 3 pages by number of views?
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

-- 8. What is the number of views and cart adds for each product category?
SELECT PH.product_category, 
	   SUM(CASE WHEN E.event_type = '1' THEN 1 ELSE 0 END) AS number_of_views,
	   SUM(CASE WHEN E.event_type = '2' THEN 1 ELSE 0 END) AS number_of_cart_adds
FROM events as E JOIN page_hierarchy AS PH
ON E.page_id = PH.page_id
WHERE PH.product_category IS NOT NULL
GROUP BY PH.product_category
ORDER BY PH.product_category;

-- 9. What are the top 3 products by purchases?


/* 3. Product Funnel Analysis */
-- Using a single SQL query - create a new output table which has the following details:
	-- How many times was each product viewed?
	-- How many times was each product added to cart?
	-- How many times was each product added to a cart but not purchased (abandoned)?
	-- How many times was each product purchased?
-- Additionally, create another table which further aggregates the data for the above points but this time 
-- for each product category instead of individual products.
    
/* PART 1 */ 
-- Creating a Temporary table view_add_to_cart
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

-- Creating a Temporary table products_abandoned
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

-- Creating a Temporary table products_purchased
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

-- Creating a Temporary table product_information that combines all the above tables created above.
CREATE TEMPORARY TABLE product_information AS
SELECT
    VATC.*,
    AB.abandoned,
    PP.purchased
FROM
view_add_to_cart AS VATC
JOIN products_abandoned AS AB ON VATC.product_id = AB.product_id
JOIN products_purchased AS PP ON VATC.product_id = PP.product_id;

-- Dropping the created temporary tables, since they are not required anymore.
DROP TEMPORARY TABLE IF EXISTS view_add_to_cart,products_abandoned, products_purchased;

-- Displaying the Final resulting table product_information records..
SELECT * FROM product_information
ORDER BY product_id;

/* PART 2 */ 

-- Creating a Temporary table category_view_add_to_cart
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

-- Creating a Temporary table category_products_abandoned
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

-- Creating a Temporary table category_products_purchased
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

-- Creating a Temporary table category_product_information that combines all the above tables created above.
CREATE TEMPORARY TABLE category_product_information AS
SELECT
    VATC.*, AB.abandoned, PP.purchased
FROM category_view_add_to_cart AS VATC
JOIN category_products_abandoned AS AB ON VATC.product_category = AB.product_category
JOIN category_products_purchased AS PP ON VATC.product_category = PP.product_category;

-- Drop the temporary tables, since they are not needed anymore
DROP TEMPORARY TABLE IF EXISTS category_view_add_to_cart, category_products_abandoned, category_products_purchased;

-- Displaying the final resulting category_product_information table records
SELECT *
FROM category_product_information
ORDER BY product_category;

-- Use your 2 new output tables - answer the following questions:
	-- 1. Which product had the most views, cart adds and purchases?
	SELECT * FROM product_information
    ORDER BY view_counts DESC
    LIMIT 1;
    
    SELECT * FROM product_information
    ORDER BY add_to_cart_counts DESC
    LIMIT 1;
    
    SELECT * FROM product_information
    ORDER BY purchased DESC
    LIMIT 1;
    -- Answer: 
    
    -- 2. Which product was most likely to be abandoned?
	SELECT * FROM product_information
    ORDER BY abandoned DESC
    LIMIT 1;
    
    -- 3. Which product had the highest view to purchase percentage?
	SELECT product_name,
		ROUND(100.0 * (purchased/view_counts),2) AS purchase_to_view_pct
	FROM product_information
    ORDER BY purchase_to_view_pct DESC
    LIMIT 1;
    
    -- 4. What is the average conversion rate from view to cart add?
	SELECT 
		ROUND(AVG(100.0 * (add_to_cart_counts/view_counts)),2) AS avg_conversion_rate
	FROM product_information;
    
    -- 5. What is the average conversion rate from cart add to purchase?
	SELECT 
		ROUND(AVG(100.0 * (purchased/add_to_cart_counts)),2) AS avg_conversion_rate
	FROM product_information;
    
/* 4. Campaigns Analysis */
/* Generate a table that has 1 single row for every unique visit_id record and has the following columns:
	-- user_id
	-- visit_id
	-- visit_start_time: the earliest event_time for each visit
	-- page_views: count of page views for each visit
	-- cart_adds: count of product cart add events for each visit
	-- purchase: 1/0 flag if a purchase event exists for each visit
	-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
	-- impression: count of ad impressions for each visit
	-- click: count of ad clicks for each visit
	-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the 
    order they were added to the cart (hint: use the sequence_number)

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single 
A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most 
important points from your findings.

Some ideas you might want to investigate further include:
	-- Identifying users who have received impressions during each campaign period and comparing each metric 
       with other users who did not have an impression event
	-- Does clicking on an impression lead to higher purchase rates?
	-- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users 
       who do not receive an impression? What if we compare them with users who just an impression but do not click?
	-- What metrics can you use to quantify the success or failure of each campaign compared to eachother? */