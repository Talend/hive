SET hive.exec.schema.evolution=true;

-- Currently, string to int conversion is not supported because it isn't in the lossless
-- TypeIntoUtils.implicitConvertible conversions.
create table src_orc (key string, val string) stored as orc;
set metaconf:hive.metastore.disallow.incompatible.col.type.changes=true;
alter table src_orc change key key int;
