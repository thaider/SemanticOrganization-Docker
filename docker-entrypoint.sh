#!/bin/bash
set -e

echo "CHECKING DB CONNECTION ..."
i=0
until [ $i -ge 10 ]; do
    nc -z db 3306 && break

    i=$(( i + 1 ))

    echo "$i: WAITING FOR DB 5 SECONDS ..."
    sleep 5
done
if [ $i -eq 10 ]; then
    echo "DB CONNECTION REFUSED, TERMINATING ..."
    exit 1
fi
echo "DB IS UP ..."

cd /var/www/html

CONTAINER_UPDATED="UPDATED"
CONTAINER_INSTALLED="config/INSTALLED"
CONTAINER_1_35="config/1_35"
EXTENSIONS="config/EXTENSIONS"

if [ ! -e $CONTAINER_INSTALLED ]; then

    echo "SETUP (SEMANTIC-)MEDIAWIKI..."
    php maintenance/install.php --dbserver=$MYSQL_HOST --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --scriptpath="" --lang=$MEDIAWIKI_LANG --pass=$MEDIAWIKI_ADMIN_PASSWORD "$MEDIAWIKI_NAME" "$MEDIAWIKI_ADMIN_USERNAME"

    echo "SAVE LOCALSETTINGS.PHP"
    cp -a LocalSettings.php config/

    touch $CONTAINER_1_35
    touch $CONTAINER_INSTALLED

fi

echo "RESET/UPDATE LOCALSETTINGS.PHP"
cp -a config/LocalSettings.php ./
cp templates/config/LocalSettings.additional.template.php LocalSettings.additional.php
echo "\$wgServer = \"$MEDIAWIKI_SERVER\";" >> LocalSettings.php
echo "require_once('LocalSettings.additional.php');" >> LocalSettings.php

if [ ! ${MEDIAWIKI_EXTENSIONS:-true} == 'false' ] && [ -e $EXTENSIONS ]; then

    IFS='|'
    while read -r EXTENSION_NAME EXTENSION_URL
    do
        echo "INSTALLING EXTENSION \"$EXTENSION_NAME\""

        if [ ! -e "/var/www/html/extensions/$EXTENSION_NAME" ]; then

            git clone -b REL1_35 $EXTENSION_URL /var/www/html/extensions/$EXTENSION_NAME

        fi

        echo "wfLoadExtension( '$EXTENSION_NAME' );" >> LocalSettings.php

    done < "$EXTENSIONS"

fi

echo "require_once('config/LocalSettings.override.php');" >> LocalSettings.php

if [ "$MEDIAWIKI_DEBUG" == 'true' ]; then

    echo "ENABLE DEBUG MODE..."
    echo "\$wgShowExceptionDetails = true;" >> LocalSettings.php
    echo "\$wgShowDBErrorBacktrace = true;" >> LocalSettings.php

fi

if [ "$MEDIAWIKI_CUSTOM" == 'true' ]; then

    echo "CREATE CUSTOM STYLES"
    cd /var/www/html/extensions/SemanticOrganization
    npm install

    if [ ! -e resources/custom/styles/custom.scss ]; then

        cp resources/custom/styles/example.custom.scss resources/custom/styles/custom.scss

    fi

    npm run prod
    cd /var/www/html
    echo "\$wgSemorgUseCustomStyles = true;" >> LocalSettings.php

fi

if [ ! -e $CONTAINER_1_35 ]; then

    echo "UPDATE TO MEDIAWIKI 1.35"
    php maintenance/populateContentTables.php
    php maintenance/update.php --quick
    php extensions/SemanticMediaWiki/maintenance/updateEntityCountMap.php
    php extensions/SemanticMediaWiki/maintenance/rebuildData.php -v --with-maintenance-log

    echo "CHANGED BEHAVIOUR OF NAMED ARGS AND USERPARAM"
    set +e # replaceAll.php throws an error if there is nothing to replace
    php extensions/ReplaceText/maintenance/replaceAll.php "{{{?" "{{{" --yes --nsall
    php extensions/ReplaceText/maintenance/replaceAll.php "{{{userparam" "{{{#userparam" --yes --nsall
    set -e

    php maintenance/runJobs.php

    touch $CONTAINER_1_35

fi

if [ ! -e $CONTAINER_UPDATED ]; then

    echo "RUN MEDIAWIKI UPDATE SCRIPT..."
    php maintenance/update.php --quick

    echo "IMPORTING SEMORG PAGES..."
    php maintenance/importDump.php < extensions/SemanticOrganization/import/semorg_pages.xml

    echo "CLEANUP AFTER IMPORT..."
    php maintenance/rebuildrecentchanges.php
    php maintenance/runJobs.php

    echo "SETUP AUTOMYSQLBACKUP"
    echo "USERNAME=$MYSQL_USER" >> /etc/default/automysqlbackup
    echo "PASSWORD=$MYSQL_PASSWORD" >> /etc/default/automysqlbackup
    sed -i "s/DBNAMES=.*/DBNAMES=mediawiki/" /etc/default/automysqlbackup
    sed -i "s/BACKUPDIR=.*/BACKUPDIR=\"\/dumps\"/" /etc/default/automysqlbackup

    touch $CONTAINER_UPDATED

fi

echo "STARTUP WEB SERVER..."
exec "apache2-foreground"
