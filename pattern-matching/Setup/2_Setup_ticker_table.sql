rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Readme for SQL pattern matching scripts
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem  ****************************************************************
rem


connect pmuser/pmuser;

set echo off
drop table ticker purge;

CREATE TABLE ticker (SYMBOL VARCHAR2(10), tstamp DATE, price NUMBER);

-- Populates the ticker table with some data
-- data for ACME identical to data in documentation and OBE. do not change
-- additional artificial tickers OSCORP and GLOBEX in the works

INSERT INTO ticker VALUES('GLOBEX', '01-Apr-11', 3);
INSERT INTO ticker VALUES('OSCORP', '01-Apr-11', 22);
INSERT INTO ticker VALUES('ACME', '01-Apr-11', 12);

INSERT INTO ticker VALUES('OSCORP', '02-Apr-11', 22);
INSERT INTO ticker VALUES('GLOBEX', '02-Apr-11', 7);
INSERT INTO ticker VALUES('ACME', '02-Apr-11', 17);

INSERT INTO ticker VALUES('ACME', '03-Apr-11', 19);
INSERT INTO ticker VALUES('OSCORP', '03-Apr-11', 19);
INSERT INTO ticker VALUES('GLOBEX', '03-Apr-11', 8);

INSERT INTO ticker VALUES('ACME', '04-Apr-11', 21);
INSERT INTO ticker VALUES('GLOBEX', '04-Apr-11', 4);
INSERT INTO ticker VALUES('OSCORP', '04-Apr-11', 18);

INSERT INTO ticker VALUES('OSCORP', '05-Apr-11', 17);
INSERT INTO ticker VALUES('GLOBEX', '05-Apr-11', 8);
INSERT INTO ticker VALUES('ACME', '05-Apr-11', 25);

INSERT INTO ticker VALUES('ACME', '06-Apr-11', 12);
INSERT INTO ticker VALUES('OSCORP', '06-Apr-11', 20);
INSERT INTO ticker VALUES('GLOBEX', '06-Apr-11', 9);

INSERT INTO ticker VALUES('ACME', '07-Apr-11', 15);
INSERT INTO ticker VALUES('OSCORP', '07-Apr-11', 17);
INSERT INTO ticker VALUES('GLOBEX', '07-Apr-11', 6);

INSERT INTO ticker VALUES('GLOBEX', '08-Apr-11', 8);
INSERT INTO ticker VALUES('ACME', '08-Apr-11', 20);
INSERT INTO ticker VALUES('OSCORP', '08-Apr-11', 20);

INSERT INTO ticker VALUES('GLOBEX', '09-Apr-11', 11);
INSERT INTO ticker VALUES('ACME', '09-Apr-11', 24);
INSERT INTO ticker VALUES('OSCORP', '09-Apr-11', 16);

INSERT INTO ticker VALUES('OSCORP', '10-Apr-11', 15);
INSERT INTO ticker VALUES('GLOBEX', '10-Apr-11', 8);
INSERT INTO ticker VALUES('ACME', '10-Apr-11', 25);

INSERT INTO ticker VALUES('OSCORP', '11-Apr-11', 15);
INSERT INTO ticker VALUES('GLOBEX', '11-Apr-11', 10);
INSERT INTO ticker VALUES('ACME', '11-Apr-11', 19);

INSERT INTO ticker VALUES('ACME', '12-Apr-11', 15);
INSERT INTO ticker VALUES('OSCORP', '12-Apr-11', 12);
INSERT INTO ticker VALUES('GLOBEX', '12-Apr-11', 9);

INSERT INTO ticker VALUES('ACME', '13-Apr-11', 25);
INSERT INTO ticker VALUES('GLOBEX', '13-Apr-11', 7);
INSERT INTO ticker VALUES('OSCORP', '13-Apr-11', 11);

INSERT INTO ticker VALUES('ACME', '14-Apr-11', 25);
INSERT INTO ticker VALUES('GLOBEX', '14-Apr-11', 11);
INSERT INTO ticker VALUES('OSCORP', '14-Apr-11', 10);

INSERT INTO ticker VALUES('GLOBEX', '15-Apr-11', 12);
INSERT INTO ticker VALUES('OSCORP', '15-Apr-11', 9);
INSERT INTO ticker VALUES('ACME', '15-Apr-11', 14);

INSERT INTO ticker VALUES('GLOBEX', '16-Apr-11', 9);
INSERT INTO ticker VALUES('OSCORP', '16-Apr-11', 8);
INSERT INTO ticker VALUES('ACME', '16-Apr-11', 12);

INSERT INTO ticker VALUES('ACME', '17-Apr-11', 14);
INSERT INTO ticker VALUES('OSCORP', '17-Apr-11', 7);
INSERT INTO ticker VALUES('GLOBEX', '17-Apr-11', 7);

INSERT INTO ticker VALUES('ACME', '18-Apr-11', 24);
INSERT INTO ticker VALUES('OSCORP', '18-Apr-11', 6);
INSERT INTO ticker VALUES('GLOBEX', '18-Apr-11', 7);

INSERT INTO ticker VALUES('ACME', '19-Apr-11', 23);
INSERT INTO ticker VALUES('GLOBEX', '19-Apr-11', 10);
INSERT INTO ticker VALUES('OSCORP', '19-Apr-11', 7);

INSERT INTO ticker VALUES('GLOBEX', '20-Apr-11', 5);
INSERT INTO ticker VALUES('OSCORP', '20-Apr-11', 8);
INSERT INTO ticker VALUES('ACME', '20-Apr-11', 22);

commit;

CREATE OR REPLACE VIEW ticker_a AS SELECT * FROM ticker WHERE symbol='ACME';
CREATE OR REPLACE VIEW ticker_o AS SELECT * FROM ticker WHERE symbol='OSCORP';
CREATE OR REPLACE VIEW ticker_g AS SELECT * FROM ticker WHERE symbol='GLOBEX';
