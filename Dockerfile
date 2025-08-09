ARG PHP_VERSION=latest

FROM wordpress:${PHP_VERSION}

ENV XDEBUG_PORT_V2=9000
ENV XDEBUG_PORT_V3=9003
ARG PHP_MAJOR_VERSION=8

# Install some nice to have dependencies for PHP extensions and developer tools
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libssl-dev \
    libonig-dev \
    vim \
    nano \
    git \
    unzip \
    mariadb-client \
    msmtp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions commonly used in WordPress development
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        mysqli \
        pdo_mysql \
        zip \
        gd \
        soap \
        bcmath \
        exif \
        opcache \
    && pecl install redis \
    && docker-php-ext-enable redis

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install and configure Xdebug
RUN yes | pecl install xdebug && \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini && \
    if php -v | grep -q "PHP 7"; then \
        # Xdebug 2.x configuration for PHP 7
        echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.remote_port=${XDEBUG_PORT_V2}" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.remote_mode=req" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.remote_autostart=false" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    else \
        # Xdebug 3.x configuration for PHP 8+
        echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.client_port=${XDEBUG_PORT_V3}" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini && \
        echo "xdebug.discover_client_host=true" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    fi

# Configure php.ini settings for WordPress development
RUN { \
        echo 'upload_max_filesize = 64M'; \
        echo 'post_max_size = 64M'; \
        echo 'memory_limit = 256M'; \
        echo 'max_execution_time = 300'; \
    } > /usr/local/etc/php/conf.d/wordpress-recommended.ini

EXPOSE 9000
EXPOSE 9003
