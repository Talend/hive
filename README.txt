============
to (re)create the jar hive-exec-shaded-2.1.1-cdh6.1:
clone this repo
switch to the branch create_hive_shaded_jar
go into the ql folder and simply do a mvn clean install -DskipTests (it's just a shade, no code has been modified)
you might need to have a clean m2 since most of studio's dependencies aren't that clean
============


Apache Hive (TM) @VERSION@


General Info
============

For the latest information about Hive, please visit out website at:

  http://hive.apache.org/


Getting Started
===============

- Installation Instructions and a quick tutorial:
  https://cwiki.apache.org/confluence/display/Hive/GettingStarted

- A longer tutorial that covers more features of HiveQL:
  https://cwiki.apache.org/confluence/display/Hive/Tutorial

- The HiveQL Language Manual:
  https://cwiki.apache.org/confluence/display/Hive/LanguageManual


Requirements
============

- Java 1.7 or 1.8

- Hadoop 1.x, 2.x (2.x required for Hive 2.x)


Upgrading from older versions of Hive
=====================================

- Hive @VERSION@ includes changes to the MetaStore schema. If
  you are upgrading from an earlier version of Hive it is imperative
  that you upgrade the MetaStore schema by running the appropriate
  schema upgrade scripts located in the scripts/metastore/upgrade
  directory.

- We have provided upgrade scripts for MySQL, PostgreSQL, Oracle,
  Microsoft SQL Server, and Derby databases. If you are using a
  different database for your MetaStore you will need to provide
  your own upgrade script.

Useful mailing lists
====================

1. user@hive.apache.org - To discuss and ask usage questions. Send an
   empty email to user-subscribe@hive.apache.org in order to subscribe
   to this mailing list.

2. dev@hive.apache.org - For discussions about code, design and features.
   Send an empty email to dev-subscribe@hive.apache.org in order to
   subscribe to this mailing list.

3. commits@hive.apache.org - In order to monitor commits to the source
   repository. Send an empty email to commits-subscribe@hive.apache.org
   in order to subscribe to this mailing list.
