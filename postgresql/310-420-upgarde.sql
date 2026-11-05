/* 

#log on to server as rds super-user and create new database with extensions and alter owner to geonetwork

psql -h [RDS server address] -p 5432 -U [RDS super-user] -W -d [3.10.x database]

create database geonetwork423
create database geohealthcheck423
\c geonetwork423
create extension postgis
create extension hstore


alter database geonetwork423 owner to geonetwork
alter database geohealthcheck423 owner to geonetwork

# run audit script

psql -h [RDS server address] -p 5432 -U [RDS super-user] -W -d geonetwork423 -q -f ./postgresql/audit.sql

# dump and restore custom and public schemas

pg_dump --schema=public -h [RDS server address] -U geonetwork -W -F custom -v [3.10.x database] > geonetwork310.dump
pg_dump --schema=custom -h [RDS server address] -U geonetwork -W -F custom -v [3.10.x database] > geonetwork310custom.dump
pg_restore -h [RDS server address] -d geonetwork423 -F custom -U geonetwork -v geonetwork310.dump
pg_restore -h [RDS server address] -d geonetwork423 -F custom -U geonetwork -v geonetwork310custom.dump

# create new read-only role for zeppelin and grant select and usage privileges on all three schemas and their tables

create role geonetworkdbfro423 with login encrypted password '[redacted]';
grant usage on schema public to geonetworkdbfro423;
grant usage on schema audit to geonetworkdbfro423;
grant usage on schema custom to geonetworkdbfro423;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO geonetworkdbfro423;
GRANT SELECT ON ALL TABLES IN SCHEMA custom TO geonetworkdbfro423;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO geonetworkdbfro423;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO geonetworkdbfro423;
ALTER DEFAULT PRIVILEGES IN SCHEMA custom GRANT SELECT ON TABLES TO geonetworkdbfro423;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO geonetworkdbfro423;

# re-connect to new database as geonetwork user and run the commands below to help update database from 3.10 to 4.2

psql -h [RDS server address] -p 5432 -U geonetwork -W -d geonetwork423

*/


/* get rid of stuff relating to the dcat schema and password enforcement */
delete from validation where metadataid in (select id from metadata where schemaid = 'dcat-ap');
delete from metadata where schemaid = 'dcat-ap';
delete from statusvaluesdes where iddes = 63;
delete from statusvalues where id = 63;
delete from settings where name like '%passwordEnforcement%';

/* update to use new names for Gemini 2.3 schematron files */
delete from schematroncriteria where group_schematronid in (select id from schematron where schemaname = 'dcat-ap');
delete from schematroncriteriagroup where schematronid in (select id from schematron where schemaname = 'dcat-ap');
delete from schematrondes where label like '%dcat%';
delete from schematron where schemaname = 'dcat-ap';
delete from schematrondes where label = 'schematron-rules-GEMINI_2.3_Schema-v1.0';
delete from schematrondes where label = 'schematron-rules-GEMINI_2.3_supp-v1.0';
update validation set valtype = 'schematron-rules-GEMINI_23_supp_v10' where valtype = 'schematron-rules-GEMINI_2.3_supp-v1.0';
update validation set valtype = 'schematron-rules-GEMINI_23_v10' where valtype = 'schematron-rules-GEMINI_2.3_Schema-v1.0';
delete from schematroncriteria where group_schematronid in (select id from schematron where filename in ('schematron-rules-GEMINI_2.3_supp-v1.0.xsl','schematron-rules-GEMINI_2.3_Schema-v1.0.xsl'));
delete from schematroncriteriagroup where schematronid in (select id from schematron where filename in ('schematron-rules-GEMINI_2.3_supp-v1.0.xsl','schematron-rules-GEMINI_2.3_Schema-v1.0.xsl'));
delete from schematron where filename in ('schematron-rules-GEMINI_2.3_supp-v1.0.xsl','schematron-rules-GEMINI_2.3_Schema-v1.0.xsl');


/* (re)start geonetwork

select * from settings where name like '%version%';
+-------------------------+-------+----------+----------+----------+-----------+----------+
| name                    | value | datatype | position | internal | encrypted | editable |
|-------------------------+-------+----------+----------+----------+-----------+----------|
| system/platform/version | 4.0.1 | 0        | 150      | n        | n         | y        |
+-------------------------+-------+----------+----------+----------+-----------+----------+

after one failed run where it gets to 4.0.1 but then fails with an error about guf_userfeedbacks: */

UPDATE Settings SET value = 'Etc/UTC' WHERE name = 'system/server/timeZone' AND VALUE = '';
UPDATE Settings SET value='4.0.2' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

/* restart geonetwork

select * from settings where name like '%version%';
+-------------------------+-------+----------+----------+----------+-----------+----------+
| name                    | value | datatype | position | internal | encrypted | editable |
|-------------------------+-------+----------+----------+----------+-----------+----------|
| system/platform/version | 4.2.3 | 0        | 150      | n        | n         | y        |
+-------------------------+-------+----------+----------+----------+-----------+----------+*/