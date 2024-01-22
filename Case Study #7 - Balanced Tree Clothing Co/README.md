# Case Study #7 - Balanced Tree Clothing Co.

<img src="./Images/Image1.png" alt="Image1" width="800" height="800" />

## Table of Contents

- [Problem Statement](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)

## Problem Statement

<a id="problem-statement"></a>

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

## Entity Relationship Diagram

<a id="entity-relationship-diagram"></a>

<img src="./Images/Image2.png" alt="Image2" />

For this case study there is a total of 4 datasets for this case study - however you will only need to utilise 2 main tables to solve all of the regular questions, and the additional 2 tables are used only for the bonus challenge question!

### Product Details

`balanced_tree.product_details` includes all information about the entire range that Balanced Clothing sells in their store.

| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name          |
| ---------- | ----- | -------------------------------- | ----------- | ---------- | -------- | ------------- | ------------ | ------------------- |
| c4a632     | 13    | Navy Oversized Jeans - Womens    | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized      |
| e83aa3     | 32    | Black Straight Jeans - Womens    | 1           | 3          | 8        | Womens        | Jeans        | Black Straight      |
| e31d39     | 10    | Cream Relaxed Jeans - Womens     | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed       |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens       | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit          |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens      | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain         |
| 9ec847     | 54    | Grey Fashion Jacket - Womens     | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion        |
| 5d267b     | 40    | White Tee Shirt - Mens           | 2           | 5          | 13       | Mens          | Shirt        | White Tee           |
| c8d436     | 10    | Teal Button Up Shirt - Mens      | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up      |
| 2a2353     | 57    | Blue Polo Shirt - Mens           | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo           |
| f084eb     | 36    | Navy Solid Socks - Mens          | 2           | 6          | 16       | Mens          | Socks        | Navy Solid          |
| b9a74d     | 17    | White Striped Socks - Mens       | 2           | 6          | 17       | Mens          | Socks        | White Striped       |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2           | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |

### Product Sales

`balanced_tree.sales` contains product level information for all the transactions made for Balanced Tree including quantity, price, percentage discount, member status, a transaction ID and also the transaction timestamp.

| prod_id | qty | price | discount | member | txn_id | start_txn_time           |
| ------- | --- | ----- | -------- | ------ | ------ | ------------------------ |
| c4a632  | 4   | 13    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| 5d267b  | 4   | 40    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| b9a74d  | 4   | 17    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| 2feb6b  | 2   | 29    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| c4a632  | 5   | 13    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| e31d39  | 2   | 10    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| 72f5d4  | 3   | 19    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| 2a2353  | 3   | 57    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| f084eb  | 3   | 36    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| c4a632  | 1   | 13    | 21       | f      | ef648d | 2021-01-27 02:18:17.1648 |

### Product Hierarcy & Product Price

Thes tables are used only for the bonus question where we will use them to recreate the `balanced_tree.product_details` table.

`balanced_tree.product_hierarchy`

| id  | parent_id | level_text          | level_name |
| --- | --------- | ------------------- | ---------- |
| 1   |           | Womens              | Category   |
| 2   |           | Mens                | Category   |
| 3   | 1         | Jeans               | Segment    |
| 4   | 1         | Jacket              | Segment    |
| 5   | 2         | Shirt               | Segment    |
| 6   | 2         | Socks               | Segment    |
| 7   | 3         | Navy Oversized      | Style      |
| 8   | 3         | Black Straight      | Style      |
| 9   | 3         | Cream Relaxed       | Style      |
| 10  | 4         | Khaki Suit          | Style      |
| 11  | 4         | Indigo Rain         | Style      |
| 12  | 4         | Grey Fashion        | Style      |
| 13  | 5         | White Tee           | Style      |
| 14  | 5         | Teal Button Up      | Style      |
| 15  | 5         | Blue Polo           | Style      |
| 16  | 6         | Navy Solid          | Style      |
| 17  | 6         | White Striped       | Style      |
| 18  | 6         | Pink Fluro Polkadot | Style      |

`balanced_tree.product_prices`

| id  | product_id | price |
| --- | ---------- | ----- |
| 7   | c4a632     | 13    |
| 8   | e83aa3     | 32    |
| 9   | e31d39     | 10    |
| 10  | d5e9a6     | 23    |
| 11  | 72f5d4     | 19    |
| 12  | 9ec847     | 54    |
| 13  | 5d267b     | 40    |
| 14  | c8d436     | 10    |
| 15  | 2a2353     | 57    |
| 16  | f084eb     | 36    |
| 17  | b9a74d     | 17    |
| 18  | 2feb6b     | 29    |

## Case Study Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

### A. High Level Sales Analysis

1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?

### B. Transaction Analysis

1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?

### C. Product Analysis

1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

### D. Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

### E. Bonus Challenge

Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!
