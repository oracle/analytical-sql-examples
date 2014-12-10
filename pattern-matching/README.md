<!--
rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Readme for SQL pattern matching scripts
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem  ****************************************************************
rem
-->

<h2>SQL Pattern Matching Examples</h2>

<h3>Prerequisites</h3>

- Have access to Oracle Database 12c with SYS user with SYSDBA privilege and OS authentication (so that you can execute the sqlplus / as sysdba command.)
- Examples create additional tables and views within the PMUSER user schema. 
- Have downloaded and the SQL scripts (which is in the Scripts subdirectory of this tutorial) into a working directory.
- Navigate to your working directory and execute all files from that location.
- Execute the tutorial setup which requires access to the PMUSER user.


<h3>Assumptions</h3>
This tutorial assumes the following:

1 - you have run all the associated setup scripts (contained in the Setup folder) before trying to execute any of the SQL scripts. The SQL commands incementally add new features and functions, however, it is not necessary to complete/run each script. Each script works in isolation so you do need to work through an entire topic before going to another one. 




<h3>Purpose</h3>
This tutorial covers the new 12c SQL pattern matching feature. This new inter-row pattern search capability complements the already existing capabilities of regular expressions that match patterns within character strings of a single record. The 12c MATCH_RECOGNIZE feature allows the definition of patterns, in terms of characters or sets of characters, and provides the ability to search for those patterns across row boundaries.

<h3>Overview of keywords used in the pattern matching</h3>This section provides an overview of the most important keywords that make up the MATCH_RECOGNIZE clause and the keywords are organized according to the four steps outlined above.
<h4>Step 1: Bucket and order the data</h4>The bucketing and ordering of data are controlled by the keywords “PARTITION BY” and “ORDER BY”.
PARTITION BY - This clause divides the data into logical groups so that you can search within each group for the required pattern. “PARTITION BY” is an optional clause and is typically followed by the “ORDER BY“ claus. The order of the data is very important as this controls the “visibility” of the pattern we are searching for within the data set. The MATCH_RECOGNIZE feature uses the ORDER BY clause to organize the data so that it is possible to test across row boundaries for the existence of a sequence of rows within the overall “stream of events”:<h4>Step 2: Define the pattern</h4>The PATTERN clause makes use of regular expressions to define the criteria for a specific pattern (or patterns). The subsequent syntax clause DEFINE is used to define the associated pattern variables. PATTERN - In this section you define three basic elements:  - the pattern variables that must be matched - the sequence in which they must be matched - the frequency of patterns that must be matchedThe PATTERN clause depends on pattern variables which means you must have a clause to define these variables and this is done using the DEFINE clause. It is a required clause and is used to specify the conditions that a row must meet to be mapped to a specific pattern variable.  <h4>Step 3: Define the measures</h4>This section allows you to define the output measures that are derived from the evaluation of an expression or calculated by evaluating an expression related to a particular match. Measures can be individual data points within a pattern such as start or end values, aggregations of the event row set such as average or count, or SQL pattern matching specific values such as a pattern variable identifier. Note that it is important to look at the measures in the context of how to retrieve the rows that match the specified pattern since there could be multiple occurrences of an event within a pattern. For example, in the pattern above there could be multiple DOWN events before the bottom of the V is reached. Therefore, the developer needs to determine which event they want to include in the output – the first, last, minimum or maximum value. It is important to be very precise when defining measures to ensure the correct, or expected, element is returned.<h4>Step 4: Controlling the output</h4>When patterns are identified in streams of rows you sometimes want the ability to report summary information (for each pattern) in other cases you will need to report the detailed information. The ability to generate summaries as part of this process is very important. The “PER MATCH” clause can create either summary data or detailed data about the matches and these two types of output are controlled by the following key phrases:

 - ONE ROW PER MATCH - each match produces one summary row and this is the default. - ALL ROWS PER MATCH - a match spanning multiple rows will produce one output row for each row in the match.<h3>Setup</h3>

Set up the tutorial by running the following scripts. These scripts do not form part of the tutorial, they create the PMUSER additional tables and views used by the scripts.

 - 1_create_PM_user.sql
 - 2_Setup_ticker_table.sql
 - 3_Setup_sessionization.sql


<h3>Exercises</h3>

There is an additional readme.md file in the "Scripts" directory that will provide you with more information about how to run each set of examples.

