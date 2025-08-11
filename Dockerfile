FROM mediawiki:1.43

# run setup as root user
USER root
# allow running composer as superuser
ENV COMPOSER_ALLOW_SUPERUSER=1 

# install node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

# install dependencies
RUN apt-get update && \
    apt-get install -y \
        vim \
        gettext-base \
        wget \
        zip \
        unzip \
        libzip-dev \
        zlib1g-dev \
        nodejs \
        automysqlbackup && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install zip calendar

# install composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# install skin and required extensions
RUN git clone -b 5.43 https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone -b REL1_43 https://github.com/thaider/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization \
    && git clone -b REL1_43 https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge.git /var/www/html/extensions/UserMerge \
    && git clone -b REL1_43 https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica.git /var/www/html/extensions/Elastica \
    && git clone -b REL1_43 https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch.git /var/www/html/extensions/CirrusSearch \
    && git clone -b REL1_43 https://gerrit.wikimedia.org/r/mediawiki/extensions/VEForAll.git /var/www/html/extensions/VEForAll

# change to version of PageForms that is known to be working with semorg's setup
WORKDIR /var/www/html/extensions/PageForms
RUN git checkout d514e77

# install PHP dependencies for Elastica extension
WORKDIR /var/www/html/extensions/Elastica
RUN composer update --no-dev

WORKDIR /var/www/html

# add composer.local.json and robots.txt
ADD composer.local.json ./
ADD robots.txt ./

# update composer
RUN chown root:root composer.json
RUN composer config --no-interaction allow-plugins.composer/installers true
RUN composer update --no-dev -o

# load config templates
RUN mkdir ./templates
ADD config ./templates/config

# setup config directory and persistent LocalSettings file
RUN mkdir config
ADD LocalSettings.override.php config
RUN chown -R www-data:www-data config

# add entry point
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# add update script
COPY update.sh /update.sh
RUN chmod +x /update.sh

# set ServerName for apache
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]
