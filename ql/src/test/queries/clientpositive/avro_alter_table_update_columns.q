-- verify schema changes introduced in avro.schema.literal/url sync with HMS if ALTER TABLE UPDATE COLUMNS is called

CREATE TABLE avro_extschema_literal
 STORED AS AVRO
 TBLPROPERTIES ('avro.schema.literal'='{
  "namespace": "org.apache.hive",
  "name": "ext_schema",
  "type": "record",
  "fields": [
    { "name":"number", "type":"int" },
    { "name":"first_name", "type":"string" },
    { "name":"last_name", "type":"string" }
  ] }');
DESCRIBE avro_extschema_literal;

ALTER TABLE avro_extschema_literal SET
 TBLPROPERTIES ('avro.schema.literal'='{
  "namespace": "org.apache.hive",
  "name": "ext_schema",
  "type": "record",
  "fields": [
    { "name":"newCol", "type":"int" }
  ] }');
DESCRIBE avro_extschema_literal;

ALTER TABLE avro_extschema_literal UNSET TBLPROPERTIES ('avro.schema.literal');
DESCRIBE avro_extschema_literal;

ALTER TABLE avro_extschema_literal SET
 TBLPROPERTIES ('avro.schema.literal'='{
  "namespace": "org.apache.hive",
  "name": "ext_schema",
  "type": "record",
  "fields": [
    { "name":"newCol", "type":"int" }
  ] }');
ALTER TABLE avro_extschema_literal UPDATE COLUMNS CASCADE;
DESCRIBE avro_extschema_literal;

ALTER TABLE avro_extschema_literal UNSET TBLPROPERTIES ('avro.schema.literal');
DESCRIBE avro_extschema_literal;

dfs -cp ${system:hive.root}data/files/grad.avsc ${system:test.tmp.dir}/gradalter.avsc;
dfs -cp ${system:hive.root}data/files/grad2.avsc ${system:test.tmp.dir}/;


CREATE TABLE avro_extschema_url
 STORED AS AVRO
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/gradalter.avsc');
DESCRIBE avro_extschema_url;

ALTER TABLE avro_extschema_url SET
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/grad2.avsc');
DESCRIBE avro_extschema_url;

ALTER TABLE avro_extschema_url UNSET TBLPROPERTIES ('avro.schema.url');
DESCRIBE avro_extschema_url;


ALTER TABLE avro_extschema_url SET
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/grad2.avsc');
ALTER TABLE avro_extschema_url UPDATE COLUMNS CASCADE;
DESCRIBE avro_extschema_url;

ALTER TABLE avro_extschema_url UNSET TBLPROPERTIES ('avro.schema.url');
DESCRIBE avro_extschema_url;



--testing partition level and non-cascade options

CREATE TABLE avro_extschema_url_parted
 PARTITIONED BY (p1 string, p2 string)
 STORED AS AVRO
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/gradalter.avsc');
ALTER TABLE avro_extschema_url_parted
 ADD PARTITION (p1=2017, p2=11);
ALTER TABLE avro_extschema_url_parted
 ADD PARTITION (p1=2018, p2=2);
ALTER TABLE avro_extschema_url_parted
 ADD PARTITION (p1=2018, p2=3);

DESCRIBE avro_extschema_url_parted;

--case: partial partition spec
ALTER TABLE avro_extschema_url_parted SET
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/grad2.avsc');
ALTER TABLE avro_extschema_url_parted PARTITION (p1=2018) UPDATE COLUMNS;
ALTER TABLE avro_extschema_url_parted UNSET TBLPROPERTIES ('avro.schema.url');

DESCRIBE avro_extschema_url_parted;
DESCRIBE avro_extschema_url_parted PARTITION (p1=2017, p2=11);
DESCRIBE avro_extschema_url_parted PARTITION (p1=2018, p2=2);
DESCRIBE avro_extschema_url_parted PARTITION (p1=2018, p2=3);


--case: full partition spec
ALTER TABLE avro_extschema_url_parted SET
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/grad2.avsc');
ALTER TABLE avro_extschema_url_parted PARTITION (p1=2017, p2=11) UPDATE COLUMNS;
ALTER TABLE avro_extschema_url_parted UNSET TBLPROPERTIES ('avro.schema.url');

DESCRIBE avro_extschema_url_parted;
DESCRIBE avro_extschema_url_parted PARTITION (p1=2017, p2=11);
DESCRIBE avro_extschema_url_parted PARTITION (p1=2018, p2=2);
DESCRIBE avro_extschema_url_parted PARTITION (p1=2018, p2=3);

--case: table with restrict (no cascade)
ALTER TABLE avro_extschema_url_parted SET
 TBLPROPERTIES ('avro.schema.url'='${system:test.tmp.dir}/grad2.avsc');
ALTER TABLE avro_extschema_url_parted UPDATE COLUMNS;
ALTER TABLE avro_extschema_url_parted UNSET TBLPROPERTIES ('avro.schema.url');

DESCRIBE avro_extschema_url_parted;
DESCRIBE avro_extschema_url_parted PARTITION (p1=2017, p2=11);
DESCRIBE avro_extschema_url_parted PARTITION (p1=2018, p2=2);
DESCRIBE avro_extschema_url_parted PARTITION (p1=2018, p2=3);