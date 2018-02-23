include:
  - zabbix.yum-repo

America/Chicago:
  timezone.system

selinux pkg installs:
  pkg.installed:
    - pkgs:
      - policycoreutils-python
      - selinux-policy-targeted

permissive:
    selinux.mode

httpd_can_connect_zabbix:
  selinux.boolean:
    - value: True
    - persist: True

httpd_can_network_connect_db:
  selinux.boolean:
    - value: True
    - persist: True

postgres server setup:
  pkg.installed:
    - pkgs:
      - postgresql-server
  postgres_initdb.present:
    - name: /var/lib/pgsql/data
    - auth: password
    - user: postgres
    - password: postgres
    - runas: postgres
  service.running:
    - name: postgresql
    - enable: True

postgresql zabbix user:
  postgres_user.present:
    - user: postgres
    - db_user: postgres
    - db_password: postgres
    - name: zabbix
    - password: zabbix
    - superuser: True

zabbix server setup:
  pkg.installed:
    - pkgs:
      - zabbix-server-pgsql
      - zabbix-web-pgsql

/var/lib/pgsql/.pgpass:
  file.managed:
    - mode: 600
    - user: postgres
    - group: postgres
    - contents: |
        # hostname:port:database:username:password
        127.0.0.1:5432:postgres:postgres:postgres
        127.0.0.1:5432:zabbix:zabbix:zabbix

postgresql zabbix database:
  postgres_database.present:
    - name: zabbix
    - owner: zabbix
    - owner_recurse: True
    - user: zabbix
    - db_user: postgres
    - db_password: postgres


load zabbix database:
  cmd.run:
    - name: 'zcat /usr/share/doc/zabbix-server-pgsql-3.4.7/create.sql.gz | sudo -u postgres psql -h 127.0.0.1 -U zabbix zabbix'
    - onchanges:
      - postgres_database: postgresql zabbix database


/etc/zabbix/zabbix_server.conf:
  file.managed:
    - backup: minion
    - user: zabbix
    - group: zabbix
    - mode: 640
    - contents: |
        LogFile=/var/log/zabbix/zabbix_server.log
        LogFileSize=0
        PidFile=/var/run/zabbix/zabbix_server.pid
        SocketDir=/var/run/zabbix
        DBHost=127.0.0.1
        DBName=zabbix
        DBUser=zabbix
        DBPassword=zabbix
        SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
        Timeout=4
        AlertScriptsPath=/usr/lib/zabbix/alertscripts
        ExternalScripts=/usr/lib/zabbix/externalscripts
        LogSlowQueries=3000

zabbix-server service:
  service.running:
    - name: zabbix-server
    - enable: True
    - watch:
      - file: /etc/zabbix/zabbix_server.conf

zabbix-server web frontend:
  service.running:
    - name: httpd
    - enable: True
    - watch:
      - file: /etc/httpd/conf.d/zabbix.conf
      - file: /etc/zabbix/web/zabbix.conf.php

/etc/httpd/conf.d/zabbix.conf:
  file.managed:
    - template: jinja
    - source: salt://zabbix/etc/httpd/conf.d/zabbix.conf
    - user: root
    - group: root
    - mode: 644

/etc/zabbix/web/zabbix.conf.php:
  file.managed:
    - source: salt://zabbix/etc/zabbix/web/zabbix.conf.php
    - user: root
    - group: root
    - mode: 644
