rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Readme for SQL pattern matching scripts
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem  ****************************************************************
rem


connect pmuser/pmuser

CREATE TABLE clickdata (tstamp integer, userid varchar2(15));

BEGIN

INSERT INTO clickdata VALUES(1, 'Mary');
INSERT INTO clickdata VALUES(2, 'Sam');
INSERT INTO clickdata VALUES(11, 'Mary');
INSERT INTO clickdata VALUES(12, 'Sam');
INSERT INTO clickdata VALUES(22, 'Sam');
INSERT INTO clickdata VALUES(23, 'Mary');
INSERT INTO clickdata VALUES(32, 'Sam');
INSERT INTO clickdata VALUES(34, 'Mary');
INSERT INTO clickdata VALUES(43, 'Sam');
INSERT INTO clickdata VALUES(44, 'Mary');
INSERT INTO clickdata VALUES(47, 'Sam');
INSERT INTO clickdata VALUES(48, 'Sam');
INSERT INTO clickdata VALUES(53, 'Mary');
INSERT INTO clickdata VALUES(59, 'Sam');
INSERT INTO clickdata VALUES(60, 'Sam');
INSERT INTO clickdata VALUES(63, 'Mary');
INSERT INTO clickdata VALUES(68, 'Sam');

commit;

END;

select count(*) from clickdata;

SELECT 
 tstamp,
 userid,
 session_id
FROM clickdata MATCH_RECOGNIZE(         
   PARTITION BY userid ORDER BY tstamp
   MEASURES match_number() as session_id
   ALL ROWS PER MATCH
   PATTERN (b s*)    
   DEFINE
       s as (s.tstamp - prev(s.tstamp) <= 10)
 );



SELECT
 tstamp,
 userid,
 session_id,
 no_of_events,
 start_time,
 session_duration
FROM clickdata MATCH_RECOGNIZE(
   PARTITION BY userid ORDER BY tstamp
   MEASURES match_number() as session_id,
            count(*) as no_of_events,
            first(tstamp) start_time,
            last(tstamp) - first(tstamp) session_duration    
   ALL ROWS PER MATCH
   PATTERN (b s*)    
   DEFINE
       s as (s.tstamp - prev(s.tstamp) <= 10)
 ); 


