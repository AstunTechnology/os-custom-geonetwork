-- migration to version 3.11.0 SNAPSHOT -- 

UPDATE Settings SET value='3.11.0' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

UPDATE Settings SET editable = 'n' WHERE name = 'system/userFeedback/lastNotificationDate';

-- Increase the length of Validation type (where the schematron file name is stored)
ALTER TABLE Validation ALTER COLUMN valType TYPE varchar(128);

ALTER TABLE usersearch ALTER COLUMN url TYPE text;

INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (63,'recordrestored','y', 63, 'event', null);
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'ara','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'cat','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'chi','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'dut','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'eng','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'fre','Fiche restaurée.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'fin','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'ger','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'ita','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'nor','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'pol','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'por','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'rus','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'slo','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'spa','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'tur','Record restored.');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (63,'vie','Record restored.');

DELETE FROM Settings WHERE name = 'system/server/securePort';

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/security/passwordEnforcement/minLength', '6', 1, 12000, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/security/passwordEnforcement/maxLength', '20', 1, 12001, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/security/passwordEnforcement/usePattern', 'true', 2, 12002, 'n');
INSERT INTO Settings (name, value, datatype, position, internal, editable) VALUES ('system/security/passwordEnforcement/pattern', '^((?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*(_|[^\w])).*)$', 0, 12003, 'n', 'n');

UPDATE Settings SET encrypted='y' WHERE name='system/proxy/password';
UPDATE Settings SET encrypted='y' WHERE name='system/feedback/mailServer/password';
UPDATE Settings SET encrypted='y' WHERE name='system/publication/doi/doipassword';

-- migration to version 3.12.0 --

UPDATE Settings SET value='3.12.0' WHERE name='system/platform/version';
UPDATE Settings SET value='0' WHERE name='system/platform/subVersion';

-- migration to version 3.12.1 --


UPDATE Settings SET value='3.12.1' WHERE name='system/platform/version';
UPDATE Settings SET value='0' WHERE name='system/platform/subVersion';

-- migration to version 4.0.0 SNAPSHOT --

DROP TABLE metadatanotifications;
DROP TABLE metadatanotifiers;

DELETE FROM Settings WHERE name LIKE 'system/indexoptimizer%';
DELETE FROM Settings WHERE name LIKE 'system/requestedLanguage%';
DELETE FROM Settings WHERE name = 'system/inspire/enableSearchPanel';
DELETE FROM Settings WHERE name = 'system/autodetect/enable';

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/index/indexingTimeRecordLink', 'false', 2, 9209, 'n');

UPDATE metadata
    SET data = REGEXP_REPLACE(data, '[a-z]{3}\/thesaurus\.download\?ref=', 'api/registries/vocabularies/', 'g')
    WHERE data LIKE '%thesaurus.download?ref=%';

UPDATE settings SET value = '1' WHERE name = 'system/threadedindexing/maxthreads';

UPDATE Settings SET value='4.0.0' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to version 4.0.1 SNAPSHOT --

UPDATE Settings SET value='4.0.1' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to version 4.0.2 SNAPSHOT --

-- Set default timezone to UTC if not set.
UPDATE Settings SET value = 'Etc/UTC' WHERE name = 'system/server/timeZone' AND VALUE = '';

ALTER TABLE guf_userfeedbacks_guf_rating DROP COLUMN GUF_UserFeedbacks_uuid;


UPDATE Settings SET value='4.0.2' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to version 4.0.3 SNAPSHOT --

UPDATE Settings SET value='4.0.3' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- Changes were back ported to version 3.12.x so they are no longer required unless upgrading from v400, v401, v402 which did not have 3.12.x  migrations steps.
-- So lets try to only add the records if they don't already exists.
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'system/security/passwordEnforcement/minLength', '6', 1, 12000, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'system/security/passwordEnforcement/minLength');
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'system/security/passwordEnforcement/maxLength', '20', 1, 12001, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'system/security/passwordEnforcement/maxLength');
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'system/security/passwordEnforcement/usePattern', 'true', 2, 12002, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'system/security/passwordEnforcement/usePattern');
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'system/security/passwordEnforcement/pattern', '^((?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*(_|[^\w])).*)$', 0, 12003, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'system/security/passwordEnforcement/pattern');

-- migration to version 4.0.4 SNAPSHOT --


DELETE FROM Schematrondes WHERE iddes IN (SELECT id FROM schematron WHERE filename LIKE 'schematron-rules-inspire%');
DELETE FROM Schematroncriteria WHERE group_name || group_schematronid IN (SELECT name || schematronid FROM schematroncriteriagroup WHERE schematronid IN (SELECT id FROM schematron WHERE filename LIKE 'schematron-rules-inspire%'));
DELETE FROM Schematroncriteriagroup WHERE schematronid IN (SELECT id FROM schematron WHERE filename LIKE 'schematron-rules-inspire%');
DELETE FROM Schematron WHERE filename LIKE 'schematron-rules-inspire%';


UPDATE Settings SET value='4.0.4' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- Changes were back ported to version 3.12.x so they are no longer required unless upgrading from v400, v401, v402, v403 which did not have 3.12.x migrations steps
-- For security reasons, the statements will remain as it will simply change the values back to true if they were previously changed to false.
-- ALTER TABLE Settings ADD COLUMN encrypted VARCHAR(1) DEFAULT 'n';
UPDATE Settings SET encrypted='y' WHERE name='system/proxy/password';
UPDATE Settings SET encrypted='y' WHERE name='system/feedback/mailServer/password';
UPDATE Settings SET encrypted='y' WHERE name='system/publication/doi/doipassword';

