rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem
rem  ****************************************************************

/* Create required tables/views to support scripts

simplified view over sales fact table in sales_history schema

CREATE VIEW sales_view AS
SELECT country_name country,
prod_name product,
calendar_year year,
SUM(amount_sold) sales, 
COUNT(amount_sold) cnt,
MAX(calendar_year) KEEP (DENSE_RANK FIRST ORDER BY SUM(amount_sold) DESC) OVER (PARTITION BY country_name, prod_name) best_year, 
MAX(calendar_year) KEEP (DENSE_RANK LAST ORDER BY SUM(amount_sold) DESC) OVER (PARTITION BY country_name, prod_name) worst_year
FROM sales, times, customers, countries, products
WHERE sales.time_id = times.time_id 
AND sales.prod_id = products.prod_id 
AND sales.cust_id =customers.cust_id 
AND customers.country_id=countries.country_id
GROUP BY country_name, prod_name, calendar_year;



CREATE TABLE mortgage_facts (customer VARCHAR2(20), fact VARCHAR2(20), 
   amount  NUMBER(10,2));
INSERT INTO mortgage_facts  VALUES ('Smith', 'Loan', 100000);
INSERT INTO mortgage_facts  VALUES ('Smith', 'Annual_Interest', 12);
INSERT INTO mortgage_facts  VALUES ('Smith', 'Payments', 360);
INSERT INTO mortgage_facts  VALUES ('Smith', 'Payment', 0);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Loan', 200000);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Annual_Interest', 12);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Payments', 180);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Payment', 0);


CREATE TABLE mortgage (customer VARCHAR2(20), pmt_num NUMBER(4),
   principalp NUMBER(10,2), interestp NUMBER(10,2), mort_balance NUMBER(10,2));
INSERT INTO mortgage VALUES ('Jones',0, 0, 0, 200000);
INSERT INTO mortgage VALUES ('Smith',0, 0, 0, 100000);


CREATE OR REPLACE VIEW sales_rollup_time AS
  SELECT
    country_name country, calendar_year year,
    calendar_quarter_desc quarter,
    grouping_id(calendar_year, calendar_quarter_desc) gid,
    sum(amount_sold) sale, count(amount_sold) cnt
  FROM sales, times, customers, countries
  WHERE sales.time_id = times.time_id and
        sales.cust_id = customers.cust_id and
        customers.country_id = countries.country_id
  GROUP BY country_name, calendar_year, ROLLUP(calendar_quarter_desc)
  ORDER BY gid, country, year, quarter;
  
  
*/
