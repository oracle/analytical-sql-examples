rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem
rem  ****************************************************************
rem

rem  scripts to demonstrate how to use the MODEL clause
rem  to apply business rules to data sets
rem


/* Part 1 - complex example

*/

SELECT m+1 month,                                               
            to_char(rem_loan, '99999999.00') rem_loan,          
            to_char(loan_paid_tot, '99999999.00') loan_paid_tot,
            to_char(mon_int, '999999.00') mon_int,              
            to_char(tot_int, '99999999.00') tot_int,            
            to_char(mon_paym, '99999999.00') mon_paym,          
            to_char(mon_paym_tot, '99999999.00') mon_paym_tot,  
            to_char(grand_tot, '99999999.00') grand_tot         
FROM dual
MODEL    
DIMENSION BY (-1 m)                                                                         
MEASURES (&&rem_loan rem_loan,                                                              
  round(&&rem_loan*&&year_int_rate/100/12,2) mon_int,                                       
  ceil(&&rem_loan/&&term*100)/100 mon_paym,                                                 
  (&&rem_loan/&&term*100)/100 loan_paid_tot,                                                
  round(&&rem_loan*&&year_int_rate/12/100,2) tot_int,                                       
  ceil(&&rem_loan/&&term*100)/100 + round(&&rem_loan*&&year_int_rate/100/12,2) mon_paym_tot,
  ceil(&&rem_loan/&&term*100)/100 + round(&&rem_loan*&&year_int_rate/100/12,2) grand_tot    
)
RULES ITERATE (&&term) UNTIL (round(loan_paid_tot[iteration_number], 2) = &&rem_loan) (
  rem_loan[iteration_number] = rem_loan[iteration_number -1] - mon_paym[iteration_number - 1],       
  mon_int[iteration_number] = round(rem_loan[iteration_number]*&&year_int_rate/100/12,2),            
  mon_paym[iteration_number] = least(ceil(&&rem_loan/&&term*100)/100, rem_loan[iteration_number]),   
  loan_paid_tot[iteration_number] = loan_paid_tot[iteration_number - 1] + mon_paym[iteration_number],
  tot_int[iteration_number] = tot_int[iteration_number - 1] + mon_int[iteration_number],             
  mon_paym_tot[iteration_number] = mon_paym[iteration_number] + mon_int[iteration_number],           
  grand_tot[iteration_number] = grand_tot[iteration_number - 1] + mon_paym_tot[iteration_number]); 

rem  extracted from http://gplivna.blogspot.co.uk/2008/10/mortgage-calculator-using-sql-model.html because calculator in Oracle
rem  documentation is not working! Reported as bug.
  
  
/* 
Part 2 - simple example
*/
rem  here is our source data from the sales history schema
rem  

SELECT SUBSTR(country,1,20) country, SUBSTR(product,1,15) product, year, sales FROM sales_view
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box');


rem  this simple example shows two important points. The model clause allows us to:
rem  
rem  1) over-write existing data points that are passed to the model
rem  clause and pushed into the array that is built in step 1 of the processing model
rem
rem  2) create new dimension values and data points - again these are added into the 
rem  array and are not written into the source table.

SELECT 
SUBSTR(country,1,20) country,
SUBSTR(product,1,15) product,
year,
sales 
FROM sales_view
WHERE country in ('Italy', 'Japan')
MODEL
RETURN UPDATED ROWS
MAIN simple_model
PARTITION BY (country) DIMENSION BY (product, year) MEASURES (sales)
RULES
(sales['Bounce', 2001] = 1000,
sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000], 
sales['Y Box', 2002] = sales['Y Box', 2001])
ORDER BY country, product, year;


rem  having overwritten the original sales value for Bounce in 2001 and then added a new year 
rem  value of 2002 and calculated corresponding sales figures, let's check that the original data
rem  has not been modified...

SELECT SUBSTR(country,1,20) country, SUBSTR(product,1,15) product, year, sales FROM sales_view
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box');

