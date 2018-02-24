include:
  - zabbix.yum-repo

zabbix agent setup:
  pkg.installed:
    - pkgs:
      - zabbix-agent
      - zabbis-sender
  service.running:
    - name: zabbix-agent
    - enable: True
