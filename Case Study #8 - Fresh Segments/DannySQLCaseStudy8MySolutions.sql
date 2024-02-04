/* If anyone got the following error -> 
	Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a 
    KEY column. To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
    
    Then in order to solve it, we can do the following trick and this has worked out for me:
		**Disable Safe Update Mode**:
			1) In MySQL Workbench, go to "Edit" -> "Preferences" -> "SQL Editor".
			2) Uncheck the "Safe Updates" option.
			3) Reconnect to your MySQL server.
		After disabling safe update mode, you should be able to run your update query without encountering 
        the error. */
        
USE fresh_segments;

/* 1. Data Exploration and Cleansing */

-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date 
	  -- data type with the start of the month.
	-- Step 1: Converting month_year column from Varchar(7) -> Varchar(10)
    ALTER TABLE interest_metrics MODIFY COLUMN month_year VARCHAR(10);
    -- Step 2: Adding '01-' in front of the month_year column to make it a proper date in every row.
    UPDATE interest_metrics SET month_year = STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y');
	-- Step 3: Converting the month_year column into a Date column.
    ALTER TABLE interest_metrics MODIFY COLUMN month_year DATE;
    -- In order to check the data type of month_year column use the following code: DESC interest_metrics;
    -- Step 4: Checking the observations
    SELECT * FROM interest_metrics;
	
-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in 
	  -- chronological order (earliest to latest) with the null values appearing first?
	SELECT 
		month_year, 
		COUNT(interest_id) AS num_of_records
	FROM interest_metrics 
	GROUP BY month_year 
	ORDER BY month_year ASC;
      
-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics.
	-- Step 1: Checking the null values in every column using the following code.
    SELECT * FROM interest_metrics WHERE month_year IS NULL ORDER BY interest_id DESC;
	-- Step2: Since the values of composition, index_value, ranking and percentile_ranking columns
		-- do not make any sense without knowing the _month, _year, month_year & interest_id variables
        -- i.e., we cannot perform any analysis on these NULL values of these variables/columns/features.
        -- Hence, a wise choice would be to delete them from the interest_metrics table.
	DELETE FROM interest_metrics WHERE (interest_id IS NULL);
    -- Do not touch this code: DELETE FROM interest_metrics WHERE interest_id = '21246';
    -- Step 3: Re-Running the code in Step 1 to check.
    SELECT * FROM interest_metrics WHERE month_year IS NULL ORDER BY interest_id DESC;
    
-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the 
	  -- fresh_segments.interest_map table? What about the other way around?
	SELECT 
    MAX(metrics_interest_id_count) AS metrics_interest_id_count,
    MAX(map_id_count) AS map_id_count,
    MAX(interest_id_in_metrics_count) AS interest_id_in_metrics_count,
    MAX(id_in_map_count) AS id_in_map_count
	FROM (
		SELECT COUNT(DISTINCT IM1.interest_id) AS metrics_interest_id_count,
			COUNT(DISTINCT IM2.id) AS map_id_count,
			SUM(CASE WHEN IM1.interest_id IS NULL THEN 1 ELSE 0 END) AS interest_id_in_metrics_count,
			SUM(CASE WHEN IM2.id IS NULL THEN 1 ELSE 0 END) AS id_in_map_count
		FROM interest_metrics AS IM1 LEFT JOIN interest_map AS IM2 ON IM1.interest_id = IM2.id
		UNION
		SELECT COUNT(DISTINCT IM1.interest_id) AS metrics_interest_id_count,
			COUNT(DISTINCT IM2.id) AS map_id_count,
			SUM(CASE WHEN IM1.interest_id IS NULL THEN 1 ELSE 0 END) AS interest_id_in_metrics_count,
			SUM(CASE WHEN IM2.id IS NULL THEN 1 ELSE 0 END) AS id_in_map_count
		FROM interest_metrics AS IM1 RIGHT JOIN interest_map AS IM2 ON IM1.interest_id = IM2.id)
			AS combined_results;
     
