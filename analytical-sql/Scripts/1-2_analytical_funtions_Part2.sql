rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

/* Part 1 - Ranking data

*/

rem  ranking of data to find top 10 or bottom 10 is a common requirement.
rem  RANK() can be used in a similar way to other analytical aggregates
rem  such as SUM(), COUNT(), AVG() etc.
rem  We can create rankings across the whole data set or within each
rem  specific partition/group.


SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  SUM(amount_sold) AS sales,  RANK () OVER (ORDER BY SUM(amount_sold) DESC) as s_rank
FROM chan_prodcat_monthly_sales
GROUP BY channel_class, prod_subcategory_desc;


rem  in this script we create rankings within each channel
rem

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  SUM(amount_sold) AS sales,
  RANK () OVER (PARTITION BY channel_class ORDER BY SUM(amount_sold) DESC) as s_rank
FROM chan_prodcat_monthly_sales
GROUP BY channel_class, prod_subcategory_desc;

rem  so that we can select the top 5 product subcategories within each channel
rem  we can use the rank column to create an additional filter:

SELECT
*
FROM (SELECT
  channel_class AS channel_class,
  prod_subcategory_desc,
  SUM(amount_sold) AS amount_sold,  
  RANK() OVER (PARTITION BY channel_class ORDER BY SUM(amount_sold) DESC) AS sales_rank
FROM chan_prodcat_monthly_sales
GROUP BY channel_class, prod_subcategory_desc)
WHERE sales_rank < 6;



rem  when creating a ranking need to consider what to do about ties since
rem  this will affect the rank number assigned to each row. Oracle provides
rem  two functions for ranking: RANK() and DENSE_RANK().
rem  The difference between RANK and DENSE_RANK is that DENSE_RANK leaves 
rem  no gaps in ranking sequence when there are ties. 

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  amount_sold AS sales,  
  RANK () OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as s_rank,
  DENSE_RANK () OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as d_rank
FROM duplicate_rank_rows;




rem  another common requirement is know which rows make up 80% or the top 20% 
rem  CUME_DIST. This function (defined as the inverse of percentile in some 
rem  statistical books) computes the position of a specified value relative to a 
rem  set of values. This makes it very easy to create pareto or 80:20 type reports
rem  and/or filters

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  amount_sold AS sales,  
  RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as s_rank,
  DENSE_RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as d_rank,
  TRUNC(CUME_DIST() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC),2) as c_dist
FROM duplicate_rank_rows;



rem  there is another way to get a similar result set by using PERCENT_RANK. This is 
rem  similar to CUME_DIST, but it uses rank values rather than row counts in its numerator. 
rem  Therefore, it returns the percent rank of a value relative to a group of values. 
rem  The calculation is based on the following forumula:
rem
rem  rank of row in its partition - 1) / (number of rows in the partition - 1)
rem
rem  The row(s) with a rank of 1 will have a PERCENT_RANK of zero so this will
rem  produce different results compared to CUME_DIST function() as shown below

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  TRUNC(amount_sold,0) AS sales,  
  RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as s_rank,
  DENSE_RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as d_rank,
  TRUNC(CUME_DIST() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC),2) as c_dist,
  TRUNC(PERCENT_RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC),2) as p_rank
FROM duplicate_rank_rows;



/*

Part 2a - LAG + LEAD functions 
*/
rem  using LAG and LEAD functions. Just to clarify, the values referenced in offset of the LAG/LEAD
rem  function have to be included in the result set, so for example the following statement
rem  returns null for the LAG() because the values for the prior year are not included in the
rem  resultset

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,   
  LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS Lyr_sales
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';



SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales, 
  LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS sales_var
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';

rem  in this example offest for the lag is 12 prior rows. Offset is an optional parameter and defaults to 1. 
rem  if offset falls outside the bounds of the table or partition, then there is an optional default parameter
rem  which provides the alternative value. BUT this is not the alternative OFFSET value but the actual an value
rem  that will be returned instead of the result of the normal LAG() processing.

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales, 
  LAG(amount_sold, 12, 2000) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  amount_sold - LAG(amount_sold, 12, 0) OVER (ORDER BY calendar_month_id) AS sales_var
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';


rem  we can use the lag to calculate sales variance comparing each month with the same month in the previous
rem  year...
rem

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,   LAG(amount_sold, 12,0) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  TRUNC(amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id,0)) AS sales_var,
  TRUNC(((amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))/LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))*100 , 0) AS var_pct
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';


rem  now if we want to find all the months where we have a drop in year-on-year sales of more than 50% we can use the following:
rem

SELECT * FROM
(SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,   
  LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  TRUNC(amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id,0)) AS sales_var,
  TRUNC(((amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))/LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))*100 , 0) AS var_pct
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras')
WHERE var_pct < -50;


rem  of course we can look forward as well as backwards...

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,   
  LAG(amount_sold, 12, 0) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  LEAD(amount_sold, 12,0) OVER (ORDER BY calendar_month_id) AS Nyr_sales
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';


/*

Part 2b - Ratio to report 
*/
rem  ratio_to_report is another useful function. It computes the ratio of a value to the sum of a set of values. 
rem  The PARTITION BY clause defines the groups on which the RATIO_TO_REPORT function is to be computed. If the PARTITION BY 
rem  clause is absent, then the function is computed over the whole query result set. In this example the grouping
rem is based on quarters so you get each months value as ration of the total for the specific quarter.

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_quarter_desc as quarters,
  calendar_month_desc as months,
  amount_sold as sales,   
  TRUNC(RATIO_TO_REPORT(amount_sold) OVER (), 3) 
    AS rtr_year,
  TRUNC(RATIO_TO_REPORT(amount_sold) 
        OVER (PARTITION BY calendar_quarter_id), 2) 
        AS rtr_qtr
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras'
AND calendar_year_id = '1803';









