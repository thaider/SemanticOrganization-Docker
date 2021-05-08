#!/bin/bash
set -e

EXTENSIONS="config/EXTENSIONS"

echo "PULL TWEEKI"
cd /var/www/html/skins/Tweeki
git pull

echo "PULL SEMANTIC ORGANIZATION"
cd /var/www/html/extensions/SemanticOrganization
git pull

echo "IMPORTING SEMORG PAGES..."
cd /var/www/html
php maintenance/importDump.php < extensions/SemanticOrganization/import/semorg_pages.xml

echo "CLEANUP AFTER IMPORT..."
php maintenance/rebuildrecentchanges.php
php maintenance/runJobs.php

if [ -e $EXTENSIONS ]; then

    IFS='|'
    while read -r EXTENSION_NAME EXTENSION_URL
    do

        if [ -e "/var/www/html/extensions/$EXTENSION_NAME" ]; then

            echo "PULLING EXTENSION \"$EXTENSION_NAME\""
            cd /var/www/html/extensions/$EXTENSION_NAME
            git pull

        fi

    done < "$EXTENSIONS"

fi