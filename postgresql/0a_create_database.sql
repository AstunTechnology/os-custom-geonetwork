CREATE ROLE :db_ro_user WITH login encrypted password :'db_ro_password';
CREATE DATABASE :db_new_dbname OWNER :db_admin_user;

