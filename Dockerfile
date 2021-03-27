FROM mediawiki:1.31

RUN apt-get update && \
    apt-get install -y nano gettext-base wget zip unzip libzip-dev zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install zip

WORKDIR /var/www/html

RUN git clone https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone -b REL1_31 https://github.com/thaider/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization

WORKDIR /var/www/html/extensions/PageForms
RUN git checkout 397dfbb

WORKDIR /var/www/html

ADD composer.local.json ./

RUN wget https://getcomposer.org/composer-1.phar
RUN php composer-1.phar update --no-dev

RUN mkdir ./templates

ADD config ./templates/config

RUN mkdir config
ADD LocalSettings.override.php config
RUN chown -R www-data:www-data config

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]