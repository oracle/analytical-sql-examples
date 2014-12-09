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

<h3>Introduction</h3>
The in-database analytical functions features that are embedded inside the Oracle Database can be used to answer a wide variety of business problems. Developers and business users can access a wide range of analytic features and combine their results with other SQL queries and analytical pipelines to gain deeper insights. Oracle's Database includes the following features:
<table>
<tr><td>
<ul><li>Ranking</li>
<li>Windowing</li>
<li>Reporting Aggregates</li>
<li>LAG/LEAD</li>
<li>FIRST/LAST</li>
</ul>
</td><td>
<ul>
<li>Inverse Percentile</li>
<li>Hypothetical Rank and Distribution</li>
<li>Pattern Matching</li>
<li>Modeling</li>
<li>Advanced aggregations</li>
<li>User defined functions</li>
</ul>
</td></tr></table>

<h3>Hardware and Software Requirements</h3>
- Requires Oracle Database 12c

<h3>Prerequisites</h3>

- Have access to Oracle Database 12c with a sample sales history schema, the SYS user with SYSDBA privilege and OS authentication (so that you can execute the sqlplus / as sysdba command.)
- Examples create additional tables and views within the SH user schema. 
- Have downloaded and the SQL scripts (which is in the Scripts subdirectory of this tutorial) into a working directory.
- Navigate to your working directory and execute all files from that location.
- Execute the tutorial setup which requires access to the SH user.


<h3>Assumptions</h3>

- This tutorial assumes that you have run all the setup scripts before trying to execute any of the SQL scripts. The SQL commands incementally add new features and functions, however, it is not necessary to complete/run each script. Each script works in isolation so you do need to work through an entire topic before going to another one. 

<h3>Tutorial Overview</h3>
	
Note that the generated data used in the tutorial is contained within the SH user schema so your query results should match the example output exactly.

The tutorial is broken down into a number of different stages:
- Analytical SQL Part 1
- Analytical SQL Part 2
- Analytical SQL Part 3
- Pivoting and unpivoting data
- Top-N queries
- Aggregating data using cubes and rollups
- SQL Pattern matching
- Using the SQL MODEL clause

<h3>Setup</h3>

Set up the tutorial by running the following scripts. These scripts do not form part of the tutorial, they create additional tables and views used by the scripts.

- 1-0_setup.sql
- 1-1_Setup_analytical_funtions.sql
- 1-2_Setup_Cubes_Rollups.sql
- 1-3_pivoting_setup.sql

This assumes that you have installed the sales history sample schema which creates the user SH. 

<h3>Exercises</h3>

There is an additional readme.md file in the "Scripts" directory that will provide you with more information about how to run each set of examples.