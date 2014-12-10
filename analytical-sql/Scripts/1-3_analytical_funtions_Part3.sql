rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

/* Part 3 - Statistical Features

Included in Oracle 12c Database is a compelling array of statistical functions accessible from through SQL. 
These include descriptive statistics, hypothesis testing, correlations analysis, test for distribution fit, 
cross tabs with Chi-square statistics, and analysis of variance (ANOVA). 

Below are some basic scripts that explain how to use these features:


*/

select
       prod_category_desc,
       min(prod_list_price)                                           "Min.", 
       percentile_cont(0.25) within group (order by prod_list_price)  "1st Qu.", 
       trunc(median(prod_list_price),2)                               "Median", 
       trunc(avg(prod_list_price),2)                                  "Mean", 
       percentile_cont(0.75) within group (order by prod_list_price)  "3rd Qu.", 
       max(prod_list_price)                                           "Max.", 
       count(*) - count(prod_list_price)                              "NA's"
from products
GROUP BY prod_category_desc; 





select /*+ parallel(5) */ 
       prod_category_desc,
       min(prod_list_price)                                             "Min.", 
       percentile_cont(0.25) within group (order by prod_list_price)    "1st Qu.", 
       trunc(median(prod_list_price),2)                                 "Median", 
       trunc(avg(prod_list_price),2)                                    "Mean", 
       percentile_cont(0.75) within group (order by prod_list_price)    "3rd Qu.", 
       max(prod_list_price)                                             "Max.", 
       count(*) - count(prod_list_price)                                "NA's", 
       min(prod_weight_class)                                           "Min.", 
       percentile_cont(0.25) within group (order by prod_weight_class)  "1st Qu.", 
       trunc(median(prod_weight_class),2)                               "Median", 
       trunc(avg(prod_weight_class),2)                                  "Mean", 
       percentile_cont(0.75) within group (order by prod_weight_class)  "3rd Qu.", 
       max(prod_weight_class)                                           "Max.", 
       count(*) - count(prod_weight_class)                              "NA's" 
from products
GROUP BY prod_category_desc; 


rem  The following example determines the significance of the difference between the average sales to men and women 
rem  where the distributions are known to have significantly different (unpooled) variances: 

SELECT 
    SUBSTR(cust_income_level, 1, 22) income_level, 
    TRUNC(AVG(DECODE(cust_gender, 'M', amount_sold, null)),2) sold_to_men, 
    TRUNC(AVG(DECODE(cust_gender, 'F', amount_sold, null)),2) sold_to_women, 
    TRUNC(STATS_T_TEST_INDEPU(cust_gender, amount_sold, 'STATISTIC', 'F'),4) t_observed, 
    TRUNC(STATS_T_TEST_INDEPU(cust_gender, amount_sold),4) two_sided_p_value 
FROM sh.customers c, sh.sales s 
WHERE c.cust_id = s.cust_id 
GROUP BY ROLLUP(cust_income_level) 
ORDER BY income_level; 