rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

rem  Let's start in simple way using the sales history schema. If we want to see a grid of total sales by quarters across
rem  channels we can start by creating the input query that will deliver our resultset into our PIVOT clause
rem  The query to build the resultset looks like this:

SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 channel_class AS channel,
 sum(amount_sold) AS sales
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc, prod_category_desc, channel_class
ORDER BY calendar_quarter_desc, prod_category_desc, channel_class;


rem  we can now pass this to the PVIOT clause to transpose the rows containing the departmemt ids into
rem  into columns the pre-PIVOT workaround is to use a CASE statement as follows:
rem

SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 SUM(CASE WHEN channel_class='Direct' THEN amount_sold ELSE NULL END) AS "Direct",
 SUM(CASE WHEN channel_class='Direct' THEN amount_sold ELSE NULL END) AS "Indirect",
 SUM(CASE WHEN channel_class='Direct' THEN amount_sold ELSE NULL END) AS "Others"  
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc, prod_category_desc
ORDER BY calendar_quarter_desc, prod_category_desc;



rem  the pivot statements above provide a resultset that contains two row edges and
rem  and a single column edge. The following example creates a multi-column report which contains 
rem  two column edges: quarters and channels
rem

SELECT *
FROM
(SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 channel_class AS channel,
 sum(amount_sold) AS sales
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc, prod_category_desc, channel_class)
PIVOT(sum(sales) FOR (qtr, channel) 
                 IN (('1999-01', 'Direct'),
                    ('1999-02', 'Direct'),
                    ('1999-03', 'Direct'),
                    ('1999-04', 'Direct'),
                    ('1999-01', 'Indirect'),
                    ('1999-02', 'Indirect'),                   
                    ('1999-03', 'Indirect'),
                    ('1999-04', 'Indirect')))
ORDER BY category;


rem  now lets combine our window functions within the PIVOT operation
rem  by creating a report that shows each product category, its sales and
rem  its contribution.


SELECT * FROM
(SELECT 
   quarter_id,
   prod_c_desc,
   sales,
   SUM(sales) OVER (PARTITION BY quarter_id) AS qtd_sales,
   (sales/SUM(sales) OVER (PARTITION BY quarter_id))*100 AS qtd_contribution
   FROM
(SELECT
   quarter_id AS quarter_id,
   prod_c_desc AS prod_c_desc,
   SUM(sales) AS sales
 FROM sh.prod_time_sales
 GROUP BY quarter_id, prod_c_desc)
ORDER BY quarter_id, prod_c_desc)
PIVOT (SUM(sales) AS sales,
      SUM(qtd_sales) AS qtd_sales,
      SUM(to_char(qtd_contribution, '99.99')) AS qtd_contribution
FOR quarter_id IN ('1998-01','1998-02','1998-03','1998-04'));



rem  XML query output for each product catwegories sales for 1998 Q1
rem  note that we are using the  xmlserialize function to output
rem  the results of the column containing the XML 

SELECT 
 prod_c_desc,
 xmlserialize(content quarter_id_xml) xml 
FROM
(SELECT
  quarter_id,
  prod_c_desc,
  sales
FROM sh.prod_time_sales 
WHERE year_id='1802')
PIVOT XML (SUM(sales) sales
FOR quarter_id IN (SELECT distinct quarter_id from sh.prod_time_sales where quarter_id='1998-01'));




rem  UNPIVOTING a data set is easy and takes us back to our original input data
rem  from the sales table.


SELECT * 
FROM PIVOT_CHAN_PRODCAT_SALES
UNPIVOT (sales 
        FOR channel_class IN ("'Direct'" as 'DIRECT', 
                              "'Indirect'" AS 'INDIRECT', 
                              "'Others'" AS 'OTHERS'));


rem  the non-unpivot workaround would be to use the following SQL:
rem 

SELECT qtr AS calendar_quarter_desc,
       category AS prod_category_desc,
      'DIRECT' As channel_class,
      "'Direct'" AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES 
UNION ALL
SELECT qtr AS calendar_quarter_desc,
       category AS prod_category_desc,
      'INDIRECT' As channel_class,
      "'Indirect'" AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES 
UNION ALL
SELECT qtr AS calendar_quarter_desc,
       category AS prod_category_desc,
      'OTHERS' As channel_class,
      "'Others'" AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES;



rem  There is also another way of doing this using the DECODE method as follows:
SELECT 
  qtr AS calendar_quarter_desc,
  category AS prod_category_desc,
 DECODE(unpivot_row, 1, 'DIRECT',
                     2, 'INDIRECT',
                     3, 'OTHERS',
                     'N/A') AS channel_class,
 DECODE(unpivot_row, 1, "'Direct'",
                     2, "'Indirect'",
                     3, "'Others'",
                     'N/A') AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES,
       (SELECT level AS unpivot_row FROM dual CONNECT BY level <= 3)
ORDER BY 1,2,3;