rem  If we need to update or insert rows in the database tables then we can use
rem  the INSERT, UPDATE, or MERGE statements to achieve this.

rem  we can refine the model to show the existing sales, updated sales and the
rem  forecasted sales as follows:

SELECT 
SUBSTR(country,1,20) country,
SUBSTR(product,1,15) product,
year,
sales,
upd_sales,
forecast
FROM sales_view
WHERE country in ('Italy', 'Japan')
MODEL
RETURN UPDATED ROWS
MAIN simple_model
PARTITION BY (country) 
DIMENSION BY (product, year) 
MEASURES (sales, 0 AS forecast, 0 AS upd_sales)
RULES
(upd_sales['Bounce', 2001] = 1000,
forecast['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000], 
forecast['Y Box', 2002] = sales['Y Box', 2001])
ORDER BY country, product, year;



rem  The following example shows how to use expressions and aliases within the
rem  model clause:

SELECT 
  country,
  p product,
  year,
  sales,
  profits 
FROM sales_view
WHERE country IN ('Italy', 'Japan')
MODEL
RETURN UPDATED ROWS
PARTITION BY (SUBSTR(country,1,20) AS country) DIMENSION BY (product AS p, year)
MEASURES (sales, 0 AS profits) RULES
(profits['Bounce', 2001] = sales['Bounce', 2001] * 0.25, 
 sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000], 
 profits['Bounce', 2002] = sales['Bounce', 2002] * 0.35)
ORDER BY country, year;

rem  Note that the alias "0 AS profits" initializes all cells of the profits measure to 0.

rem  We can include window functions ont the righthand side of a rule such as to
rem  create a running total within a model. The cumulative sum window functions is evaluated over all 
rem  rows qualified by the left side of the rule. In the above case, they are all the rows coming 
rem  to the Model clause. as shown below:
rem

select *
FROM SALES_VIEW
WHERE country IN ('Italy', 'Japan') 
AND product IN ('Bounce', 'Y Box')
MODEL 
   PARTITION BY (product)
   DIMENSION BY (country, year)
   MEASURES (sales, 0 AS csum)
   RULES upsert
     (csum[ANY,ANY] = SUM(sales) OVER (PARTITION BY country ORDER BY year));

 

rem  Beacuse the MODEL clause is so flexible it is possible to use it instead
rem  of/as a replacement for existing SQL functions/features
rem
rem  We can use MODEL clause to calculate/derive totals/sub-totals in the same
rem  way that CUBE-ROLLUP work but in this case we need to directly
rem  specify the values that we want to compute and how they are 
rem  computed

SELECT 
  SUBSTR(country, 1, 20) country,
  SUBSTR(product, 1, 15) product,
  year,
  sales
FROM sales_view
WHERE country IN ('Italy', 'Japan') 
AND product IN ('Bounce', 'Y Box')
MODEL
PARTITION BY (country) DIMENSION BY (product, year)
MEASURES (sales sales)
RULES
(sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000],
 sales['Y Box', 2002] = sales['Y Box', 2001],
 sales['All_Products', 2002] = sales['Bounce', 2002] + sales['Y Box', 2002]) 
ORDER BY country, product, year;

rem  one of the issues here is that you need to be careful with the ordering of the
rem  ouptut set. In this case the derived total for 'All Products' appears as the first product
rem  which may or may not be the correct position but the ordering is determined by the
rem  final ORDER BY clause.

rem  we can create a LAG calculation using the following syntax:
rem

SELECT 
  SUBSTR(country, 1, 20) country,
  SUBSTR(product, 1, 15) product,
  year,
  sales,
  new_sales
FROM sales_view
WHERE country IN ('Italy', 'Japan') 
AND product IN ('Bounce', 'Y Box')
MODEL
PARTITION BY (product) DIMENSION BY (country, year)
MEASURES (sales, 0 AS new_sales)
RULES 
(new_sales[country IS ANY, year BETWEEN 2000 AND 2003] ORDER BY year = 1.05 * sales[CV(country), CV(year)-1])
ORDER BY country, product, year;

