FROM debian:jessie

WORKDIR /var/www/html

# Install nginx and php
RUN apt-get update && apt-get install -y nginx \
    php5-curl \
    php5-fpm \
    php5-gd \
    php5-intl \
    php5-mcrypt \
    php5-mysql \
    php5-sqlite \
    php5-xsl \
    php-pear \
    git

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY assets/bin /usr/local/bin
COPY assets/etc/php5/fpm/php.ini /etc/php5/fpm/
COPY assets/etc/php5/fpm/php-fpm.conf /etc/php5/fpm/
COPY assets/nginx/default /etc/nginx/sites-enabled

RUN rm -r /etc/php5/fpm/pool.d
RUN chmod a+x /usr/local/bin/*.sh

# Install Roundcube + plugins
RUN VERSION=`latestversion roundcube/roundcubemail` \
    && mkdir -p /var/www/html \
    && rm -r /var/www/html/* \
    && cd /var/www/html \
    && git clone --branch ${VERSION} --depth 1 https://github.com/roundcube/roundcubemail.git . \
    && rm -rf .git installer

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Roundcube
COPY assets/config.inc.php /var/www/html/config/

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
