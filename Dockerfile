#stage 1 : Build stage
FROM php:7.4-fpm AS builder
WORKDIR /var/www/html
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql zip
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader

#stage 2 : Production stage

FROM php:7.4-fpm
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www/html
COPY --from=builder /var/www/html .
COPY . .
RUN composer dump-autoload --optimize
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN php artisan key:generate
EXPOSE 9000
CMD php artisan serve --host=0.0.0.0 --port=$APP_PORT
