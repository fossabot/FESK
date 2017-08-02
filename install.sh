#!/bin/bash
# Include bootstrap lib
source bin/bootstrap.function

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

function distrocheck {
case $(head -n1 /etc/issue | cut -f 1 -d ' ') in
    Arch) export init=systemd
    ;;
    Debian | Ubuntu)    
    eval $(grep VERSION_ID= /etc/os-release)
    case "$VERSION_ID" in
        7 | 6 | 5) export init=sysvinit ;;
        8 | 9) export init=systemd ;;
        14.04 | 13.10 | 12.04 | 10.04) export init=sysvinit ;;
        15.04 | 15.10 | 16.04 | 16.10) export init=systemd ;;
        *) echo "Currently $VERSION_ID is not supported, please report it in ISSUES on github" && exit 1 ;;
    esac
    ;;
    *) echo "Unsuported distro, you can read documentation in README.md to install this manually" && exit 1
esac
}

function pre-install {
distrocheck

case "$init" in
    systemd) path="/etc/iptables-remastered/firewall" ;;
    sysvinit) path="/etc/init.d/firewall" ;;
    esac

if [ -f "$path" ]; then
    op=ask
else
    op=install
fi

case "$op" in
    ask) 
    echo -n "This project already installed. Do you wan't to update it or remove?[U/R]: "
    read install
    case "$install" in
    R|REMOVE|r) export pre=remove
    ;;
    U|UPDATE|u) export pre=update
    ;;
    esac
    ;;
    install) 
    echo  Installing on $(head -n1 /etc/issue | cut -f 1 -d ' ')
    echo -n "Are you sure?[Y/N]: "
    read sure
    case "$sure" in
    y|Y) export pre=install
    ;;
    n|N) exit 1
    ;;
    esac
    ;;
esac
install
}

pre-install