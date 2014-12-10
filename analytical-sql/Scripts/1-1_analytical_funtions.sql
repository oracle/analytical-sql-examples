rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem
rem If you need to reset your buffer cache during this session, i.e.
rem when you are reviewing explain plans etc then you might find
rem this commmand usefyul:
rem
rem alter system flush buffer_cache;
rem



rem  start with a basic report showing a running total for a specific product sub-category
rem  and for a specific year. The report will show the amount sold in each month
rem  and the final column will create a running total.

SELECT
 prod_subcategory_desc AS category,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (ORDER BY calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803';

rem  notice what happens to our running total if we extend
rem  the time range to cover more than one year....
rem  notice that the total does not reset when a new year
rem  starts!

SELECT
 prod_subcategory_desc AS category,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (ORDER BY calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id >='1803';


rem  although the report looks ok this is actually more by chance because
rem  the data happens to be in the correct order in our fact table.
rem  To make sure we always get the data back in the correct order
rem  it is important to include a final ORDER BY clause to ensure the running
rem  totals match up with the order in the final report.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (ORDER BY calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_month_id;


rem  now show what happens if we completely remove the ORDER BY clause - this controls the window
rem  that is used to frame our running total so if we remove the ORDER BY clause then we are
rem  the analytic function to revert to its default processing of using the whole 
rem  set as the window.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER () AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_month_id;

rem  then I just get the grand total of all the sales which is similar
rem  to use a SUM() without a GROUP BY clause....the grand total, reported 
rem  for each row and this is a useful feature because it 
rem  allows us to do row-to-total comparisons.


rem  now let's see what happens if we remove the filter on subcategory description
rem  and view all subcategories?

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER 
 (ORDER BY prod_subcategory_id, calendar_month_desc) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY calendar_month_id;

rem  Two points:
rem  1) now we see the importance of the ORDER BY clause both within the analytical
rem  function and the output for the report so what we need to do is extend the 
rem  final ORDER BY clause

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER 
 (ORDER BY prod_subcategory_id, calendar_month_desc) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_id, calendar_month_id;


rem  2) We get a report that shows the running total over all product sub-categories
rem  but notice that there is no break/reset when the sub-category changes!



/*
Part 1b - running totals the hardway...using inline query

*/
rem  Can I create the same report showing cumulative sales without using analytical SQL? 
rem  Yes but it can get very messy as we can see here.
rem  As an alternative we could use a view or an inline subquery with group by
rem  clause to generate the totals we need:

SELECT
 pms1.prod_subcategory_desc AS subcategory,
 pms1.calendar_month_desc AS month,
 pms1.amount_sold AS sales,
 (SELECT 
   SUM(amount_sold)
  FROM PRODCAT_MONTHLY_SALES pms2
  WHERE calendar_year_id ='1803'
  AND prod_subcategory_desc ='Cameras'
  AND pms2.calendar_month_id <= pms1.calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES pms1
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY pms1.calendar_month_id;


rem  worth looking at the explain plan for both queries as this highlights the additional
rem  simplicity. Performance of the analytic function is much better than the inline subquery

/* 
PART 2 of demo script to show how to correctly use PARTITION BY clause. 
*/

rem  now we want to use the PARTITION BY clause but without an ORDER BY
rem  clause....note that we have now modified by final ORDER BY clause
rem  to include deptno so that it matches the PARTITION BY clause


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) 
    OVER (PARTITION BY calendar_quarter_id) AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;


rem  so now I have the total sale within each quarter...
rem  As an alternative we could use a view or an inline subquery with group by
rem  clause to generate the quarterly totals we need:

SELECT
 pms1.prod_subcategory_desc AS subcategory,
 pms1.calendar_quarter_desc AS quarter, 
 pms1.calendar_month_desc AS month,
 pms1.amount_sold AS sales,
 pms2.tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES pms1,
(SELECT
  calendar_quarter_id,
  SUM(amount_sold) as tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
GROUP BY calendar_quarter_id) pms2
WHERE pms1.prod_subcategory_desc ='Cameras'
AND pms1.calendar_year_id ='1803'
AND pms2.calendar_quarter_id = pms1.calendar_quarter_id
ORDER BY pms1.calendar_quarter_id, pms1.calendar_month_id;


rem  if we extend our analytical SQL SUM() function to include
rem  an ORDER BY clause then you can see in the explain plan
rem  that we do not incur an additional sort because we optimize
rem  and reduce the two ORDER BY clauses to a single SORT operation
rem

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) 
    OVER (PARTITION BY calendar_quarter_id ORDER BY calendar_month_id) AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;



rem  what happens if we have more than one product category?
rem  what do we expect to see? This report produces the total for each
rem  quarter across both product subcategories.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) 
    OVER (PARTITION BY calendar_quarter_id) 
    AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;


rem  what we really need to see is the quarterly total for each product subcategory
rem  as you can see here: if we change the ORDER BY clause to include product subcategory
rem  then the actual order of the rows within the report makes it very difficult to understatand
rem  the values in tot_qtr_sales because the totals apply to each quarter and
rem  are not linked to the product category.
rem

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) 
    OVER (PARTITION BY calendar_quarter_id) 
    AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;


