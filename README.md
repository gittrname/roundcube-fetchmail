# Roundcube
---
Made because I needed a simple roundcube latest version installation.  

I myself use environment variables for configuration:
---
    ROUNDCUBE_USERNAME_DOMAIN=example.loc
    ROUNDCUBE_DEFAULT_HOST=tls://dovecot
    ROUNDCUBE_SMTP_SERVER=tls://postfix
    ROUNDCUBE_PRODUCT_NAME='MyDomain - Webmail'

## Mapping
For Mapping these locations are used:

    /var/mail/roundcube/sqlite.db
