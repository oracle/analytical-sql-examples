<h2>Analytical SQL Examples</h2>

<h3>Purpose</h3>

This tutorial covers the analytical SQL features that are part of Oracle Database 12c. The key benefits provided by Oracle’s in-database analytical functions and features are:
<ol>
<li>Enhanced Developer Productivity - enable developers to perform complex analyses with much clearer and more concise SQL code. Complex tasks can now be expressed using single SQL statement which is quicker to formulate and maintain, resulting in greater productivity.</li>
<li>Improved Query Speed - processing optimizations supported by in-database analytics enable significantly better query performance. Actions which before required self-joins or complex procedural processing may now be performed in native SQL.</li>
<li>Improved Manageability - ability to access a consolidated view of all data types and sources is simplified when applications share a common relational environment rather than a mix of calculation engines with incompatible data structures.</li>
<li>Minimized Learning Effort - SQL analytic functions minimize the need to learn new keywords because the syntax leverages existing well-understood keywords.</li>
<li>Industry standards based syntax - Oracle's features conform to ANSI SQL standard and are supported by a large number of independent software vendors.</li>
</ol>

<h3>Time to Complete</h3>
Approximately 60 minutes.

<h3>Hardware and Software Requirements</h3>
- Requires Oracle Database 12c

<h3>Use Cases</h3>
Most common analytical report is to show top five by products within each product group/category:

 - Total sales for each product
 - Totals sales for each product category
 - Percentage sold of the total sales within category
 - Total sales last year for each product
 - Totals sales last year for each product category
 - Percentage variance current year vs. last year

these analytical reports use the following functions:
 - SUM()
 - RANK/ DENSE_RANK
 - RATIO_TO_REPORT
 - LAG
 - VARIANCE

Pick line items to fulfill and order based on FIFO/LIFO model where items are stored in multiple warehouses:
 - SUM()
 - OVER (PARTITION BY . . . ORDER BY . . .)

Forecast sales for following year based on trends from previous years to create targets for next sales year. Extend sales from prior year using the regression slope to compute next year’s sales target
 - SUM()
 - REGR_SLOPE to compute trend lines
 - RANGE window to create moving trend calculation

Predicting stock-out events such as:
 - Alcohol sales always peak around major sporting events
 - Deliveries to stores are usually restricted to specific times during day
 - Need to accurately predict if and when a store run out of stock

Trend existing sales or SUM() on budgeted sales data forward
 - Cumulative running total
 - Using FIFO pick point-in-time when SUM() predicted sales exceeds stock

and for long term events (World Cup, Olympics etc)
 - MODEL clause to test run repeated re-stocks


	
<h3>Analytical SQL Part 1</h3>

This script introduces you to some of the basic concepts of analytical SQL. This section explores some of the the basic concepts behind analytic SQL

 - PARTITION BY . . .   not to be confused with the database partitioning option
 - ORDER BY . . .
 - WINDOWS . . .

Enable you to understand how and where to use analytic SQL in your projects.

<h4>Analytical Functions</h4>
First script creates a total report for sales within a specific product category. Next step is to add an analytical function to generate a running total.Subsquent code explains how to achieve the same result by using sub-query to generate the required totals. You should compare the explain plan for both approaches.

<h4>Using PARTITION BY clause...</h4>
Creates groupings within result set
 - Argument can contain multiple columns in a comma separated list
 - Analytic function acts on each group independently
 - Works in the similar way to GROUP BY clause 