rem  what we actually need to do to create quarterly totals for each product subcategory
rem  is extend our PARTITION BY clause to include prod_subcategory_desc and then we need
rem  to include this column in the ORDER BY clause as well:


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) 
    OVER (PARTITION BY prod_subcategory_desc, calendar_quarter_id) 
    AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  the point of this section was to show that sometimes it can be difficult to 
rem  understand how the data being returned is computed. You need to examine it
rem  in detauil to fully understand the results. Therefore, you need to be very
rem  careful in terms of how you use the PARTITION BY and ORDER BY clauses
rem  as these can completely change the results 

/* 
PART 3 of demo script to show how to correctly use PARTITION BY and ORDER BY. 
*/

rem  So now what happens now if we add back in the ORDER BY clause and sort by the
rem  calendar month? 

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER 
 (PARTITION BY prod_subcategory_desc, calendar_quarter_id ORDER BY calendar_month_id) AS cum_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  Now we get a running total within each quarter where the total resets at the boundary of each quarter
rem  What's next.....

rem  now we can extend the example to show the cumulative quarterly sales, total quarterly sales and
rem  total sales for our cameras subcategory.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id ORDER BY calendar_month_id) AS cum_qtr_sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id) AS tot_qtr_sales,
 SUM(amount_sold) OVER () AS tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;

rem  once we have the various totals in place we can start using them in calculations
rem  but note that we cannot reference the analytical functions using a column alias
rem  we have to repeat the function to use in within a calculation as shown here:


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id ORDER BY calendar_month_id) AS cum_qtr_sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id) AS tot_qtr_sales,
 SUM(amount_sold) OVER () AS tot_sales,
 TRUNC((amount_sold/SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id))*100,2) AS contribution_qtr_sales,
 TRUNC((amount_sold/SUM(amount_sold) OVER ())*100,2) AS contribution_tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;

 


rem  Now lets extend the report to include a breakout by channel to create cumulative balances within each
rem  sub-category and channel. We can create a cumulative running total within each quarter by changing 
rem  the PARTIION BY and ORDER BY clauses...
rem  

rem  Due to the way the data is returned, it might not be clear but the totals are actually SELECT
 prod_subcategory_desc AS subcategory,
 channel_desc AS channel,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (PARTITION BY prod_subcategory_desc, channel_id, calendar_quarter_id ORDER BY calendar_month_id) AS cum_mnth_sales,
 SUM(amount_sold) OVER (PARTITION BY prod_subcategory_desc, channel_id  ORDER BY calendar_quarter_id) AS cum_qtr_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, channel_id, calendar_quarter_id, calendar_month_id;

rem  this now creates a running total within each quarter for each product subcategory and distribution
rem  channel


/* 
PART 4 of demo script to show how to correctly use windows. 
*/
rem  We are going to look at the concept of windows.
rem  In this example we are using a physical window to sum the sales of the current
rem  record with the sales from the previous two rows. This creates a 3-month moving 
rem  total.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY calendar_month_id ROWS 2 PRECEDING),0) 
     AS "3m_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;



rem  this syntax actually requires a little more explanation because what we are actually stating
rem  is that we want the value in the current row added to the vaule in the preceding row but the
rem  syntax for analytic function simplifies this down to ROWS 2 PRECEDING.
rem

rem  what happens if we have a month with no sales? In this case we did not sell any cameras in
rem  November so if we have a dense time dimension we will end-up with a row for November with null
rem  sales. If we wrap the sales column in an NVL() then we can maintain the 3-month moving average
rem  calculation for December rather than it default to a moving average based on two months:

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(nvl(amount_sold,0)) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY calendar_month_desc ROWS 2 PRECEDING),0) 
     AS "3m_mavg_sales"
FROM DENSE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;


rem  If we want to add the current value to the value in the next row then we have to use a slightly
rem  different syntax which does include the CURRENT ROW identifier along with the key word FOLLLOWING
rem  as shown here:


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY calendar_month_id ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),0) AS "3m_fl_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  or we can use the PRECEDING AND FOLLLOWING keywords rather than CURRENT ROW and FOLLOWING keywords
rem  which allows you to create a centered moving average...

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,

 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY calendar_month_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),0) 
     AS "3m_cmavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  ...and it all depends on the ORDER BY clause inside the analytic function
rem  which determines the output value so if you sort months in descending order
rem  the output is just like the prior statement where we now have a normal 3-month
rem 

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY calendar_month_id desc ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),0) AS "3m_fl_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  now if you look at the explain plan you will see an additional final sort step that is linked
rem  to the analytical ORDER BY clause since we can no longer rely on the GROUP BY clause to 
rem  order the data correctly for the analytical function.
rem
rem
rem  and of course we can include all the calculations within the same SQL statement:
rem

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) OVER (PARTITION BY prod_subcategory_desc ORDER BY calendar_month_id ROWS 2 PRECEDING),0) AS "3m_mavg_sales",
 TRUNC(AVG(amount_sold) OVER (PARTITION BY prod_subcategory_desc ORDER BY calendar_month_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),0) AS "3m_cmavg_sales",
 TRUNC(AVG(amount_sold) OVER (PARTITION BY prod_subcategory_desc ORDER BY calendar_month_id ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),0) AS "3m_fl_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;


