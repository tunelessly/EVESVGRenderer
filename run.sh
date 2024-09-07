#!/usr/bin/env sh
set -e;

DOWNLOAD_DIRECTORY="./downloads";
URL="https://www.fuzzwork.co.uk/dump/";
FILENAME="sqlite-latest.sqlite.bz2";
FULL_URL="$URL$FILENAME";

if [ ! -d "$DOWNLOAD_DIRECTORY" ]; then 
    mkdir "$DOWNLOAD_DIRECTORY";
fi;

cd "$DOWNLOAD_DIRECTORY";
echo "Downloading database dump from $FULL_URL iff theirs is more recent...";
curl -s -O -z "$FILENAME" "$FULL_URL";
echo "Done.";

echo "Extracting file...";
bzip2 -kf -d "$FILENAME";
echo "Done.";

cd "../datadump";
echo "Performing transformations...";
./run.sh ../downloads/sqlite-latest.sqlite;
echo "Done.";

cd ..;
echo "Rendering SVGs...";
poetry run start ./datadump/database_transformed.sqlite3;
echo "Done".;