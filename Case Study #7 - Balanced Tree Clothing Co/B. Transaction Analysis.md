### 1. How many unique transactions were there?

```sql
SELECT
	COUNT(DISTINCT txn_id) AS unique_number_of_transactions
FROM sales;
```

Output:
| unique_number_of_transactions |
|------------------------------|
| 2500 |

#### Analysis of Unique Transactions

1. **Insights**:

   - The total number of unique transactions recorded is 2,500. Each transaction represents a distinct instance of a purchase made by a customer, providing valuable insights into the volume of sales and customer engagement with Balanced Tree Clothing Company.

### 2. What is the average unique products purchased in each transaction?

```sql
SELECT
	ROUND(AVG(unique_products_purchased),0) AS avg_unique_products_purchased
FROM (
	SELECT txn_id,
		COUNT(DISTINCT prod_id) AS unique_products_purchased
	FROM sales
	GROUP BY txn_id
) AS unique_products_count;
```

Output:
| avg_unique_products_purchased |
|-------------------------------|
| 6 |

#### Analysis of Average Unique Products Purchased

1. **Insights**:

   - The average number of unique products purchased in each transaction is 6. This metric indicates the diversity of products that customers typically buy in a single transaction, reflecting their preferences and shopping behavior.

### 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

```sql
WITH revenue_per_transaction AS (
	SELECT
		S.txn_id,
		SUM(S.qty * S.price) AS total_revenue
 	FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
 	GROUP BY S.txn_id
 	ORDER BY S.txn_id
)
SELECT
	MAX(CASE WHEN percentile_group = 1 THEN total_revenue END) AS percentile_25,
    MAX(CASE WHEN percentile_group = 2 THEN total_revenue END) AS percentile_50,
    MAX(CASE WHEN percentile_group = 3 THEN total_revenue END) AS percentile_75
FROM (
	SELECT
		txn_id,
		total_revenue,
		NTILE(4) OVER (ORDER BY total_revenue) as percentile_group
    FROM revenue_per_transaction
	) AS percentile_groups;
```

Output:
| percentile_25 | percentile_50 | percentile_75 |
|---------------|---------------|---------------|
| 375 | 509 | 647 |

#### Analysis of Revenue Percentile Values

1. **Insights**:

   - These percentile values represent the revenue per transaction at different points in the distribution. For instance, the 25th percentile indicates that 25% of transactions have a revenue of $375 or lower, while the 75th percentile signifies that 75% of transactions have a revenue of $647 or lower. Understanding these values helps in assessing the distribution of revenue and identifying potential areas for improvement or optimization in sales strategies.

### 4. What is the average discount value per transaction?

```sql
SELECT
	ROUND(AVG(discount_value),1) AS avg_discount_value
FROM (
	SELECT
		txn_id,
		ROUND(SUM((price * qty * discount)/100),0) AS discount_value
	FROM sales
	GROUP BY txn_id
	) AS discount_table;
```

Output:
| avg_discount_value |
|-------------------------------|
| 62.5 |

#### Analysis of Average Discount Value per Transaction

1. **Insights**:

   - The Average Discount Value of $62.5, indicates the average discount applied per transaction across all purchases.

### 5. What is the percentage split of all transactions for members vs non-members?

```sql
SELECT
	ROUND(100.0 * (COUNT(DISTINCT CASE WHEN member = 't' THEN txn_id ELSE 0 END))
		/(SELECT COUNT(DISTINCT txn_id)  FROM sales),2) As member_transaction_pct,
	ROUND(100.0 * (COUNT(DISTINCT CASE WHEN member = 'f' THEN txn_id ELSE 0 END))
		/(SELECT COUNT(DISTINCT txn_id)  FROM sales),2) As non_member_transaction_pct
FROM sales;
```

Output:
| member_transaction_pct | non_member_transaction_pct |
|------------------------|-----------------------------|
| 60.24 | 39.84 |

#### Analysis of Percentage Split of Transactions: Members vs Non-members

1. **Insights**:

   - The data reveals that a significant portion of transactions, approximately 60.24%, is attributed to members, while non-members contribute to about 39.84% of the total transactions. Understanding this split helps in assessing the contribution of membership programs to overall sales and in formulating strategies to attract and retain both member and non-member customers. It highlights the importance of analyzing the behavior and preferences of each segment to tailor marketing and loyalty initiatives effectively.

### 6. What is the average revenue for member transactions and non-member transactions?

```sql
WITH member_transactions_cte AS (
	SELECT
		member,
		txn_id,
		SUM(qty*price) AS avg_revenue
	FROM sales GROUP BY member,txn_id
	)
	SELECT
		member,
		ROUND(AVG(avg_revenue),2) AS avg_member_transactions
	FROM member_transactions_cte
	GROUP BY member;
```

Output:
| member | avg_member_transactions |
|--------|-------------------------|
| t | 516.27 |
| f | 515.04 |

#### Analysis of Average Revenue for Transactions: Members vs Non-members

1. **Insights**:

   - On average, member transactions generate slightly higher revenue compared to non-member transactions. This insight underscores the potential value of membership programs in driving higher spending per transaction. It suggests that members may be more inclined to make larger purchases or buy higher-priced items, indicating their engagement and loyalty to the brand. Understanding these differences in average revenue can inform targeted marketing strategies and personalized offerings to enhance customer satisfaction and retention.
