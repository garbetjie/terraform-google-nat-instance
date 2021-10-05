#!/usr/bin/env bash

apt-get install -y dante-server

cat <<EOT > /etc/danted.conf
logoutput: stderr
internal: ${address} port = ${port}
external: ${address}
clientmethod: none
socksmethod: none
debug: ${debug}
user.privileged: proxy
user.unprivileged: nobody
user.libwrap: nobody

%{~ for cidr in allowed_ranges ~}

client pass {
	from: ${cidr} port 1-65535 to: 0.0.0.0/0
	log: connect error
}

socks pass {
	from: ${cidr} to: 0.0.0.0/0
	log: connect error
}
%{ endfor ~}

client block {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect error
}

socks block {
	from: 0.0.0.0/0 to: 0.0.0.0/0
	log: connect error
}
EOT

systemctl restart danted