-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
	SELECT 
		COUNT(id) AS record_count 
	FROM interest_map;

-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the 
	  -- rows where interest_id = 21246 in your joined output and include all columns from 
      -- fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
	
    -- Answer: Inner Join or, Join will be used. 
    SELECT 
		IM1.*, 
		IM2.interest_name, 
		IM2.interest_summary,
		IM2.created_at, 
		IM2.last_modified 
	FROM interest_metrics AS IM1 
	JOIN interest_map AS IM2
	ON IM1.interest_id = IM2.id
	WHERE IM1.interest_id = '21246';
    
-- 7. Are there any records in your joined table where the month_year value is before the created_at value from 
	  -- the fresh_segments.interest_map table? Do you think these values are valid and why?
	
    
/* 2. Interest Analysis */

-- 1. Which interests have been present in all month_year dates in our dataset?
	-- Counting distinct interest_id's present in the interest_metrics table 
    SELECT 
		COUNT(DISTINCT interest_id) AS distinct_interest_metrics 
	FROM interest_metrics;
    -- Answer: 1202 distinct interest_id's are present in our dataset.
    
    -- Counting distinct interest_id's present in all month_year dates in our dataset
    SELECT 
		COUNT(interest_id)
	FROM (
		SELECT 
			interest_id, 
			COUNT(month_year) AS month_year_cnt
		FROM interest_metrics
		GROUP BY interest_id
		HAVING COUNT(month_year) = (
			SELECT 
				COUNT(DISTINCT month_year) AS distinct_month_year_combination
			FROM interest_metrics
			)
		) AS T;
    -- Answer: 480 distinct interest_id's are present in all the month_year dates in our dataset.
    
    -- Selecting/Displaying the interest_id's present in all month_year dates in our dataset
    SELECT 
		interest_id, 
		COUNT(month_year) AS month_year_cnt
	FROM interest_metrics
	GROUP BY interest_id
	HAVING COUNT(month_year) = (
		SELECT 
			COUNT(DISTINCT month_year) AS distinct_month_year_combination
		FROM interest_metrics
	);

-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 
	-- 14 months - which total_months value passes the 90% cumulative percentage value?
	WITH interest_id_month_year_cte AS (
		SELECT 
			interest_id, 
            COUNT(DISTINCT month_year) AS total_months
		FROM interest_metrics
		WHERE interest_id IS NOT NULL
		GROUP BY interest_id
    ),
    interest_id_counts_cte AS (
		SELECT 
			total_months, 
            COUNT(interest_id) AS interest_cnt
		FROM interest_id_month_year_cte
		GROUP BY total_months    
    )
    SELECT 
		total_months, 
        interest_cnt,
		ROUND(100.0 * ((SUM(interest_cnt) OVER (ORDER BY total_months DESC) /SUM(interest_cnt) OVER ()))
		,2) AS cumulative_percentage
    FROM interest_id_counts_cte;
   -- Answer: Interest with total_months = 6 reached the cumulative percentage of 90%.

-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in 
	-- the previous question - how many total data points would we be removing?
	WITH interest_id_month_year_cte AS (
		SELECT 
			interest_id, 
			COUNT(DISTINCT month_year) AS total_months
		FROM interest_metrics
		WHERE interest_id IS NOT NULL
		GROUP BY interest_id
    )
    SELECT 
		COUNT(interest_id) AS total_interest_id_counts,
		COUNT(DISTINCT interest_id) AS unique_interest_id_counts
	FROM interest_metrics
    WHERE interest_id IN (
		SELECT 
			interest_id 
		FROM interest_id_month_year_cte 
        WHERE total_months < 6);
    
-- 4. Does this decision make sense to remove these data points from a business perspective? 
	-- Use an example where there are all 14 months present to a removed interest example for your arguments - 
    -- think about what it means to have less months present from a segment perspective.
    
    
