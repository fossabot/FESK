#!/bin/bash

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

function distrocheck {
case $(head -n1 /etc/issue | cut -f 1 -d ' ') in
    Arch) init=systemd
    ;;
    Debian | Ubuntu)    
    eval $(grep VERSION_ID= /etc/os-release)
    case "$VERSION_ID" in
        7 | 6 | 5) init=sysvinit ;;
        8 | 9) init=systemd ;;
        14.04 | 13.10 | 12.04 | 10.04) init=sysvinit ;;
        15.04 | 15.10 | 16.04 | 16.10) init=systemd ;;
        *) echo Currently $(head -n1 /etc/issue | cut -f 1 -d ' ') $VERSION_ID is not supported
        echo Please report it in ISSUES on github && exit 1 ;;
    esac
    ;;
    *) echo "Unsuported distro. However, you can try to install this manually by using Makefile, manual located at README.md" && exit 1 ;;
esac
}

function install_funct {
case "$operation" in
    install) 
    mkdir /etc/fesk
    mkdir /etc/fesk/custom
    cp etc/fesk/*.conf /etc/fesk
    install -m 755 firewall /etc/fesk/firewall

    if [ "$init" == "systemd" ]; then
    install -Dm644 systemd/fesk.service /usr/lib/systemd/system/fesk.service
    systemctl daemon-reload
    elif [ "$init" == "sysvinit" ]; then
    ln -s /etc/fesk/firewall /etc/init.d/firewall
    update-rc.d firewall defaults
    fi

    echo "Installed" ;;
    update)

    install -m 755 firewall /etc/fesk/firewall

    if [ "$init" == "systemd" ]; then
    systemctl stop fesk
    install -Dm644 systemd/fesk.service /usr/lib/systemd/system/fesk.service
    systemctl daemon-reload
    elif [ "$init" == "sysvinit" ]; then
    /etc/init.d/firewall stop
    ln -s /etc/fesk/firewall /etc/init.d/firewall
    update-rc.d firewall defaults
    fi
    echo "Updated, check new configuration and start your firewall" ;;
    remove)


    if [ "$init" == "systemd" ]; then
    systemctl stop fesk
    systemctl disable fesk
    rm -rf /etc/fesk
    rm /usr/lib/systemd/system/fesk.service
    systemctl daemon-reload
    elif [ "$init" == "sysvinit" ]; then
    /etc/init.d/firewall stop
    rm -rf  /etc/fesk
    rm /etc/init.d/firewall
    fi
    echo "Removed" ;;
esac
}

# ========================================================

distrocheck

if [ -f "/etc/fesk/firewall" ]; then
    going_to=ask
else
    going_to=install
fi

case "$going_to" in
    ask) 
    echo "fesk already installed."
    echo -n "Do you want to update or remove it?[U/R]: "
    read install
    case "$install" in
    R|REMOVE|r) operation=remove ;;
    U|UPDATE|u) operation=update ;;
    esac
    ;;
    install) 
    echo "Iptables-boilderplate project is going to install"
    echo -n "Are you sure?[Y/N]: "
    read sure
    case "$sure" in
    y|Y) echo Installing on $(head -n1 /etc/issue | cut -f 1 -d ' ')
    operation=install ;;
    *) exit 1 ;;
    esac
    ;;
esac
install_funct