#!/bin/bash
set -e

cd /var/www/html

CONTAINER_UPDATED="UPDATED"
CONTAINER_INSTALLED="config/INSTALLED"
EXTENSIONS="config/EXTENSIONS"

if [ ! -e $CONTAINER_INSTALLED ]; then

    echo "SETUP (SEMANTIC-)MEDIAWIKI..."
    php maintenance/install.php --dbserver=$MYSQL_HOST --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --scriptpath="" --lang=$MEDIAWIKI_LANG --pass=$MEDIAWIKI_ADMIN_PASSWORD "$MEDIAWIKI_NAME" "$MEDIAWIKI_ADMIN_USERNAME"

    echo "SAVE LOCALSETTINGS.PHP"
    cp -a LocalSettings.php config/

    touch $CONTAINER_INSTALLED

fi

echo "RESET/UPDATE LOCALSETTINGS.PHP"
cp -a config/LocalSettings.php ./ 
cp templates/config/LocalSettings.additional.template.php LocalSettings.additional.php 
echo "\$wgServer = \"$MEDIAWIKI_SERVER\";" >> LocalSettings.php
echo "require_once('LocalSettings.additional.php');" >> LocalSettings.php

if [ -e $EXTENSIONS ]; then

    IFS='|'
    while read -r EXTENSION_NAME EXTENSION_URL
    do
        echo "INSTALLING EXTENSION \"$EXTENSION_NAME\""

        if [ ! -e "/var/www/html/extensions/$EXTENSION_NAME" ]; then

            git clone $EXTENSION_URL /var/www/html/extensions/$EXTENSION_NAME

        fi

        echo "wfLoadExtension( '$EXTENSION_NAME' );" >> LocalSettings.php

    done < "$EXTENSIONS"

fi

echo "require_once('config/LocalSettings.override.php');" >> LocalSettings.php  

if [ $MEDIAWIKI_DEBUG == 'true' ]; then
    
    echo "ENABLE DEBUG MODE..."
    echo "\$wgShowExceptionDetails = true;" >> LocalSettings.php 
    echo "\$wgShowDBErrorBacktrace = true;" >> LocalSettings.php 

fi

if [ ! -e $CONTAINER_UPDATED ]; then

    echo "RUN MEDIAWIKI UPDATE SCRIPT..."
    php maintenance/update.php --skip-external-dependencies --quick

    echo "IMPORTING SEMORG PAGES..."
    php maintenance/importDump.php < extensions/SemanticOrganization/import/semorg_pages.xml

    echo "CLEANUP AFTER IMPORT..."
    php maintenance/rebuildrecentchanges.php
    php maintenance/runJobs.php

    touch $CONTAINER_UPDATED

fi

echo "STARTUP WEB SERVER..."
exec "apache2-foreground"