rem  now we want to use a logical or range based window to find the 3 monthly average salary by using the 
rem  RANGE keyword and defining the number of months within the range. This means that the analytic
rem  function will have to determine if the previous month is within 2 months of the current row's month


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING),0) 
     AS "3m_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;


rem  this raises an interesting point about how missing rows are managed by analytical
rem  functions. Look at the last row for month 1999-12. The 3 month moving average for
rem  this row is actually month 10 + month 12 divided by 2 because month 11 did not record
rem  any sales. If you want to check what is being included in the calculation for each row
rem then we can use two additional functions: FIRST_VALUE and LAST_VALUE

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES",
 count(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS count_periods,
 FIRST_VALUE(calendar_month_desc) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS start_window,
 LAST_VALUE(calendar_month_desc) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS end_window
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;


rem  so how do we deal with missing values? If we have a row showing null value - 
rem  in this case November? If we wrap the sales column in an NVL() then we can maintain the 3-month moving average
rem  calculation for December rather than it default to a moving average based on two months:

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') 
     RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES"
FROM DENSE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;


rem  but what happens if we have two rows for November? This shows that we assign the same
rem  value to both rows that are labelled as November.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') 
     RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES",
 count(amount_sold) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS count_periods,
FROM DENSE_DUPLICATE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;


rem  what happens if we have duplicate rows that contain data, i.e. there are no nulls?
rem  Then we find that the duplicate rows are taken into account when we compute the
rem  moving average. In this case the NULL value in November is now replaced by a zero
rem  so the moving average for November and December is based on 4 values and not 3!

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(nvl(amount_sold,0)) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') 
     RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES",
 count(nvl(amount_sold,0)) 
     OVER (PARTITION BY prod_subcategory_desc 
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') 
     RANGE INTERVAL '2' MONTH PRECEDING) AS count_periods
FROM DENSE_DUPLICATE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;


rem  Using analytical SQL to filter results. We want to find the months contributing > 10% of subcategory sales
rem  within product subcategories contributing > 10% total sales.  We can use the result set from analytical functions
rem  in the WHERE clause to apply the filtering

rem  Step 1: build the body of the query:
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (PARTITION BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803';

rem  Step 2: apply the filter to find the product subcategories contributing more than 10% of total sales
 

SELECT
 subcategory,
 quarters,
 months,
 TRUNC(sales,0) AS sales,
 TRUNC(psc_sales, 0) AS psc_sales,
 TRUNC(tot_sales, 0) AS tot_sales,
 TRUNC((sales/psc_sales)*100, 0) AS cont_psc_sales,  
 TRUNC((psc_sales/tot_sales)*100, 0) AS cont_tot_sales 
FROM 
(SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 amount_sold AS sales,
 SUM (amount_sold) OVER (PARTITION BY prod_subcategory_desc) psc_sales,
 SUM (amount_sold) OVER () tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803')
WHERE psc_sales > 0.1 * tot_sales 
ORDER BY subcategory, quarters, months;

rem  Step 3: apply the filter to find the rows where the monthly contribution is more than 10% of product subcategory
rem  total sales

SELECT
 subcategory,
 quarters,
 months,
 TRUNC(sales,0) AS sales,
 TRUNC(psc_sales, 0) AS psc_sales,
 TRUNC(tot_sales, 0) AS tot_sales,
 TRUNC((sales/psc_sales)*100, 0) AS cont_psc_sales,  
 TRUNC((psc_sales/tot_sales)*100, 0) AS cont_tot_sales 
FROM 
(SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 amount_sold AS sales,
 SUM (amount_sold) OVER (PARTITION BY prod_subcategory_desc) psc_sales,
 SUM (amount_sold) OVER () tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803')
WHERE psc_sales > 0.1 * tot_sales 
AND sales > 0.1 * psc_sales
ORDER BY subcategory, quarters, months;


/* 
PART 5 of demo script to show sort optimizations. Starting with this script which contains
one sort statement
*/
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_desc,
         calendar_quarter_desc,
         calendar_month_desc;

rem  now as we add more analytic functions that include ORDER BY clauses that we
rem start to incurr additional sort steps in the explain plan.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY channel_class),0) c_psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY calendar_quarter_id, calendar_month_id),0) qm_psc_sales, 
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_desc,
         calendar_quarter_desc,
         calendar_month_desc;
         
rem if we add another function that includes an ORDER BY clause we can see that the sort
rem  optimizations kick-in and we start reusing previous sorts...


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY channel_class),0) c_psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY calendar_quarter_id, calendar_month_id),0) qm_psc_sales, 
 TRUNC(SUM (amount_sold) OVER (ORDER BY calendar_quarter_id),0) q_psc_sales, 
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_desc,
         calendar_quarter_desc,
         calendar_month_desc;