#!/bin/sh
setenv.sh

echo starting php service
/etc/init.d/php5-fpm start

echo starting cron service
/etc/init.d/cron start

echo starting postfix service
/etc/init.d/postfix start

echo starting rsyslog service
/etc/init.d/rsyslog start

exec "$@"
