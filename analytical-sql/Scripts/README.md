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
Script: 1-1_analytical_funtions.sql

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

<h4>Using ORDER BY clause...</h4>
Optional clause, warning – if you omit an optional clause/keyword make sure results are what you were expecting.
Majority of SQL statements will include ORDER BY keyword within the OVER() clause. If omitted then data is automatically aggregated within each PARTITION
 1. Defines the order of rows to be processed by the calculation
 2. Defines the default window	
   - Sub-grouping of rows within the main block
   - Default window is the current row + all previous rows

<h4>Using windows...</h4>
Gives you more control over the processing within the analytic function. Defines the start row and the end row for processing within each partition/group. Sophisticate set of keywords
 - RANGE, INTERVAL DAY/MONTH/YEAR, UNBOUNDED, PRECEDING, FOLLOWING, CURRENT ROW

Used to compute cumulative, moving, and centered aggregates. Two types of window:
 - Physical
 - Logical

Similar in concept to the WHERE clause

<h4>Sort optimizations...</h4>
 - Number of sorts is minimized via the notion of “Ordering Groups”
 - An ordering group is a set of analytic functions which can be evaluated with a single sort
 - A minimal set of ordering groups is found which in turn minimizes the number of sorts

<h3>Analytical SQL Part 2</h3>
Scipt: 1-2_analytical_funtions_Part2.sql

<h4>Ranking data...</h4>
Ranking of data to find top 10 or bottom 10 is a common requirement. RANK() can be used in a similar way to other analytical aggregates such as SUM(), COUNT(), AVG() etc. We can create rankings across the whole data set or within each specific partition/group.

<h4>Using LAG/LEAD...</h4>
LAG/LEAD functions provides access to several rows at the same time. Allows comparison of different portions of a table without a self join. Functions operate on an ordered set of data. Allow access to a row at a fixed offset from the current row.

<h4>Ratio to report</h4> 
Ratio_to_report is another useful function. It computes the ratio of a value to the sum of a set of values. The PARTITION BY clause defines the groups on which the RATIO_TO_REPORT function is to be computed. If the PARTITION BY clause is absent, then the function is computed over the whole query result set. In this example the grouping is based on quarters so you get each months value as ration of the total for the specific quarter.


<h3>Analytical SQL Part 3</h3>
Script: 1-3_analytical_funtions_Part3.sql

Included in Oracle 12c Database is a compelling array of statistical functions accessible from through SQL. These include descriptive statistics, hypothesis testing, correlations analysis, test for distribution fit, cross tabs with Chi-square statistics, and analysis of variance (ANOVA). 

<h3>Pivoting and Unpivoting Data</h3>
Script: 2_pivoting.sql

This set of commands use the PIVOT and UNPIVOT clauses. The build up the earlier window functions as part of the PIVOT operation by creating a report that shows each product category, its sales and its contribution. It is possible to generate XML output for each product catwegories sales for 1998 Q1, however, note that we are using the xmlserialize function to output the results of the column containing the XML.


<h3>Filtering just the top-N results</h3>
Script: 3_Top-N.sql

Contains the code for running TOP-N queries against the tables/views in the SH schema. The first example shows the rows that make up the worst 20% of product sales during 1999.


<h3>Aggregating hierarchical data</h3>
Script: 4_Cubes_Rollups.sql

Scripts to demonstrate how to use the various rollup features to calculate hierarchical totals within a "cube". This introduces the concepts of dimensions and hierarchies. Using GROUPING SETS it is possible to compute totals for specific groupings of levels within in each dimension. The last part of this script examines how to identify which rows have been calculated by the CUBE/ROLLUP/GROUPING SETS clauses. This functionality is especially useful for application developers who need to populate tables/forms within their application UIs.




