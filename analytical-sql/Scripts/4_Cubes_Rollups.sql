rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

rem  scripts to demonstrate how to use the various rollup
rem  features to calculate hierarchical totals within a 
rem  cube.
rem

/* 
Part 1 - cube/rollup features
*/

rem  Start with a standard GROUP BY clause to calculate
rem  totals at Year Category level


SELECT 
  calendar_year,
  prod_category_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY calendar_year, prod_category_desc
ORDER BY calendar_year, prod_category_desc;


rem  now extend the basic totalling by using the ROLLUP()
rem  feature as follows 

SELECT 
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY ROLLUP 
   (calendar_year,
   calendar_quarter_desc,
   calendar_month_desc)
ORDER BY   
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc;


rem  and we can extend this to compute the totals across the time periods
rem  for all our product categories

SELECT 
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc,
  prod_category_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY prod_category_desc,
ROLLUP 
 (calendar_year,
  calendar_quarter_desc,
  calendar_month_desc)
ORDER BY   
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc;
  


rem  now we switch to CUBE to automatically generate totals for all
rem categories and all years along with a final total

SELECT 
  calendar_year,
  prod_category_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc)
ORDER BY calendar_year, prod_category_desc;



/* 
Part 2 - more sophisticated aggregations...
*/

rem  now calculating totals for specific groupings of levels within in 
rem  each dimension

SELECT 
  calendar_year,
  calendar_quarter_desc,
  prod_category_desc,
  prod_subcategory_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY GROUPING SETS ((calendar_year, prod_category_desc), 
                        (calendar_quarter_desc, prod_subcategory_desc))
ORDER BY calendar_year, calendar_quarter_desc, prod_category_desc, prod_subcategory_desc;


rem  now using a combination of GROUP BY and GROUPING ID to calculate totals
rem  within our cube

SELECT
  calendar_month_desc,
  prod_category_desc,
  prod_subcategory_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY calendar_month_desc,
GROUPING SETS(prod_category_desc, prod_subcategory_desc)
ORDER BY calendar_month_desc, prod_category_desc, prod_subcategory_desc;

rem  computing the whole cube....
rem  
SELECT
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc,
  prod_desc,
  prod_category_desc,
  prod_subcategory_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY 
GROUPING SETS (calendar_year, calendar_quarter_desc, calendar_month_desc),
GROUPING SETS (prod_category_desc,prod_subcategory_desc,prod_desc)
ORDER BY calendar_year, calendar_quarter_desc, calendar_month_desc, prod_category_desc, prod_subcategory_desc, prod_desc;

rem  working out which lines are computed by the GROUP BY clause and which lines are aggregated
rem  based on the GROUP BY extension clauses: CUBE-ROLLUP-GROUPING etc....
SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold),
  GROUPING(calendar_year) AS t_tot_id,
  GROUPING(prod_category_desc) AS p_tot_id
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc);

rem  now fill in missing values for dimension descriptions...
rem
SELECT
  DECODE(GROUPING(calendar_year), 1, 'All Years', calendar_year) AS years,
  DECODE(GROUPING(prod_category_desc), 1, 'All Products', prod_category_desc) as products,
  SUM(amount_sold),
  GROUPING(calendar_year) AS t_tot_id,
  GROUPING(prod_category_desc) AS p_tot_id
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc);


rem  now using the more sophisticated GROUPING_ID column to list
rem  all the required vectors within a single column
rem   
SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold),
  GROUPING(calendar_year) AS t_tot_id,
  GROUPING(prod_category_desc) AS p_tot_id,
  GROUPING_ID(calendar_year, prod_category_desc) AS t_tot_id
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc);


rem  using CUBE and PIVOT together can cause problems...
rem

SELECT   
*
FROM
(SELECT 
  calendar_year,
  prod_category_desc,
  SUM(amount_sold) AS amount_sold
FROM prod_monthly_sales
WHERE prod_category_desc IN ('Photo', 'Hardware')
AND calendar_year_id IN ('1803', '1804')
GROUP BY CUBE (calendar_year, prod_category_desc))
PIVOT (SUM(amount_sold) 
       FOR calendar_year 
       IN ('1999', '2000', NULL));

rem  actually needs the following to work correctly:

SELECT   
*
FROM
(SELECT 
  DECODE(GROUPING(calendar_year), 1, 'All Years'
        , calendar_year) AS calendar_year,
   DECODE(GROUPING(prod_category_desc), 1, 'All Products', prod_category_desc) as prod_category_desc,
  SUM(amount_sold) AS amount_sold
FROM prod_monthly_sales
WHERE prod_category_desc IN ('Photo', 'Hardware')
AND calendar_year_id IN ('1803', '1804')
GROUP BY CUBE (calendar_year, prod_category_desc))
PIVOT (SUM(amount_sold) 
       FOR calendar_year 
       IN ('1999', '2000', 'All Years'));
       
