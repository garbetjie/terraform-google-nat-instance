#!/usr/bin/env bash

apt-get install -y tinyproxy

cat <<EOT > /etc/tinyproxy/tinyproxy.conf
User tinyproxy
Group tinyproxy
Port ${port}
Listen ${address}
BindSame yes
Timeout ${timeout}
MaxClients ${max_connections}
StatHost "tinyproxy.stats"
Syslog On
LogLevel Info
PidFile "/run/tinyproxy/tinyproxy.pid"
MinSpareServers ${min_spare}
MaxSpareServers ${max_spare}
StartServers 10
MaxRequestsPerChild 100
Allow 10.0.0.0/8
ViaProxyName "tinyproxy"
#ConnectPort 443
#ConnectPort 563

XTinyproxy Yes
EOT

systemctl reload tinyproxy