-- 5. After removing these interests - how many unique interests are there for each month?
	-- Dropping the temporary table modified_interest_metrics if it already exists.
    DROP TABLE IF EXISTS modified_interest_metrics;
    -- Creating a temporary table named as modified_interest_metrics after removing these data points
    CREATE TEMPORARY TABLE modified_interest_metrics AS
		SELECT * FROM 
			interest_metrics
		WHERE interest_id NOT IN (
			SELECT 
				interest_id 
			FROM interest_metrics
			WHERE interest_id IS NOT NULL
			GROUP BY interest_id
			HAVING COUNT(DISTINCT month_year) < 6
    );
    -- Selecting/Displaying the total_interest_ids and unique_interest_ids left  after removing those datapoints.
    SELECT COUNT(interest_id) AS total_interest_id_counts,
		COUNT(DISTINCT interest_id) AS unique_interest_id_counts
    FROM modified_interest_metrics;
    -- Answer: A total of 12680 interest_id data points left and 1092 unique interest_id's are left.    

/* Segment Analysis */

-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the 
	-- top 10 and bottom 10 interests which have the largest composition values in any month_year? 
	-- Only use the maximum composition value for each interest but you must keep the corresponding month_year.
    
    -- Top 10 interests which have the largest values in any month_year
	WITH max_composition_cte AS (
		SELECT 
			month_year, 
			interest_name, 
			MAX(composition) OVER (PARTITION BY interest_id) AS max_composition
		FROM modified_interest_metrics JOIN interest_map 
		ON modified_interest_metrics.interest_id = interest_map.id 
		WHERE interest_name IS NOT NULL
        ), composition_rank_cte AS (
		SELECT 
			*, 
            DENSE_RANK() OVER (ORDER BY max_composition DESC) AS max_composition_ranking
		FROM max_composition_cte
		)
		(
        SELECT 
			DISTINCT interest_name, 
			max_composition, 
            max_composition_ranking FROM 
		composition_rank_cte 
        WHERE max_composition_ranking <= 10);
    
    -- Bottom 10 interests which have the largest values in any month_year
    WITH max_composition_cte AS (
		SELECT 
			month_year, 
			interest_name, 
			MAX(composition) OVER (PARTITION BY interest_id) AS max_composition
		FROM modified_interest_metrics 
        JOIN interest_map 
        ON modified_interest_metrics.interest_id = interest_map.id 
		WHERE interest_name IS NOT NULL
        ), composition_rank_cte AS (
		SELECT 
			*, 
            DENSE_RANK() OVER (ORDER BY max_composition DESC) AS max_composition_ranking
		FROM max_composition_cte
    )
    (SELECT 
		DISTINCT interest_name, 
        max_composition, 
        max_composition_ranking 
        FROM composition_rank_cte
		ORDER BY max_composition_ranking DESC LIMIT 10);
    
-- 2. Which 5 interests had the lowest average ranking value?
	SELECT 
		DISTINCT IM.interest_name, 
        ROUND(1.0 * AVG(MIM.ranking), 2) AS avg_ranking
    FROM modified_interest_metrics AS MIM 
    JOIN interest_map AS IM
	ON MIM.interest_id = IM.id
    GROUP BY IM.interest_name
    ORDER BY avg_ranking ASC
    LIMIT 5;
	