-- migration to version 4.0.5 SNAPSHOT --

UPDATE metadata SET data = replace(data, 'WWW:DOWNLOAD-OGC:OWS-C', 'OGC:OWS-C') WHERE data LIKE '%WWW:DOWNLOAD-OGC:OWS-C%';

UPDATE Settings SET internal = 'n' WHERE name = 'system/metadata/prefergrouplogo';

UPDATE Settings SET value='4.0.5' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to version 4.0.6 --

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/inspire/remotevalidation/nodeid', '', 0, 7212, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/inspire/remotevalidation/apikey', '', 0, 7213, 'y');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/publication/doi/doipublicurl', '', 0, 100196, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/harvester/enablePrivilegesManagement', 'false', 2, 9010, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/localrating/notificationLevel', 'catalogueAdministrator', 0, 2111, 'n');

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/metadatacreate/preferredGroup', '', 1, 9105, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/metadatacreate/preferredTemplate', '', 0, 9106, 'n');

DELETE FROM Settings WHERE name = 'system/server/securePort';

UPDATE Settings SET value = '0 0 0 * * ?' WHERE name = 'system/inspire/atomSchedule' and value = '0 0 0/24 ? * *';

UPDATE Settings SET value='4.0.6' WHERE name='system/platform/version';
UPDATE Settings SET value='0' WHERE name='system/platform/subVersion';

-- migration to version 4.0.7 SNAPSHOT -- 

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('metadata/csvReport/csvName', 'metadata_{datetime}.csv', 0, 12607, 'n');

UPDATE Settings set position = 7213 WHERE name = 'system/inspire/remotevalidation/nodeid';
UPDATE Settings set position = 7214 WHERE name = 'system/inspire/remotevalidation/apikey';
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/inspire/remotevalidation/urlquery', '', 0, 7212, 'n');

INSERT INTO Users (id, username, password, name, surname, profile, kind, organisation, security, authtype, isenabled) VALUES  (0,'nobody','','nobody','nobody',4,'','','','', 'n');
INSERT INTO Address (id, address, city, country, state, zip) VALUES  (0, '', '', '', '', '');
INSERT INTO UserAddress (userid, addressid) VALUES  (0, 0);

-- WARNING: Security / Add this settings only if you need to allow admin
-- users to be able to reset user password. If you have mail server configured
-- user can reset password directly. If not, then you may want to add that settings
-- if you don't have access to the database.
-- INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/security/password/allowAdminReset', 'false', 2, 12004, 'n');

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('metadata/link/excludedUrlPattern', '', 0, 12010, 'n');

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/metadata/thesaurusNamespace', 'https://registry.geonetwork-opensource.org/{{type}}/{{filename}}', 0, 9161, 'n');

UPDATE Settings SET editable = 'n' WHERE name = 'system/userFeedback/lastNotificationDate';
UPDATE Settings SET editable = 'n' WHERE name = 'system/security/passwordEnforcement/pattern';

UPDATE Settings SET value='4.0.7' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to version 4.2.0 SNAPSHOT --

UPDATE Settings SET value='4.2.0' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to version 4.2.1 SNAPSHOT --


INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/metadataprivs/publicationbyrevieweringroupowneronly', 'true', 2, 9181, 'n');
INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/publication/doi/doipattern', '{{uuid}}', 0, 100197, 'n');

-- Changes were back ported to version 3.12.x so they are no longer required unless upgrading from previous v42x which did not have 3.12.x  migrations steps.
-- So lets try to only add the records if they don't already exists.
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'metadata/delete/profilePublishedMetadata', 'Editor', 0, 12011, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'metadata/delete/profilePublishedMetadata');
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'system/metadataprivs/publication/notificationLevel', '', 0, 9182, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'system/metadataprivs/publication/notificationLevel');
INSERT INTO Settings (name, value, datatype, position, internal) SELECT distinct 'system/metadataprivs/publication/notificationGroups', '', 0, 9183, 'n' from settings WHERE NOT EXISTS (SELECT name FROM Settings WHERE name = 'system/metadataprivs/publication/notificationGroups');

-- cf. https://www.un.org/en/about-us/member-states/turkiye (run this manually if it applies to your catalogue)
-- UPDATE metadata SET data = replace(data, 'Turkey', 'Türkiye') WHERE data LIKE '%Turkey%';
UPDATE Settings SET value='log4j2.xml' WHERE name='system/server/log';

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/localrating/notificationGroups', '', 0, 2112, 'n');

UPDATE Settings SET value='4.2.1' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';

-- migration to 4.2.2 SNAPSHOT --

DELETE FROM Settings WHERE name = 'system/downloadservice/leave';
DELETE FROM Settings WHERE name = 'system/downloadservice/simple';
DELETE FROM Settings WHERE name = 'system/downloadservice/withdisclaimer';

INSERT INTO Settings (name, value, datatype, position, internal) VALUES ('system/server/sitemapLinkUrl', NULL, 0, 270, 'y');

UPDATE Settings SET value='4.2.2' WHERE name='system/platform/version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='system/platform/subVersion';
