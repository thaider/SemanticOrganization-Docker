FROM mediawiki:1.35

# run setup as root user
USER root
# allow running composer as superuser
ENV COMPOSER_ALLOW_SUPERUSER = 1 

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
        automysqlbackup \
        netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install zip && \
    docker-php-ext-install calendar

WORKDIR /var/www/html

# install skin and required extensions
RUN git clone -b REL1_35 https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone -b REL1_35 https://github.com/thaider/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization

# change to version of PageForms that is known to be working with semorg's setup
WORKDIR /var/www/html/extensions/PageForms
RUN git checkout 731d226

WORKDIR /var/www/html

# add composer.local.json and robots.txt
ADD composer.local.json ./
ADD robots.txt ./

# install composer and update
RUN wget https://getcomposer.org/composer.phar
RUN chown root:root composer.json
RUN php composer.phar config --no-interaction allow-plugins.composer/installers true
RUN php composer.phar update --no-dev -o

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

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]