-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
	SELECT 
		DISTINCT MIM.interest_id, 
        IM.interest_name, 
        IM.interest_summary,
		ROUND(STDDEV(MIM.percentile_ranking) OVER (PARTITION BY MIM.interest_id),2) AS largest_std_percentile_ranking
    FROM modified_interest_metrics AS MIM JOIN interest_map AS IM
    ON MIM.interest_id = IM.id
    ORDER BY largest_std_percentile_ranking DESC
    LIMIT 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values 
	-- for each interest and its corresponding year_month value? Can you describe what is happening for these 
    -- 5 interests?
	
    -- Drop the temporary table after use
	DROP TEMPORARY TABLE IF EXISTS interest_metrics_map_temp;
	-- Create a temporary table to store intermediate results
	CREATE TEMPORARY TABLE interest_metrics_map_temp AS
		SELECT 
			MIM.interest_id, 
            MI.interest_name, 
            MI.interest_summary, 
            MIM.percentile_ranking
		FROM modified_interest_metrics MIM
		JOIN interest_map MI 
        ON MIM.interest_id = MI.id;

	-- Use the temporary table in the CTE
	WITH largest_std_interests_cte AS (
		SELECT 
			DISTINCT interest_id, 
            interest_name, 
            interest_summary, 
			ROUND(STDDEV(percentile_ranking) OVER (PARTITION BY interest_id), 2) AS std_percentile_ranking
		FROM interest_metrics_map_temp
		ORDER BY std_percentile_ranking DESC 
        LIMIT 5
	), max_min_percentiles AS (
		SELECT 
			LSIC.interest_id, 
			LSIC.interest_name, 
            LSIC.interest_summary, 
            MIM.month_year, 
            MIM.percentile_ranking, 
			MAX(MIM.percentile_ranking) OVER (PARTITION BY LSIC.interest_id) AS max_pct_rnk,
			MIN(MIM.percentile_ranking) OVER (PARTITION BY LSIC.interest_id) AS min_pct_rnk
		FROM largest_std_interests_cte LSIC
		JOIN modified_interest_metrics MIM 
        ON LSIC.interest_id = MIM.interest_id
	)
	-- Select the final result
		SELECT 
			interest_id, 
			interest_name, 
            interest_summary,
			MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN month_year END) AS max_pct_month_year,
			MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN percentile_ranking END) AS max_pct_rnk,
			MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN month_year END) AS min_pct_month_year,
			MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN percentile_ranking END) AS min_pct_rnk
		FROM max_min_percentiles
		GROUP BY interest_id, interest_name, interest_summary;    
    
-- 5. How would you describe our customers in this segment based off their composition and ranking values? 
	-- What sort of products or services should we show to these customers and what should we avoid?
	
    


/* Index Analysis */
/* The index_value is a measure which can be used to reverse calculate the average composition for 
Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column 
rounded to 2 decimal places. */

-- 1. What is the top 10 interests by the average composition for each month?
	-- Creating the temporary table that combines both the tables
    CREATE TEMPORARY TABLE combined_tables AS 
    SELECT MIM.*, IM.*
	FROM modified_interest_metrics AS MIM JOIN interest_map AS IM
    ON MIM.interest_id = IM.id;
    
    WITH average_composition_cte AS (
	SELECT 
		CT._month,
		CT.interest_name,
		ROUND((CT.composition / CT.index_value), 2) AS avg_composition,
		DENSE_RANK() OVER (PARTITION BY CT._month ORDER BY CT.composition / CT.index_value DESC) AS rnk
	FROM combined_tables AS CT
	WHERE CT._month IS NOT NULL
	) 
	SELECT 
		* 
	FROM average_composition_cte 
	WHERE rnk <= 10;

-- 2. For all of these top 10 interests - which interest appears the most often?
	    
    WITH average_composition_cte AS (
    SELECT 
		CT.month_year, 
        CT.interest_name,
		DENSE_RANK() OVER (PARTITION BY CT.month_year ORDER BY CT.composition / CT.index_value DESC) AS rnk
	FROM combined_tables AS CT
    WHERE CT.month_year IS NOT NULL
    ), frequent_interest_id_cte AS (
	SELECT 
		ACC.interest_name, 
        COUNT(ACC.interest_name) AS interest_cnt
    FROM average_composition_cte AS ACC
    WHERE ACC.avg_composition <= 10
    GROUP BY ACC.interest_name
    )
    SELECT 
		DISTINCT interest_name, 
        interest_cnt 
	FROM frequent_interest_id_cte 
    WHERE interest_cnt IN (
		SELECT MAX(interest_cnt) FROM frequent_interest_id_cte);
        
	
-- 3. What is the average of the average composition for the top 10 interests for each month?


-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to 
	-- August 2019 and include the previous top ranking interests in the same output shown below.


-- 5. Provide a possible reason why the max average composition might change from month to month? 
	-- Could it signal something is not quite right with the overall business model for Fresh Segments?

