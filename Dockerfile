FROM wordpress:php7.4-apache

ENV XDEBUG_PORT 9000

RUN yes | pecl install xdebug && \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini && \
	echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
	echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
	echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini && \
	echo "xdebug.remote_mode=req" >> /usr/local/etc/php/conf.d/xdebug.ini && \
	echo "xdebug.remote_autostart=false" >> /usr/local/etc/php/conf.d/xdebug.ini && \
	echo "198.143.164.251 api.wordpress.org" >> /etc/hosts

EXPOSE 9000
