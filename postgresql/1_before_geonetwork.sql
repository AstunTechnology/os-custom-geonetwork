delete from settings where name like '%passwordEnforcement%';
update settings set value = '' where name='system/feedback/mailServer/password';

create index idx_metadatafiledownloads_metadataid on metadatafiledownloads (metadataid);
create index idx_metadatafileuploads_metadataid on metadatafileuploads (metadataid);
create index idx_operationallowed_metadataid on operationallowed (metadataid);

ALTER TABLE metadatastatus ADD COLUMN IF NOT EXISTS owner integer;
UPDATE metadatastatus SET owner=0;
ALTER TABLE metadatastatus ALTER COLUMN owner SET NOT NULL;

CREATE TABLE harvesterSettings 
		(id int, 
		parentid int, 
		name varchar(64), 
		value text, 
		encrypted character(1), 
		primary key(id), 
		foreign key(parentId) references HarvesterSettings(id));
ALTER TABLE harvestersettings ALTER COLUMN encrypted SET DEFAULT 'n'::bpchar;
INSERT INTO harvesterSettings (id, parentid, name, value) VALUES  (1,NULL,'harvesting',NULL);
ALTER TABLE harvestersettings ALTER COLUMN id SET NOT NULL;
ALTER TABLE harvestersettings ALTER COLUMN name SET NOT NULL;
ALTER TABLE harvestersettings ALTER COLUMN encrypted SET NOT NULL;
