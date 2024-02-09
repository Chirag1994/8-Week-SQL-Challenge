### 1. What was the total quantity sold for all products?

Total quantity sold from all the products is given by the following query:

```sql
SELECT
    SUM(qty) AS total_quantity_sold
FROM sales;
```

Output:
| total_quantity_sold |
|----------------------|
| 45216 |

Total quantity sold for all the products is given by the following query:

```sql
SELECT
	PD.product_name, SUM(S.qty) AS total_quantity_sold
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_quantity_sold DESC;
```

Output:
| product_name | total_quantity_sold |
|-------------------------------------|----------------------|
| Grey Fashion Jacket - Womens | 3876 |
| Navy Oversized Jeans - Womens | 3856 |
| Blue Polo Shirt - Mens | 3819 |
| White Tee Shirt - Mens | 3800 |
| Navy Solid Socks - Mens | 3792 |
| Black Straight Jeans - Womens | 3786 |
| Pink Fluro Polkadot Socks - Mens | 3770 |
| Indigo Rain Jacket - Womens | 3757 |
| Khaki Suit Jacket - Womens | 3752 |
| Cream Relaxed Jeans - Womens | 3707 |
| White Striped Socks - Mens | 3655 |
| Teal Button Up Shirt - Mens | 3646 |

#### Analysis of Total Quantity Sold for All Products

1. **Insights**:

   - The total quantity sold for all products is 45216 with the Grey Fashion Jacket and Navy Oversized Jeans being the top-selling items.

### 2. What is the total generated revenue for all products before discounts?

Total revenue before discounts

```sql
SELECT
    SUM(qty * price) AS total_revenue
FROM sales;
```

Output:
| total_revenue |
|----------------------|
| 1289453 |

Total revenue before discounts for all the products

```sql
SELECT
    PD.product_name, SUM(S.qty * S.price) AS total_revenue
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_revenue DESC;
```

Output:
| product_name | total_revenue |
|-------------------------------------|---------------|
| Blue Polo Shirt - Mens | 217683 |
| Grey Fashion Jacket - Womens | 209304 |
| White Tee Shirt - Mens | 152000 |
| Navy Solid Socks - Mens | 136512 |
| Black Straight Jeans - Womens | 121152 |
| Pink Fluro Polkadot Socks - Mens | 109330 |
| Khaki Suit Jacket - Womens | 86296 |
| Indigo Rain Jacket - Womens | 71383 |
| White Striped Socks - Mens | 62135 |
| Navy Oversized Jeans - Womens | 50128 |
| Cream Relaxed Jeans - Womens | 37070 |
| Teal Button Up Shirt - Mens | 36460 |

#### Analysis of Total Revenue Before Discounts

1. **Insights**:

   - The total revenue generated for all products before discounts is $1,289,453.

### 3. What was the total discount amount for all products?

Total discount given is given by

```sql
SELECT
    ROUND(SUM((qty*price*discount)/100),2) AS total_discount
FROM sales;
```

Output:
| total_discount |
|----------------------|
| 156229.14 |

Total discount for all the products is given by

```sql
SELECT
    PD.product_name, ROUND(SUM((S.qty*S.price*S.discount)/100),2) AS total_discount
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_discount DESC;
```

Output:
| product_name | total_discount |
|-------------------------------------|-----------------|
| Blue Polo Shirt - Mens | 26819.07 |
| Grey Fashion Jacket - Womens | 25391.88 |
| White Tee Shirt - Mens | 18377.60 |
| Navy Solid Socks - Mens | 16650.36 |
| Black Straight Jeans - Womens | 14744.96 |
| Pink Fluro Polkadot Socks - Mens | 12952.27 |
| Khaki Suit Jacket - Womens | 10243.05 |
| Indigo Rain Jacket - Womens | 8642.53 |
| White Striped Socks - Mens | 7410.81 |
| Navy Oversized Jeans - Womens | 6135.61 |
| Cream Relaxed Jeans - Womens | 4463.40 |
| Teal Button Up Shirt - Mens | 4397.60 |

#### Analysis of Total Discount Amount

1. **Insights**:

   - The total discount amount given across all products is $156,229.14.
