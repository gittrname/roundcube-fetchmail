#!/bin/sh

mkdir -p /var/mail/roundcube
php /var/www/html/bin/initdb.sh --dir=/var/www/html/SQL
php /var/www/html/bin/initdb.sh --dir=/var/www/html/plugins/fetchmail/SQL
chown www-data:www-data -R /var/mail/roundcube
chown www-data:www-data /var/www/html/logs

mkdir -p /var/run/fetchmail

echo mydomain = $ROUNDCUBE_USERNAME_DOMAIN >> /etc/postfix/main.cf
echo myorigin = \$mydomain >> /etc/postfix/main.cf
sed -i "s|^myhostname\s*=.*$|myhostname = $HOSTNAME|g" /etc/postfix/main.cf
sed -i "s|^relayhost\s*=.*$|relayhost = [$ROUNDCUBE_SMTP_SERVER]|g" /etc/postfix/main.cf
