-- Table CDH_VERSION for classes [org.apache.hadoop.hive.metastore.model.MVersionTable]
CREATE TABLE CDH_VERSION
(
    VER_ID bigint NOT NULL,
    SCHEMA_VERSION nvarchar(127) NOT NULL,
    VERSION_COMMENT nvarchar(255) NOT NULL
);

ALTER TABLE CDH_VERSION ADD CONSTRAINT CDH_VERSION_PK PRIMARY KEY (VER_ID);

INSERT INTO CDH_VERSION (VER_ID, SCHEMA_VERSION, VERSION_COMMENT)
SELECT VER_ID, SCHEMA_VERSION_V2, VERSION_COMMENT
FROM VERSION WHERE VER_ID=1;

ALTER TABLE VERSION DROP COLUMN SCHEMA_VERSION_V2;
