CREATE TABLE TEST3a(A INT, B DOUBLE) STORED AS TEXTFILE; 
DESCRIBE TEST3a; 
CREATE TABLE TEST3b(A ARRAY<INT>, B DOUBLE, C MAP<DOUBLE, INT>) STORED AS TEXTFILE; 
DESCRIBE TEST3b; 
SHOW TABLES LIKE "TEST3*";
EXPLAIN
ALTER TABLE TEST3b ADD COLUMNS (X DOUBLE);
ALTER TABLE TEST3b ADD COLUMNS (X DOUBLE);
DESCRIBE TEST3b; 
EXPLAIN
ALTER TABLE TEST3b RENAME TO TEST3c;
ALTER TABLE TEST3b RENAME TO TEST3c;
DESCRIBE TEST3c; 
SHOW TABLES LIKE "TEST3*";
set hive.metastore.disallow.incompatible.col.type.changes=false;
EXPLAIN
ALTER TABLE TEST3c REPLACE COLUMNS (R1 INT, R2 DOUBLE);
ALTER TABLE TEST3c REPLACE COLUMNS (R1 INT, R2 DOUBLE);
reset hive.metastore.disallow.incompatible.col.type.changes;
DESCRIBE EXTENDED TEST3c;
