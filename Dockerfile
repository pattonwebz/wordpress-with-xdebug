ARG PHP_VERSION=latest

FROM wordpress:${PHP_VERSION}

ENV XDEBUG_PORT_V2=9000
ENV XDEBUG_PORT_V3=9003

# Install only essential dependencies for PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install only the required PHP extensions: Intl and Redis
RUN docker-php-ext-install intl \
    && pecl install redis \
    && docker-php-ext-enable redis

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
