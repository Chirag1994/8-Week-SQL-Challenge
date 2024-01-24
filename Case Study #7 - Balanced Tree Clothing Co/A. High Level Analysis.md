### 1. What was the total quantity sold for all products?

Total quantity sold from all the products is given by the following query:

```sql
SELECT SUM(qty) AS total_quantity_sold FROM sales;
```

Output:

Total quantity sold for all the products is given by the following query:

```sql
SELECT PD.product_name, SUM(S.qty) AS total_quantity_sold
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_quantity_sold DESC;
```

Output:

### 2. What is the total generated revenue for all products before discounts?

Total revenue before discounts

```sql
SELECT SUM(qty * price) AS total_revenue FROM sales;
```

Output:

Total revenue before discounts for all the products

```sql
SELECT PD.product_name, SUM(S.qty * S.price) AS total_revenue
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_revenue DESC;
```

Output:

### 3. What was the total discount amount for all products?

Total discount given is given by

```sql
SELECT ROUND(SUM((qty*price*discount)/100),2) AS total_discount FROM sales;
```

Output:

Total discount for all the products is given by

```sql
SELECT PD.product_name, ROUND(SUM((S.qty*S.price*S.discount)/100),2) AS total_discount
FROM product_details AS PD JOIN sales AS S ON PD.product_id = S.prod_id
GROUP BY PD.product_name
ORDER BY total_discount DESC;
```

Output:
