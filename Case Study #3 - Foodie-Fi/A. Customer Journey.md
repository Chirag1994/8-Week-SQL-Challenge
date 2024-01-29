### A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

```sql
SELECT
	S.customer_id, P.plan_name, P.price, S.start_date
FROM Subscriptions AS S
JOIN Plans AS P ON P.plan_id = S.plan_id
WHERE customer_id IN (1,2,3,4,5,6,7,8);
```

Output:
| customer_id | plan_name | price | start_date |
|-------------|-----------------|-------|-------------|
| 1 | trial | 0.00 | 2020-08-01 |
| 1 | basic monthly | 9.90 | 2020-08-08 |
| 2 | trial | 0.00 | 2020-09-20 |
| 2 | pro annual | 199.00| 2020-09-27 |
| 3 | trial | 0.00 | 2020-01-13 |
| 3 | basic monthly | 9.90 | 2020-01-20 |
| 4 | trial | 0.00 | 2020-01-17 |
| 4 | basic monthly | 9.90 | 2020-01-24 |
| 4 | churn | | 2020-04-21 |
| 5 | trial | 0.00 | 2020-08-03 |
| 5 | basic monthly | 9.90 | 2020-08-10 |
| 6 | trial | 0.00 | 2020-12-23 |
| 6 | basic monthly | 9.90 | 2020-12-30 |
| 6 | churn | | 2021-02-26 |
| 7 | trial | 0.00 | 2020-02-05 |
| 7 | basic monthly | 9.90 | 2020-02-12 |
| 7 | pro monthly | 19.90 | 2020-05-22 |
| 8 | trial | 0.00 | 2020-06-11 |
| 8 | basic monthly | 9.90 | 2020-06-18 |
| 8 | pro monthly | 19.90 | 2020-08-03 |

Customer 1 signed up on '2020-08-01' for free-trial and on '2020-08-08' customer took the basic monthly plan as the system automatically upgrades to pro monthly plan.

Customer 2 signed up on '2020-09-20' for free trial and on '2020-09-27' customer upgraded to pro annual subscription.

Customer 3 signed up on '2020-01-13' for free trial and on '2020-01-20' customer took the basic monthly plan instead of going for the pro monthly plan as what system automatically upgrades to.

Customer 4 signed up on '2020-01-17' for free trial, on '2020-01-24' customer took the basic monthly plan and then churned out on '2020-0421' (after 3 months of free-trial).

Customer 5 signed up on '2020-08-03' for free-trial and on '2020-08-10' customer took the basic monthly plan instead of going for the pro monthly plan as what system automatically upgrades to.

Customer 6 signed up on '2020-12-23' for free trial, on '2020-12-30' customer took the basic monthly plan and then churned out on '2021-02-26' (after 2 months of free-trial).

Customer 7 signed up on '2020-02-05' for free-trial, on '2020-02-12' customer took the basic monthly plan and then using the basic monthly plan for 3 months upgraded his plan to pro monthly on '2020-05-22'.

Same goes to customer 8, customer signed up on '2020-06-11' for free-trial, on '2020-06-18' customer took the basic monthly plan and then using the basic monthly plan for 2 months upgraded his plan to pro monthly on '2020-08-03'.
