rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Readme for SQL pattern matching scripts
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem  ****************************************************************
rem


connect / as sysdba;
-- creating user pmuser for pattern matching workshop…in database NONCDB'

DROP USER pmuser CASCADE;
CREATE USER pmuser IDENTIFIED BY pmuser;
ALTER USER pmuser DEFAULT TABLESPACE users QUOTA 20M ON users TEMPORARY TABLESPACE temp;
GRANT CONNECT TO pmuser;
GRANT RESOURCE TO pmuser;
GRANT DBA TO pmuser;

--- 'finished creating user pmuser'
--- 'You should now run setup.sql'