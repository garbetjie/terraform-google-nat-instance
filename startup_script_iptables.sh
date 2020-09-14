#!/usr/bin/env bash

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

apt-get install -y nftables
nft add rule nat POSTROUTING masquerade
