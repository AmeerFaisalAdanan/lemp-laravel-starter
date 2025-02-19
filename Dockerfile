# Use PHP 8.3 FPM image as the base
FROM php:8.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    inetutils-ping \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql gd zip intl pcntl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Redis PHP extension
RUN pecl install redis && docker-php-ext-enable redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add a non-root user to improve security
ARG user=app
ARG uid=1000
ARG gid=1000

RUN groupadd -g $gid $user && \
    useradd -u $uid -g $gid -m $user && \
    mkdir -p /var/www && \
    chown -R $user:$user /var/www

# Set working directory
# WORKDIR /var/www

# Copy application files to the container
# COPY . /var/www/

# Copy SSL certificates for Nginx (optional if not required for PHP-FPM)
# COPY ./docker/nginx/selfsigned.crt /etc/ssl/certs/selfsigned.crt
# COPY ./docker/nginx/selfsigned.key /etc/ssl/private/selfsigned.key

# Copy custom php.ini for upload limits
COPY ./docker/php/php.ini /usr/local/etc/php/

# Install Composer dependencies
# RUN composer update && composer dump-autoload && composer install --no-dev --optimize-autoloader

# Expose port 9000 for PHP-FPM
# EXPOSE 9000

# Start PHP-FPM server
# CMD ["php-fpm"]
