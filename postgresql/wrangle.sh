#!/bin/bash

# define all the variables we need

EXCLUDELIST=harvesterSettings
DB_ADMIN_USER=geonetwork
DB_OLD_HOST=localhost
DB_NEW_HOST=localhost
DB_OLD_PORT=5433
DB_NEW_PORT=5433
DB_OLD_DBNAME=defra_geonetwork_int_live
DB_OLD_EXTDBNAME=defra_geonetwork_ext_live
DB_NEW_DBNAME=defra_geonetwork_int_live_new
DB_NEW_ROOT=geonetwork
DB_RO_USER=geonetwork_ro
# DB_RO_PASSWORD=PassSeveralFrightAgency0

Help()
{
	echo "Helper functions for EA database upgrade wrangling."
	echo "Make sure you complete the variables at the top of the script."
	echo
	echo "Syntax: wrangle.sh [option]"
	echo
	echo "Options:"
	echo "-c|--create 		| create new database and geonetwork roles"
	echo "-d|--dump 		| back up database with separate dump for excluded tables"
	echo "-r|--restore		| restore database without excluded tables or custom schema"
	echo "-b|--beforegeonetwork	| run 1_before_geonetwork.sql"
	echo "-a|--aftergeonetwork 	| run 2_after_geonetwork.sql"
	echo "-i|--reinstate		| restore excluded tables and custom schema"
	echo
}

# define the actions for each arg value

for arg in "$@"
do
	case $arg in

		-h|--help)

		Help
		;;

		-c|--create)
		# create new database, extensions, audit schema, foreign server and roles on new server
		echo -n "Enter the password for the admin user ${DB_ADMIN_USER} > "
		read PGPASSWORD
		echo -n "Set the password for the read-only user ${DB_RO_USER} > "
		read DB_RO_PASSWORD
		psql -h ${DB_NEW_HOST} -d postgres -U ${DB_NEW_ROOT} -p ${DB_NEW_PORT} -v db_admin_user=${DB_ADMIN_USER} -v db_ro_user=${DB_RO_USER} -v db_new_dbname=${DB_NEW_DBNAME} -v db_ro_password=${DB_RO_PASSWORD} -f 0a_create_database.sql > dbcreate.log 2> dbcreate.err
		psql -h ${DB_NEW_HOST} -d ${DB_NEW_DBNAME} -U ${DB_ADMIN_USER} -p ${DB_NEW_PORT} -v db_old_host=${DB_OLD_HOST} -v db_old_extdbname=${DB_OLD_EXTDBNAME} -v db_old_port=${DB_OLD_PORT} -f 0b_create_database.sql >> dbcreate.log 2>> dbcreate.err
		echo "Now restore the database backup with wrangle.sh -r"
		read -p "Press any key to continue ..."
		;;
		
		-d|--dump)
		# backup excluding harvestersettings table
		#pg_dump -T ${EXCLUDELIST} -U ${DB_ADMIN_USER} -h ${DB_OLD_HOST} -p ${DB_OLD_PORT} -F custom -v ${DB_OLD_DBNAME}> ${DB_OLD_DBNAME}.dump
		# backup harvestersettings table as insert statements
		pg_dump -t ${EXCLUDELIST} --column-inserts -U ${DB_ADMIN_USER} -h ${DB_OLD_HOST} -p ${DB_OLD_PORT} -F plain -a --no-comments -v ${DB_OLD_DBNAME}> ${DB_OLD_DBNAME}_exclusions.sql
		echo "Now create your NEW database with wrangle.sh -c"
		read -p "Press any key to continue ..."
		;;

		-r|--restore)
		# restore excluding custom schema
		pg_restore -n audit -n public -h ${DB_NEW_HOST} -d ${DB_NEW_DBNAME} -p ${DB_NEW_PORT} -F custom -U ${DB_ADMIN_USER} -v ${DB_OLD_DBNAME}.dump
		echo "Now prep the database with wrangle.sh -b"
		read -p "Press any key to continue ..."
		;;

		-b|--beforegeonetwork)
		psql -h ${DB_NEW_HOST} -d ${DB_NEW_DBNAME} -U ${DB_ADMIN_USER} -p ${DB_NEW_PORT} -f 1_before_geonetwork.sql > dbbeforegeonetwork.log 2> dbbeforegeonetwork.err
		echo "Now start GeoNetwork and run wrangle.sh -a once it has started"
		read -p "Press any key to continue ..."
		;;

		-a|--aftergeonetwork)
		echo  -n "Enter your mailtrap test username > "
		read MAILTRAP_USERNAME
		echo -n "Enter your mailtrap test password > "
		read MAILTRAP_PASSWORD
		psql -h ${DB_NEW_HOST} -d ${DB_NEW_DBNAME} -U ${DB_ADMIN_USER} -p ${DB_NEW_PORT} -v mailtrap_username=${MAILTRAP_USERNAME} -v mailtrap_password=${MAILTRAP_PASSWORD} -f 2_after_geonetwork.sql > dbaftergeonetwork.log 2> dbaftergeonetwork.err
		echo "Now restore the custom schema with wrangle.sh -i"
		read -p "Press any key to continue ..."
		;;

		-i|--reinstate)
		# restore harvesterSettings table
		psql -h ${DB_NEW_HOST} -d ${DB_NEW_DBNAME} -U ${DB_ADMIN_USER} -p ${DB_NEW_PORT} -f ${DB_OLD_DBNAME}_exclusions.sql
		# restore only custom schema
		#pg_restore -t custom -h ${DB_NEW_HOST} -d ${DB_NEW_DBNAME} -p ${DB_NEW_PORT} -F custom -U ${DB_ADMIN_USER} -v ${DB_OLD_DBNAME}.dump
		echo "I think we're done!"
		read -p "Press any key to continue ..."
		;;


		*)

		Help
		;;

	esac

done

if [ -z "$*" ]; then Help; fi





