/* 

# log on to server as rds super-user and create new database with extensions and alter owner to geonetwork

psql -h geonetwork-live.ckezqnsefivr.eu-west-1.rds.amazonaws.com -p 5432 -U geonework -W -d geonetwork38

create database geonetwork425;
\c geonetwork425
create extension postgis;
create extension hstore;

alter database geonetwork425 owner to geonetwork;

# run audit script

psql -h geonetwork-live.ckezqnsefivr.eu-west-1.rds.amazonaws.com -p 5432 -U geonetwork -W -d -v geonetwork425 -q -f ./postgresql/audit.sql

# dump public and custom schemas

pg_dump --schema=public -h geonetwork-live.ckezqnsefivr.eu-west-1.rds.amazonaws.com -p 5432 -U geonetwork -W -F custom -v geonetwork38 > geonetwork38.dump
pg_dump --schema=custom -h geonetwork-live.ckezqnsefivr.eu-west-1.rds.amazonaws.com -p 5432 -U geonetwork -W -F custom -v geonetwork38 > geonetwork38custom.dump

# restore public schema

pg_restore -h localhost -p 5432 -d geonetwork425 -F custom -U geonetwork -v ./postgresql/geonetwork38.dump

# re-connect to new database as geonetwork user and run the commands below to help update database from 3.10 to 4.2

psql -h geonetwork-live.ckezqnsefivr.eu-west-1.rds.amazonaws.com -p 5432 -U geonetwork -W -d geonetwork425

*/

/* update to use new names for Gemini 2.3 schematron files */
delete from schematrondes where label = 'schematron-rules-GEMINI_2.3_Schema-v1.0';
delete from schematrondes where label = 'schematron-rules-GEMINI_2.3_supp-v1.0';
update validation set valtype = 'schematron-rules-GEMINI_23_supp_v10' where valtype = 'schematron-rules-GEMINI_2.3_supp-v1.0';
update validation set valtype = 'schematron-rules-GEMINI_23_v10' where valtype = 'schematron-rules-GEMINI_2.3_Schema-v1.0';
delete from schematroncriteria where group_schematronid in (select id from schematron where filename in ('schematron-rules-GEMINI_2.3_supp-v1.0.xsl','schematron-rules-GEMINI_2.3_Schema-v1.0.xsl'));
delete from schematroncriteriagroup where schematronid in (select id from schematron where filename in ('schematron-rules-GEMINI_2.3_supp-v1.0.xsl','schematron-rules-GEMINI_2.3_Schema-v1.0.xsl'));
delete from schematron where filename in ('schematron-rules-GEMINI_2.3_supp-v1.0.xsl','schematron-rules-GEMINI_2.3_Schema-v1.0.xsl');

/* remove records that appear in metadatastatus table, but not in metadata table

select distinct(metadataid) from metadatastatus where metadataid not in (select id from metadata);

+------------+
| metadataid |
|------------|
| 278        |
| 6626       |
| 6627       |
| 6628       |
| 6629       |
| 6630       |
| 6631       |
| 6632       |
| 6633       |
| 6634       |
| 6635       |
| 6636       |
| 6637       |
| 6638       |
| 6875       |
| 6876       |
+------------+

*/

delete from metadatastatus where metadataid not in (select id from metadata);

/* insert timezone in the settings table */

insert into settings values ('system/server/timeZone', '0', 'y', '260', '');

/* start geonetwork */

/* after one failed run where it still stays on 3.10.11 and fails with an error about page_language column: */

UPDATE Settings SET value='4.0.0' WHERE name='system/platform/version';

/* (re)start geonetwork 

select * from settings where name like '%version%';
+-------------------------+-------+----------+----------+----------+-----------+----------+
| name                    | value | datatype | position | internal | encrypted | editable |
|-------------------------+-------+----------+----------+----------+-----------+----------|
| system/platform/version | 4.2.4 | 0        | 150      | n        | n         | y        |
+-------------------------+-------+----------+----------+----------+-----------+----------+

*/

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/index/indexingTimeRecordLink', 'false', 2, 9209, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/users/identicon', 'gravatar:mp', 0, 9110, 'n');

alter table metadatastatus add column uuid varchar(255);
alter table metadatastatus add column id integer;

/*
UPDATE settings SET name = 'metadata/workflow/allowSubmitApproveInvalidMd'
WHERE name = 'metadata/workflow/allowSumitApproveInvalidMd';

UPDATE settings_ui
  SET  configuration = replace(configuration,
    '"showMapInFacet": true', '"searchMapPlacement": "facets"')
  WHERE configuration LIKE '%"showMapInFacet": true%';

UPDATE settings_ui
  SET  configuration = replace(configuration,
    '"showMapInFacet": false', '"searchMapPlacement": "results"')
  WHERE configuration LIKE '%"showMapInFacet": false%';

-- Update translations for status values
UPDATE StatusValuesDes SET label = 'Entwurf' WHERE iddes = 1 AND langid = 'ger';
UPDATE StatusValuesDes SET label = 'Genehmigt' WHERE iddes = 2 AND langid = 'ger';
UPDATE StatusValuesDes SET label = 'Übermittelt' WHERE iddes = 4 AND langid = 'ger';
UPDATE StatusValuesDes SET label = 'Abgelehnt' WHERE iddes = 5 AND langid = 'ger';

UPDATE StatusValuesDes SET label = 'Luonnos' WHERE iddes = 1 AND langid = 'fin';
UPDATE StatusValuesDes SET label = 'Hyväksytty' WHERE iddes = 2 AND langid = 'fin';
UPDATE StatusValuesDes SET label = 'Poistettu' WHERE iddes = 3 AND langid = 'fin';
UPDATE StatusValuesDes SET label = 'Lähetetty' WHERE iddes = 4 AND langid = 'fin';

UPDATE StatusValuesDes SET label = 'Rascunho' WHERE iddes = 1 AND langid = 'por';
UPDATE StatusValuesDes SET label = 'Aprovado' WHERE iddes = 2 AND langid = 'por';
UPDATE StatusValuesDes SET label = 'Retirado' WHERE iddes = 3 AND langid = 'por';
UPDATE StatusValuesDes SET label = 'Enviado' WHERE iddes = 4 AND langid = 'por';
UPDATE StatusValuesDes SET label = 'Rejeitado' WHERE iddes = 5 AND langid = 'por';

UPDATE StatusValuesDes SET label = 'Borrador' WHERE iddes = 1 AND langid = 'spa';
UPDATE StatusValuesDes SET label = 'Aprobado' WHERE iddes = 2 AND langid = 'spa';
UPDATE StatusValuesDes SET label = 'Retirado' WHERE iddes = 3 AND langid = 'spa';
UPDATE StatusValuesDes SET label = 'Enviado' WHERE iddes = 4 AND langid = 'spa';
UPDATE StatusValuesDes SET label = 'Rechazado' WHERE iddes = 5 AND langid = 'spa';


UPDATE Settings SET value='4.2.5' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

/* restart geonetwork

select * from settings where name like '%version%';
+-------------------------+-------+----------+----------+----------+-----------+----------+
| name                    | value | datatype | position | internal | encrypted | editable |
|-------------------------+-------+----------+----------+----------+-----------+----------|
| system/platform/version | 4.2.5 | 0        | 150      | n        | n         | y        |
+-------------------------+-------+----------+----------+----------+-----------+----------+ 
*/


/* once everything is working restore the custom schema as well 

pg_restore -h localhost -p 5432 -d geonetwork425 -F custom -U geonetwork -v ./postgresql/geonetwork38custom.dump

# and restart geonetwork */