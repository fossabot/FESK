#!/bin/bash

# DNS rules and port forwarding for LXC
## Kurt Strohmeyer - https://github.com/Strohmeyer

IPTABLES="/sbin/iptables"

EXT_IF="eth0"
EXT_IP=$(ifconfig eth0 | grep inet | grep -v inet6 | grep -v 127.0.0.1 | cut -d: -f2 | awk '{printf $1}')
LX_IF="lxcbr0"
LX_IP_AUTO=$(ifconfig lxcbr0 | grep inet | grep -v inet6 | grep -v 127.0.0.1 | cut -d: -f2 | awk '{printf $1}')
LX_IP="10.0.3.1"
LX_NET="10.0.3.0/24"
HOST_N1="10.0.3.25"
HOST_N2="10.0.3.102"
# Forwarding accept and DNS rules
$IPTABLES -A FORWARD -o lxcbr0 -j ACCEPT
$IPTABLES -A FORWARD -i lxcbr0 -j ACCEPT
$IPTABLES -A INPUT -i lxcbr0 -p tcp -m tcp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i lxcbr0 -p udp -m udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i lxcbr0 -p tcp -m tcp --dport 67 -j ACCEPT
$IPTABLES -A INPUT -i lxcbr0 -p udp -m udp --dport 67 -j ACCEPT

# NAT chain
$IPTABLES -t nat -A PREROUTING -d $EXT_IP/31 -p tcp -m tcp --dport 80 -j DNAT --to-destination $HOST_N1:80

$IPTABLES -t nat -A PREROUTING -d $EXT_IP/31 -p udp -m udp --dport 1812 -j DNAT --to-destination $HOST_N2:1812

# Masquerade rules for LXC-network
$IPTABLES -t nat -A POSTROUTING -s 10.0.3.0/24 ! -d 10.0.3.0/24 -j MASQUERADE
