rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem  ****************************************************************
rem

rem  scripts to demonstrate how to use MATCH_RECOGNIZE
rem  clause for sql pattern matching
rem

/* Create required tables/views
*/


/* 
Part 1 -
*/

SELECT * FROM Ticker 
MATCH_RECOGNIZE 
(PARTITION BY symbol
 ORDER BY tstamp
 MEASURES 
   STRT.tstamp AS start_tstamp,
   FINAL LAST(DOWN.tstamp) AS bottom_tstamp,
   FINAL LAST(UP.tstamp) AS end_tstamp
 ALL ROW PER MATCH
 AFTER MATCH SKIP TO LAST UP
 PATTERN (STRT DOWN+ UP+)
 DEFINE
    DOWN AS DOWN.price < PREV(DOWN.price),
    UP AS UP.price > PREV(UP.price)) MR


rem  can I filter my results so I only see one ticker?
rem  Yes, note that we reference the MATCH_RECOGNIZE
rem  block with the suffice MR which allows us to interact
rem  the result set that is returned.
 
SELECT * FROM Ticker MATCH_RECOGNIZE
(PARTITION BY symbol
 ORDER BY tstamp
 MEASURES 
    STRT.tstamp AS start_tstamp,
    FINAL LAST(DOWN.tstamp) AS bottom_tstamp,
    FINAL LAST(UP.tstamp) AS end_tstamp,
    MATCH_NUMBER() AS match_num,
    CLASSIFIER() AS var_match
 ONE ROW PER MATCH
 AFTER MATCH SKIP TO LAST UP
 PATTERN (STRT DOWN+ UP+)
 DEFINE
   DOWN AS DOWN.price < PREV(DOWN.price),
   UP AS UP.price > PREV(UP.price)) MR
WHERE symbol='ACME'
ORDER BY MR.symbol, MR.match_num, MR.tstamp;                 



/* 
Part 2 -
*/

rem  lets build another example using sessionization
rem  where we define a sessions as containing group
rem  of clicks that are within 10 seconds of each other

SELECT *
FROM clickdata
MATCH_RECOGNIZE
(MEASURES 
  userid as user_id,
  MATCH_NUMBER() AS session_id,                                   
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,                     
  LAST(tstamp) - FIRST(tstamp) as sess_duration            
 ALL ROWS PER MATCH  
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));
   

rem  what is missing from the above statement?
rem  we need to add in the partition by clause
rem  so is this output correct?


SELECT *
FROM clickdata
MATCH_RECOGNIZE
(PARTITION BY userid 
 MEASURES 
  userid as user_id,
  MATCH_NUMBER() AS session_id,                                   
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,                     
  LAST(tstamp) - FIRST(tstamp) as sess_duration            
 ALL ROWS PER MATCH  
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));
      

rem  what if we want a summary report?
rem  

SELECT *
FROM clickdata
MATCH_RECOGNIZE
(PARTITION BY userid
 ORDER BY tstamp
 MEASURES 
  userid as user_id,
  MATCH_NUMBER() AS session_id,                                   
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,                     
  LAST(tstamp) - FIRST(tstamp) as sess_duration            
 ONE ROW PER MATCH  
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));
   
   
   
   
rem  can we find out how the pattern is being interpreted on each row?   
   
SELECT *
FROM clickdata
MATCH_RECOGNIZE
(PARTITION BY userid
 ORDER BY tstamp
 MEASURES 
  userid as user_id,
  MATCH_NUMBER() AS session_id,                                   
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,                     
  LAST(tstamp) - FIRST(tstamp) as sess_duration            
 ALL ROWsS PER MATCH  
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));
    


rem  makes a little more sense if we go back to our ticker
rem  dataset as this has more variables within the pattern
rem
rem

SELECT * FROM Ticker MATCH_RECOGNIZE 
(PARTITION BY symbol
 ORDER BY tstamp
 MEASURES 
  STRT.tstamp AS start_tstamp,
  FINAL LAST(DOWN.tstamp) AS bottom_tstamp,
  FINAL LAST(UP.tstamp) AS end_tstamp,
  MATCH_NUMBER() AS match_num,
  CLASSIFIER() AS var_match
 ALL ROWS PER MATCH
 AFTER MATCH SKIP TO LAST UP
 PATTERN (STRT DOWN+ UP+)
 DEFINE
 DOWN AS DOWN.price < PREV(DOWN.price),
 UP AS UP.price > PREV(UP.price) ) MR
WHERE symbol='ACME'
ORDER BY MR.symbol, MR.match_num, MR.tstamp;


             

