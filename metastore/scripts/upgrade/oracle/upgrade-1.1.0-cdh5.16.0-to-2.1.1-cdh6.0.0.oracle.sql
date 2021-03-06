SELECT 'Upgrading MetaStore schema from 1.1.0 to 2.1.1' AS Status from dual;

-- Upgrading schema from 1.1.0 to 2.0.0 excluding patches included in CDH-5.12.0. There are no patches from 1.1.0 to 1.2.0
@upgrade-1.1.0-to-1.2.0.oracle.sql;

-- Upgrading schema from 2.0.0 to 2.1.1 excluding patches included in CDH-5.12.0.
@upgrade-1.2.0-to-2.0.0.oracle.sql;
@upgrade-2.0.0-to-2.1.0.oracle.sql;

-- Apply incremental schema changes to the 2.1.0 schema
@039-HIVE-12274.oracle.sql;
@018-HIVE-6757.oracle.sql;
@049-HIVE-18489.oracle.sql;

UPDATE VERSION SET SCHEMA_VERSION='2.1.1', VERSION_COMMENT='Hive release version 2.1.1' where VER_ID=1;
UPDATE CDH_VERSION SET SCHEMA_VERSION='2.1.1-cdh6.0.0', VERSION_COMMENT='Hive release version 2.1.1 for CDH 6.0.0' where VER_ID=1;
SELECT 'Finished upgrading MetaStore schema from 1.1.0 to 2.1.1' AS Status from dual;
