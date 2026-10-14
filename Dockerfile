FROM php:7.0-apache

RUN sed -i 's/deb.debian.org/archive.debian.org/; s|security.debian.org|archive.debian.org|; /stretch-updates/d' /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends git unzip zip libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libxml2-dev ruby-sass mysql-client libsqlite3-dev \
 && docker-php-ext-configure gd --with-jpeg-dir=/usr --with-freetype-dir=/usr \
 && docker-php-ext-install pdo pdo_mysql pdo_sqlite mbstring gd zip opcache \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

ENV APACHE_DOCUMENT_ROOT=/var/www/app/web
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
 && printf 'memory_limit=1024M\ndate.timezone=UTC\n' > /usr/local/etc/php/conf.d/jarves.ini

COPY jarves-src.tar.gz /tmp/jarves-src.tar.gz
RUN mkdir -p /var/www/jarves && tar xzf /tmp/jarves-src.tar.gz -C /var/www/jarves && rm /tmp/jarves-src.tar.gz
COPY docker/app /var/www/app
WORKDIR /var/www/app
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --prefer-dist --no-progress \
 && mkdir -p app/cache app/logs data web/bundles

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
