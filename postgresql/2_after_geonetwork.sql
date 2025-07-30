ALTER TABLE metadatastatus DROP CONSTRAINT IF EXISTS metadatastatus_pkey;
ALTER TABLE metadatastatus DROP CONSTRAINT IF EXISTS  metadatastatus_metadataid_fkey;
ALTER TABLE metadatastatus DROP CONSTRAINT IF EXISTS  metadatastatus_userid_fkey;
ALTER TABLE operationallowed DROP CONSTRAINT IF EXISTS  operationallowed_groupid_fkey;
ALTER TABLE operationallowed DROP CONSTRAINT IF EXISTS  operationallowed_metadataid_fkey;
ALTER TABLE operationallowed DROP CONSTRAINT IF EXISTS  operationallowed_operationid_fkey;
ALTER TABLE validation DROP CONSTRAINT  IF EXISTS validation_metadataid_fkey;
ALTER TABLE metadatastatus DROP CONSTRAINT  IF EXISTS metadatastatus_pkey;
ALTER TABLE metadatastatus ADD CONSTRAINT metadatastatus_pkey PRIMARY KEY (id);
ALTER TABLE metadatastatus ADD FOREIGN KEY (relatedmetadatastatusid) REFERENCES metadatastatus;

UPDATE statusvalues set notificationlevel = 'recordUserAuthor' WHERE name = 'draft';

UPDATE metadatastatus SET uuid = m.uuid FROM metadata m WHERE metadataid = m.id;

UPDATE SETTINGS SET value = '' WHERE name LIKE '%password';
UPDATE SETTINGS SET value = 'smtp.mailtrap.io' WHERE name LIKE 'system/feedback/mailServer/host';
UPDATE SETTINGS SET value = '465' WHERE name LIKE 'system/feedback/mailServer/port';
UPDATE SETTINGS SET value = 'false' WHERE name LIKE 'system/feedback/mailServer/tls';
UPDATE SETTINGS SET value = 'false' WHERE name LIKE 'system/feedback/mailServer/ssl';
UPDATE SETTINGS SET value = :'mailtrap_username' WHERE name LIKE 'system/feedback/mailServer/username';
UPDATE SETTINGS SET encrypted = 'n' WHERE name LIKE 'system/feedback/mailServer/password';
UPDATE SETTINGS SET value = :'mailtrap_password' WHERE name LIKE 'system/feedback/mailServer/password';
