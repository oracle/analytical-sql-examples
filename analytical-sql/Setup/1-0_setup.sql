rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
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

rem  the following query just introduces analytical SQL
rem  by creating a cumulative/running total for salary 
rem  note the extension to the SUM() function using
rem  the OVER and ORDER BY key words
rem

rem Assumes that you have installed the sales history schema from the 
rem examples CD. The following lines of code create all the required
rem additional views needed for this series of scripts on analytical
rem  SQL
rem


CREATE OR REPLACE VIEW PRODCAT_MONTHLY_SALES AS 
  SELECT
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
FROM sales s, products p, times t
WHERE s.prod_id=p.prod_id
AND s.time_id = t.time_id
GROUP BY p.prod_category_id,
 p.prod_category_desc, 
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id, 
 t.calendar_year;
 
 
CREATE OR REPLACE VIEW CHAN_PRODCAT_MONTHLY_SALES AS 
SELECT
 c.channel_id,
 c.channel_desc,
 c.channel_class_id, 
 c.channel_class,
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
FROM sales s, products p, times t, channels c
WHERE s.prod_id=p.prod_id
AND s.time_id = t.time_id
AND s.channel_id = c.channel_id
GROUP BY c.channel_id,
 c.channel_desc,
 c.channel_class_id, 
 c.channel_class, 
 p.prod_category_id,
 p.prod_category_desc, 
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id, 
 t.calendar_year;

View for doing outer joins on times table to fill in missing values
so we have a dense time colum in our fact tables

CREATE OR REPLACE VIEW MONTHLY_TIMES AS 
SELECT
 DISTINCT t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id, 
 t.calendar_year 
FROM times t;

NEEDS REBUILDING FROM THE SALES FACT TABLE

CREATE OR REPLACE VIEW DENSE_CHAN_PRODCAT_MONTHLY_SALES AS
SELECT
 PROD_SUBCATEGORY_DESC,
 CHANNEL_DESC,
 calendar_QUARTER_DESC,
 CALENDAR_MONTH_DESC,
 AMOUNT_SOLD
FROM
(SELECT
 s.prod_subcategory_desc AS prod_subcategory,
 s.channel_desc AS channel_id,
 s.calendar_quarter_desc AS quarter_id, 
 s.calendar_month_desc AS month_id,
 s.amount_sold AS sales
FROM CHAN_PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_id not in (2051, 2031)) v
PARTITION BY (v.prod_subcategory,v.channel_id)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id,
 t.calendar_month_desc AS calendar_month_desc
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.month_id = t.calendar_month_id AND v.quarter_id = t.calendar_quarter_id)
ORDER BY 1,2,3,4;


CREATE OR REPLACE VIEW DENSE_CAMERA_SALES AS
select 
 v.prod_subcategory_desc AS prod_subcategory_desc,
 t.calendar_quarter_id AS calendar_quarter_desc, 
 t.calendar_month_id AS calendar_month_desc,
 v.amount_sold AS amount_sold
from
(SELECT
 s.prod_subcategory_desc AS prod_subcategory_desc,
 s.calendar_quarter_desc AS calendar_quarter_desc, 
 s.calendar_month_desc AS calendar_month_desc,
 s.amount_sold AS amount_sold
FROM PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_desc = 'Cameras') v
PARTITION BY (v.prod_subcategory_desc)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.calendar_month_desc = t.calendar_month_id AND v.calendar_quarter_desc = t.calendar_quarter_id);


Need this view to show the process for managing sparsity/nulls within moving average

CREATE OR REPLACE VIEW DENSE_PRODCAT_MONTHLY_SALES AS
SELECT
 PROD_SUBCATEGORY_DESC,
 calendar_QUARTER_DESC,
 CALENDAR_MONTH_DESC,
 AMOUNT_SOLD
FROM
(SELECT
 s.prod_subcategory_desc AS prod_subcategory,
 s.channel_desc AS channel_id,
 s.calendar_quarter_desc AS quarter_id, 
 s.calendar_month_desc AS month_id,
 s.amount_sold AS sales
FROM CHAN_PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_id not in (2051, 2031)) v
PARTITION BY (v.prod_subcategory,v.channel_id)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id,
 t.calendar_month_desc AS calendar_month_desc
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.month_id = t.calendar_month_id AND v.quarter_id = t.calendar_quarter_id)
ORDER BY 1,2,3,4;


Need this view to show the process for managing duplicates within moving average

CREATE OR REPLACE VIEW DENSE_DUPLICATE_CAMERA_SALES AS
SELECT
 prod_subcategory_desc,
 calendar_quarter_desc, 
 calendar_month_desc,
 amount_sold
FROM DENSE_CAMERA_SALES
UNION
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter, 
 calendar_month_desc AS month,
 amount_sold AS sales
FROM DENSE_CAMERA_SALES
  MODEL RETURN UPDATED ROWS
     PARTITION BY (prod_subcategory_desc)
     DIMENSION BY (calendar_quarter_desc, calendar_month_desc)
     MEASURES (amount_sold amount_sold)
     RULES (amount_sold['1999-04', '1999-11'] = amount_sold['1999-01', '1999-01']);


view to create duplicate rows for ranking....

CREATE OR REPLACE VIEW DUPLICATE_RANK_ROWS AS
SELECT * FROM
(SELECT 
 channel_class,
 prod_subcategory_desc,
 SUM(amount_sold) AS amount_sold
FROM channels c,
(SELECT *
FROM CHAN_PRODCAT_MONTHLY_SALES
MODEL RETURN UPDATED ROWS
     PARTITION BY (calendar_month_id, channel_id)
     DIMENSION BY (prod_subcategory_id)
     MEASURES (amount_sold, prod_subcategory_desc)
     RULES (amount_sold['9998'] = amount_sold['2044'],
            prod_subcategory_desc['9998'] = 'Tablet',
            amount_sold['9999'] = amount_sold['2044'],
            prod_subcategory_desc['9999'] = 'Smartphone')) n
WHERE n.channel_id = c.channel_id
GROUP BY  channel_class, prod_subcategory_desc
UNION
SELECT 
 channel_class,
 prod_subcategory_desc,
 SUM(amount_sold) AS amount_sold
FROM CHAN_PRODCAT_MONTHLY_SALES
GROUP BY  channel_class, prod_subcategory_desc)
ORDER BY 3;


