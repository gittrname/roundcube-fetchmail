FROM debian:jessie

#MAINTAINER  J.P.C. Oudeman
MAINTAINER ペール<txgfx504@yahoo.co.jp>

ENV DEBIAN_FRONTEND noninteractive

# Install nginx
RUN apt-get update 
RUN apt-get install -y nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Install fetchmail, postfix, cron
RUN apt-get install -y fetchmail postfix cron rsyslog

# Configure Fetchmail
COPY assets/etc/cron.d/fetchmail /etc/cron.d/fetchmail
COPY assets/var/mail/fetchmail.pl /var/mail/fetchmail.pl
RUN chmod 644 /etc/cron.d/fetchmail

# Install php, git, perl
RUN apt-get install -y \
    perl \
    perl-modules \
    libdbi-perl \
    libclass-dbi-sqlite-perl \
    liblockfile-simple-perl \
    libsys-syslog-perl \
    php5-curl \
    php5-fpm \
    php5-gd \
    php5-intl \
    php5-mcrypt \
    php5-mysql \
    php5-sqlite \
    php5-xsl \
    php-mail \
    php-mail-mimedecode \
    php-pear \
    git

# Configure php
RUN rm -r /etc/php5/fpm/pool.d
COPY assets/etc/php5/fpm/php.ini /etc/php5/fpm/
COPY assets/etc/php5/fpm/php-fpm.conf /etc/php5/fpm/
COPY assets/nginx/default /etc/nginx/sites-enabled

COPY assets/bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*.sh

# Install Roundcube + plugins
RUN VERSION=`latestversion roundcube/roundcubemail` \
    && mkdir -p /var/www/html \
    && rm -r /var/www/html/* \
    && cd /var/www/html \
    && git clone --branch ${VERSION} --depth 1 https://github.com/roundcube/roundcubemail.git . \
    && rm -rf .git installer
RUN php -r "readfile('https://getcomposer.org/installer');" | php \
    && mv composer.phar /usr/local/bin/composer \
    && cd /var/www/html \
    && mv composer.json-dist composer.json \
    && composer config secure-http false \
    && composer require --update-no-dev \
        roundcube/plugin-installer:dev-master \
        roundcube/carddav \
        pf4public/fetchmail \
    && ln -sf ../../vendor plugins/carddav/vendor \
    && composer clear-cache

# Configure Roundcube
COPY assets/config.inc.php /var/www/html/config/
COPY assets/plugins-fetchmail-config.inc.php /var/www/html/plugins/fetchmail/config.inc.php
COPY assets/plugins-fetchmail-sqlite.initial.sql /var/www/html/plugins/fetchmail/SQL/sqlite.initial.sql
COPY assets/plugins-managesieve-config.inc.php /var/www/html/plugins/managesieve/config.inc.php
COPY assets/plugins-password-config.inc.php /var/www/html/plugins/password/config.inc.php
COPY assets/plugins-password-file.php /var/www/html/plugins/password/drivers/file.php

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
WORKDIR /var/www/html
