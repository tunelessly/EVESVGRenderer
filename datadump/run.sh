#!/usr/bin/env sh
set -e;

SOURCE_DB=$1;
if [ -z $SOURCE_DB ]; then echo "Invalid argument for sqllite source database."; exit; fi;

# TIMESTAMP=$(date +%s%N | cut -b1-13);
TARGET_SQL_DUMP_FILENAME="database_version_${TIMESTAMP}.sql";
TARGET_DB_FILENAME="database_transformed.sqlite3";

sqlite3 "${SOURCE_DB}" < "dump.sql" > "${TARGET_SQL_DUMP_FILENAME}" && echo "SQL Dump ${TARGET_SQL_DUMP_FILENAME} created."; 
sqlite3 "${TARGET_DB_FILENAME}" < "${TARGET_SQL_DUMP_FILENAME}" && echo "Database ${TARGET_DB_FILENAME} created.";
sqlite3 "${TARGET_DB_FILENAME}" < "transform.sql" && echo "Database ${TARGET_DB_FILENAME} transformed.";