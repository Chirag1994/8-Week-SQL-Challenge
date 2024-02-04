### Generate a table that has 1 single row for every unique visit_id record and has the following columns:

> -- user_id
> -- visit_id
> -- visit_start_time: the earliest event_time for each visit
> -- page_views: count of page views for each visit
> -- cart_adds: count of product cart add events for each visit
> -- purchase: 1/0 flag if a purchase event exists for each visit
> -- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
> -- impression: count of ad impressions for each visit
> -- click: count of ad clicks for each visit
> -- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number).

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single
A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most
important points from your findings.

Some ideas you might want to investigate further include:

> -- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
> -- Does clicking on an impression lead to higher purchase rates?
> -- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
> -- What metrics can you use to quantify the success or failure of each campaign compared to eachother?

```sql
SELECT
	U.user_id, E.visit_id, MIN(E.event_time) AS visit_start_date, C.campaign_name,
    SUM(CASE WHEN EI.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_view_counts,
    SUM(CASE WHEN EI.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS add_to_cart_counts,
    SUM(CASE WHEN EI.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchased_counts,
    SUM(CASE WHEN EI.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_counts,
    SUM(CASE WHEN EI.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click_counts
FROM users AS U
JOIN events AS E ON U.cookie_id = E.cookie_id
JOIN event_identifier AS EI ON E.event_type = EI.event_type
JOIN campaign_identifier AS C ON E.event_time BETWEEN C.start_date AND C.end_date
GROUP BY U.user_id, E.visit_id, C.campaign_name;
```

Output:

First 20 records
| user_id | visit_id | visit_start_date | campaign_name | page_view_counts | add_to_cart_counts | purchased | impression_counts | click_counts |
|---------|----------|------------------------|---------------------------------------|-------------------|--------------------|-----------|-------------------|--------------|
| 1 | ccf365 | 2020-02-04 19:16:09 | Half Off - Treat Your Shellf(ish) | 7 | 3 | 1 | 0 | 0 |
| 2 | d58cbd | 2020-01-18 23:40:55 | 25% Off - Living The Lux Life | 8 | 4 | 0 | 0 | 0 |
| 3 | 9a2f24 | 2020-02-21 03:19:10 | Half Off - Treat Your Shellf(ish) | 6 | 2 | 1 | 0 | 0 |
| 4 | 7caba5 | 2020-02-22 17:49:38 | Half Off - Treat Your Shellf(ish) | 5 | 2 | 0 | 0 | 0 |
| 5 | f61ed7 | 2020-02-01 06:30:40 | Half Off - Treat Your Shellf(ish) | 8 | 2 | 1 | 0 | 0 |
| 6 | e0ce49 | 2020-01-25 22:43:21 | 25% Off - Living The Lux Life | 9 | 3 | 1 | 0 | 0 |
| 7 | 8479c1 | 2020-02-09 17:27:59 | Half Off - Treat Your Shellf(ish) | 5 | 1 | 1 | 0 | 0 |
| 8 | a6c424 | 2020-02-12 11:23:55 | Half Off - Treat Your Shellf(ish) | 7 | 2 | 0 | 0 | 0 |
| 9 | 5ef346 | 2020-02-07 17:32:45 | Half Off - Treat Your Shellf(ish) | 7 | 0 | 0 | 0 | 0 |
| 10 | d39d35 | 2020-01-23 21:47:04 | 25% Off - Living The Lux Life | 7 | 3 | 1 | 0 | 0 |
| 11 | 9c2633 | 2020-01-17 04:59:43 | 25% Off - Living The Lux Life | 8 | 2 | 0 | 0 | 0 |
| 12 | d69e73 | 2020-02-06 09:09:06 | Half Off - Treat Your Shellf(ish) | 5 | 1 | 0 | 0 | 0 |
| 13 | c70085 | 2020-02-12 08:26:14 | Half Off - Treat Your Shellf(ish) | 6 | 1 | 0 | 0 | 0 |
| 14 | 6a20a3 | 2020-01-12 02:49:32 | BOGOF - Fishing For Compliments | 8 | 1 | 0 | 0 | 0 |
| 16 | 69440b | 2020-01-06 21:45:51 | BOGOF - Fishing For Compliments | 4 | 1 | 1 | 0 | 0 |
| 17 | e70fd5 | 2020-02-17 10:05:51 | Half Off - Treat Your Shellf(ish) | 7 | 2 | 0 | 0 | 0 |
| 18 | 48810d | 2020-02-29 15:26:41 | Half Off - Treat Your Shellf(ish) | 4 | 0 | 0 | 0 | 0 |
| 19 | fdf383 | 2020-02-11 13:52:24 | Half Off - Treat Your Shellf(ish) | 7 | 1 | 1 | 0 | 0 |
| 20 | 378a75 | 2020-02-12 23:33:51 | Half Off - Treat Your Shellf(ish) | 4 | 0 | 0 | 0 | 0 |
