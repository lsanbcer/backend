FROM PHP:7.4-APACHE

RUN mkdir -p /var/www/html/backend

WORKDIR /var/www/html/backend

COPY ./src-backend/. .
COPY ./ssl/. .
COPY ./php.ini /usr/local/etc/php

RUN chmod -R 777 /var/www/html/backend
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pod_pgsql
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    nano
RUN docker-php-ext-install zip
RUN apt-get install -y python3 \
 && apt-get install -y python3-pip \
 && pip3 install --upgrade pip
 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --ignore-platform-reqs

RUN php /var/www/html/backend/artisan
RUN php artisan key:generate
RUN php artisan jwt:secret
RUN php artisan storage:link

ADD ./apache/laravel.conf /etc/apache2/sites-available/laravel.conf
RUN a2dissite 000-default.conf
RUN a2ensite laravel.conf
RUN a2enmod ssl 
RUN a2enmod rewrite
