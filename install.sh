#!/bin/bash


# Am I root?
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
    R|REMOVE|r) pre=remove
    ;;
    U|UPDATE|u) pre=update
    ;;
    esac
    ;;
    install) 
    echo  Installing on $(head -n1 /etc/issue | cut -f 1 -d ' ')
    echo -n "Are you sure?[Y/N]: "
    read sure
    case "$sure" in
    y|Y) pre=install
    ;;
    n|N) exit 1
    ;;
    esac
    ;;
esac
final
}

function final {
case "$pre" in
    install) 

    case "$init" in
    systemd)
    mkdir /etc/iptables-remastered
    mkdir /etc/iptables-remastered/custom
    install -m 755 firewall /etc/iptables-remastered/firewall
    cp etc/firewall/*.conf /etc/iptables-remastered
    install -Dm644 systemd/rtables.service /usr/lib/systemd/system/rtables.service
    systemctl daemon-reload
    ;;
    sysvinit)
    mkdir /etc/iptables-remastered
    mkdir /etc/iptables-remastered/custom
    install -m 755 firewall /etc/init.d/firewall
    cp etc/firewall/*.conf /etc/iptables-remastered
    update-rc.d firewall defaults
    ;;
    esac
    echo "Installed"
    
    ;;
    update)

    case "$init" in
    systemd)
    systemctl stop rtables
    install -m 755 firewall /etc/iptables-remastered/firewall
    install -Dm644 systemd/rtables.service /usr/lib/systemd/system/rtables.service
    systemctl daemon-reload
    ;;
    sysvinit)
    /etc/init.d/firewall stop
    install -m 755 firewall /etc/init.d/firewall
    update-rc.d firewall defaults
    ;;
    esac
    echo "Updated, check new configuration and start your firewall"


    ;;
    remove)


    case "$init" in
    systemd)
    systemctl stop rtables
    systemctl disable rtables
    rm -rf /etc/iptables-remastered
    rm /usr/lib/systemd/system/rtables.service
    systemctl daemon-reload
    ;;
    sysvinit)
    /etc/init.d/firewall stop
    rm -rf  /etc/iptables-remastered
    rm /etc/init.d/firewall
    ;;
    esac
    echo "Removed"
    ;;
esac
}

pre-install