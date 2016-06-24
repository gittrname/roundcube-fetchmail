#!/bin/sh
setenv.sh

echo starting service
/etc/init.d/php5-fpm start

exec "$@"
