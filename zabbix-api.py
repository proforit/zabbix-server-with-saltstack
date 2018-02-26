#!/usr/bin/env python
#
# Zabbix API Python usage example
# Christoph Haas <email@christoph-haas.de>
#
import zabbix_api
import sys
from datetime import datetime, timedelta
import time

username='Admin'
password='zabbix'
zabbix_url='http://localhost/zabbix/api_jsonrpc.php'
yesterday = datetime.now() - timedelta(days=1)
yesterdaystr=str(int(time.mktime(yesterday.timetuple())))

# Connect to Zabbix server
z=zabbix_api.ZabbixAPI(server=zabbix_url)
z.login(user=username, password=password)


# Get jsontest key data
jsontest = z.history.get(
{
    "output": "extend",
    "history": "4",
    "itemids": ["28250"],
    "sortfield": "clock",
    "sortorder": "DESC",
    "time_from": yesterdaystr
}
)

# Return the last entry
print(jsontest[0])
