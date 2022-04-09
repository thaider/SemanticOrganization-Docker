FROM mediawiki:1.35

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

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
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install zip && \
    docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir && \
    docker-php-ext-install -j$(nproc) gd

WORKDIR /var/www/html

RUN git clone https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone -b REL1_35 https://github.com/thaider/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization \
    && git clone https://github.com/redekopmark/MediaWiki-pChart4mw /var/www/html/extensions/pChart4mw

WORKDIR /var/www/html/extensions/PageForms
RUN git checkout 731d226

WORKDIR /var/www/html

ADD composer.local.json ./
ADD robots.txt ./

RUN wget https://getcomposer.org/composer-1.phar
RUN php composer-1.phar update --no-dev -o

RUN mkdir ./templates

ADD config ./templates/config

RUN mkdir config
ADD LocalSettings.override.php config
RUN chown -R www-data:www-data config

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY update.sh /update.sh
RUN chmod +x /update.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]
