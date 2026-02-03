FROM php:8.2-apache

RUN apt-get update \
    && apt-get install -y \
       libicu-dev libxml2-dev libzip-dev \
       libpng-dev libonig-dev \
       libjpeg62-turbo libjpeg62-turbo-dev \
       libfreetype6-dev \
    && docker-php-ext-install \
       intl xml xmlwriter gettext mbstring zip mysqli pdo_mysql \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

RUN a2enmod rewrite

# Apache VirtualHost FIX (INI KUNCI 404)
RUN printf "<VirtualHost *:80>\n\
ServerName localhost\n\
DocumentRoot /var/www/html\n\
<Directory /var/www/html>\n\
AllowOverride All\n\
Require all granted\n\
</Directory>\n\
</VirtualHost>\n" > /etc/apache2/sites-available/000-default.conf \
 && a2ensite 000-default.conf

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html
COPY . /var/www/html

RUN composer install --no-dev --optimize-autoloader

# Pastikan folder SLiMS ada & writable
RUN mkdir -p files images repository config \
 && chown -R www-data:www-data /var/www/html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
