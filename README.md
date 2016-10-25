# Roundcube
---
jpco/roundcubeにfetchmail, carddav, managesieveの３つのプラグインを追加したもの 

■設定例
---
    version: '2'
    services:
      roundcube:
      build: roundcube
      container_name: roundcube
      ports:
        - "80:80"
    extra_hosts:
      - "fetch.example.com:127.0.0.1"
    environment:
      - "ROUNDCUBE_DEFAULT_HOST=imap.example.com"
      - "ROUNDCUBE_SMTP_SERVER=smtp.example.com"
      - "ROUNDCUBE_USERNAME_DOMAIN=example.com"
      - "HOSTNAME=fetchmail.example.com"

