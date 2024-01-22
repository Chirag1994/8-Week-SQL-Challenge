USE data_bank;
/* --------------------------- A. Customer Nodes Exploration --------------------------- */
-- 1. How many unique nodes are there on the Data Bank system?
	SELECT COUNT(DISTINCT node_id) AS unique_nodes
	FROM customer_nodes;

-- 2. What is the number of nodes per region?
	SELECT R.region_name, COUNT(CN.node_id) AS total_nodes_count,
	COUNT(DISTINCT CN.node_id) AS unique_nodes_count
	FROM customer_nodes AS CN JOIN regions AS R
	ON CN.region_id = R.region_id
	GROUP BY R.region_name
	ORDER BY R.region_name;
    
-- 3. How many customers are allocated to each region?
	SELECT R.region_name, COUNT(CN.customer_id) AS total_customer_count,
	COUNT(DISTINCT CN.customer_id) AS unique_customer_count
	FROM customer_nodes AS CN JOIN regions AS R
	ON CN.region_id = R.region_id
	GROUP BY R.region_name
	ORDER BY R.region_name;
-- 4. How many days on average are customers reallocated to a different node?

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
  
  /* --------------------------- B. Customer Transactions --------------------------- */
  -- 1. What is the unique count and total amount for each transaction type?
		SELECT CT.txn_type,
			COUNT(CT.customer_id) AS total_count,
			COUNT(DISTINCT CT.customer_id) AS unique_count,
			SUM(CT.txn_amount) AS total_amount
     	FROM customer_transactions AS CT
	    GROUP BY CT.txn_type;
        
  -- 2. What is the average total historical deposit counts and amounts for all customers?
		WITH customer_deposit AS (
		SELECT customer_id,
			COUNT(customer_id) AS total_deposits_count,
			SUM(txn_amount) AS total_txn_amount
		FROM customer_transactions
		WHERE txn_type = 'deposit'
		GROUP BY customer_id
		)
		SELECT 
			ROUND(AVG(total_deposits_count)) AS avg_total_deposits_count,
			ROUND(AVG(total_txn_amount)) AS avg_total_txn_amount
		FROM customer_deposit;

  -- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase 
		-- or 1 withdrawal in a single month?
		WITH monthly_data AS (
		SELECT CT.customer_id,
			MONTH(CT.txn_date) AS month_,
			SUM(CASE WHEN CT.txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposits_count,
			SUM(CASE WHEN CT.txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawl_count,
			SUM(CASE WHEN CT.txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
		FROM customer_transactions AS CT
		GROUP BY CT.customer_id, MONTH(CT.txn_date)
		)
		SELECT MD.month_, COUNT(MD.customer_id) AS customer_count
		FROM monthly_data AS MD
		WHERE MD.deposits_count > 1 AND (MD.withdrawl_count = 1 OR MD.purchase_count = 1)
		GROUP BY MD.month_
		ORDER BY MD.month_;
  
  -- 4. What is the closing balance for each customer at the end of the month?
		
        
  -- 5. What is the percentage of customers who increase their closing balance by more than 5%?
		
        
  /* --------------------------- C. Data Allocation Challenge --------------------------- */
  /* To test out a few different hypotheses - the Data Bank team wants to run an experiment where different 
	 groups of customers would be allocated data using 3 different options:
	 -- Option 1: data is allocated based off the amount of money at the end of the previous month
     -- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
     -- Option 3: data is updated real-time
     For this multi-part challenge question - you have been requested to generate the following data elements to 
     help the Data Bank team estimate how much data will need to be provisioned for each option:
	 -- running customer balance column that includes the impact each transaction
     -- customer balance at the end of each month
	 -- minimum, average and maximum values of the running balance for each customer
	 Using all of the data available - how much data would have been required for each option on a monthly basis? */
     
     

/* --------------------------- D. Extra Challenge --------------------------- */  
/* Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data 
   growth using an interest calculation, just like in a traditional savings account you might have with a bank.
  
   If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their 
   data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be 
   required for this option on a monthly basis?
Special notes:
   Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be 
   interested in a daily compounding interest calculation so you can try to perform this calculation if you have the 
   stamina! */