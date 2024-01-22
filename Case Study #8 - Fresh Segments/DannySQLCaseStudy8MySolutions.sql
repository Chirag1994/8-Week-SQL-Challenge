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
	SELECT month_year, COUNT(interest_id) AS num_of_records
    FROM interest_metrics GROUP BY month_year ORDER BY month_year ASC;
      
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
	SELECT COUNT(id) AS record_count FROM interest_map;

-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the 
	  -- rows where interest_id = 21246 in your joined output and include all columns from 
      -- fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
	
    -- Answer: Inner Join or, Join will be used. 
    SELECT IM1.*, IM2.interest_name, IM2.interest_summary,
		IM2.created_at, IM2.last_modified 
	FROM interest_metrics AS IM1 JOIN interest_map AS IM2
    ON IM1.interest_id = IM2.id
    WHERE IM1.interest_id = '21246';
    
-- 7. Are there any records in your joined table where the month_year value is before the created_at value from 
	  -- the fresh_segments.interest_map table? Do you think these values are valid and why?
	
    
/* 2. Interest Analysis */

-- 1. Which interests have been present in all month_year dates in our dataset?

-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 
	-- 14 months - which total_months value passes the 90% cumulative percentage value?
	

-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in 
	-- the previous question - how many total data points would we be removing?
-- 4. Does this decision make sense to remove these data points from a business perspective? 
	-- Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
-- 5. After removing these interests - how many unique interests are there for each month?

/* Segment Analysis */

-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the 
	-- top 10 and bottom 10 interests which have the largest composition values in any month_year? 
	-- Only use the maximum composition value for each interest but you must keep the corresponding month_year
-- 2. Which 5 interests had the lowest average ranking value?
-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values 
	-- for each interest and its corresponding year_month value? Can you describe what is happening for these 
    -- 5 interests?
-- 5. How would you describe our customers in this segment based off their composition and ranking values? 
	-- What sort of products or services should we show to these customers and what should we avoid?

/* Index Analysis */
/* The index_value is a measure which can be used to reverse calculate the average composition for 
Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column 
rounded to 2 decimal places. */

-- 1. What is the top 10 interests by the average composition for each month?
-- 2. For all of these top 10 interests - which interest appears the most often?
-- 3. What is the average of the average composition for the top 10 interests for each month?
-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to 
	-- August 2019 and include the previous top ranking interests in the same output shown below.
-- 5. Provide a possible reason why the max average composition might change from month to month? 
	-- Could it signal something is not quite right with the overall business model for Fresh Segments?
