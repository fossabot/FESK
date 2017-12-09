#!/bin/bash
# Sudokamikaze - https://github.com/Sudokamikaze

# Please, read this information, before you start https://wiki.archlinux.org/index.php/WireGuard#Server_2
# You need to setup your wireguard configs like in Archwiki

# Open port for Wireguard
# ipv4 forwarding has to be enabled!
# UDP port will be opened: 51820

# Please, change these variables
# They provided as example
INT="enp0s25"

IPTABLES=/sbin/iptables

$IPTABLES -A INPUT -i $INT -p tcp -m udp --dport 51820 -j ACCEPT
