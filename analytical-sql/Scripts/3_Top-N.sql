rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

rem  contains the code for running TOP-N queries as follows
rem  against the tables/views in the SH schema. There are no
rem  additional tables/views to create for this set of examples

rem  this shows my the rows that make up the worst 20% of my
rem  product sales during 1999...

SELECT
  prod_subcategory_desc,
  sum(amount_sold) AS "1999_SALES"
FROM prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY prod_subcategory_desc
ORDER BY "1999_SALES" ASC
FETCH FIRST 20 percent ROWS ONLY;


rem  the code above gets rewritten as follows:
rem

SELECT
  prod_subcategory_desc,
  SALES
FROM 
(SELECT 
  prod_subcategory_desc,
  sum(amount_sold) AS SALES,
  ROW_NUMBER() over (ORDER BY sum(AMOUNT_SOLD)) rn,
  COUNT(*) over () total_rows
FROM prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY prod_subcategory_desc
ORDER BY SALES ASC)
WHERE rn <= CEIL(total_rows * 20/100);

rem  what is interesting is when you include the analytical functions
rem  within your SQL as shown here:


SELECT
  channel_class,
  prod_subcategory_desc,
  sum(amount_sold) AS "1999_SALES"
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY channel_class, prod_subcategory_desc
ORDER BY channel_class, "1999_SALES" ASC
FETCH FIRST 25 percent ROWS ONLY;


rem  the only problem with TOP-N is that you cannot apply it
rem  within a partition so you need to use an alternative approach

SELECT * 
FROM (
SELECT
  channel_class,
  prod_subcategory_desc,
  SUM(amount_sold) AS "1999_SALES",
  DENSE_RANK() OVER (PARTITION BY channel_class ORDER BY sum(amount_sold) ASC) rnk  
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY channel_class, prod_subcategory_desc
ORDER BY channel_class, "1999_SALES" ASC)
WHERE rnk <= 5;

