FROM php:7-apache

EXPOSE 80

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2
ENV APACHE_PID_FILE    /var/run/apache2/apache2.pid
ENV APACHE_SERVER_NAME php-docker-base-linkorb

ENV APP_ENV=prod

COPY ./apache2.conf      /etc/apache2/apache2.conf
COPY ./apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update \
  && apt-get install -y --no-install-recommends git nodejs npm unzip zip libbz2-dev openssh-client \
  && install-php-extensions apcu bzip2 gd gmp intl opcache pdo pdo_mysql sockets zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /app/config/secrets/dev \
  && mkdir -p /app/public/build \
  && chown -R www-data:www-data /app \
  && chown -R www-data:www-data /var/www \
  && a2enmod rewrite

COPY --chown=www-data:www-data index.html /app

WORKDIR /app

USER root

COPY app-docker-entrypoint.sh /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

CMD ["apache2-foreground"]
