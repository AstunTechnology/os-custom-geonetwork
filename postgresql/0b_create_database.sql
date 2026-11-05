CREATE SCHEMA audit;
CREATE SCHEMA custom;
CREATE EXTENSION hstore;
CREATE EXTENSION postgis;
CREATE EXTENSION postgres_fdw;
CREATE SERVER IF NOT EXISTS pub_rds FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :'db_old_host', dbname :'db_old_extdbname', port :'db_old_port');