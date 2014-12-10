rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************

rem  scripts to demonstrate how to use the various rollup
rem  features to calculate hierarchical totals within a 
rem  cube.
rem
rem  Create more detailed view at PRODUCT level

CREATE OR REPLACE VIEW PROD_MONTHLY_SALES 
AS 
SELECT
 p.prod_id,
 p.prod_desc,
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id, 
 t.calendar_year, 
 SUM(s.amount_sold) AS amount_sold
FROM channels c, products p, sales s, times t
WHERE t.time_id = s.time_id (+)
AND s.prod_id = p.prod_id
and s.channel_id = c.channel_id
GROUP BY p.prod_category_id,
 p.prod_category_desc, 
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 p.prod_id,
 p.prod_desc,
 t.calendar_year_id, 
 t.calendar_year,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_month_id,
 t.calendar_month_desc;

