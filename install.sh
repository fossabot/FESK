#!/bin/bash

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

function distrocheck {
eval $(grep ID= /etc/os-release)
case "$ID" in
    arch) init=systemd
    ;;
    debian | ubuntu)
    eval $(grep VERSION_ID= /etc/os-release)
    case "$VERSION_ID" in
        7 | 6 | 5) echo "Detected Debian $VERSION_ID" && init=sysvinit ;;
        8 | 9) echo "Detected Debian $VERSION_ID" && init=systemd ;;
        14.04 | 13.10 | 12.04 | 10.04) echo "Detected Ubuntu $VERSION_ID" && init=sysvinit ;;
        15.04 | 15.10 | 16.04 | 16.10) echo "Detected Ubuntu $VERSION_ID" && init=systemd ;;
        *) echo Currently $ID $VERSION_ID is not supported
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
    mkdir /etc/fesk/post_down
    touch /etc/fesk/post_down/sequence.sh
    chmod +x /etc/fesk/post_down/sequence.sh
    cp etc/fesk/*.conf /etc/fesk
    install -m 755 firewall /etc/fesk/firewall

    if [ "$init" == "systemd" ]; then
    install -Dm644 systemd/fesk.service /usr/lib/systemd/system/fesk.service
    systemctl daemon-reload
    elif [ "$init" == "sysvinit" ]; then
    ln -s /etc/fesk/firewall /etc/init.d/fesk
    update-rc.d fesk defaults
    fi

    echo "Installed" ;;
    update)

    install -m 755 firewall /etc/fesk/firewall

    if [ "$init" == "systemd" ]; then
    systemctl stop fesk
    install -Dm644 systemd/fesk.service /usr/lib/systemd/system/fesk.service
    systemctl daemon-reload
    elif [ "$init" == "sysvinit" ]; then
    /etc/init.d/fesk stop
    ln -s /etc/fesk/firewall /etc/init.d/fesk
    update-rc.d fesk defaults
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
    /etc/init.d/fesk stop
    rm -rf /etc/fesk
    rm /etc/init.d/fesk
    fi
    echo "Removed" ;;
esac
}

# ========================================================

distrocheck

if [ -f "/etc/fesk/firewall" ]; then
  eval $(grep FESK_VERSION= /etc/fesk/firewall)
  echo "fesk $FESK_VERSION already installed."
  echo -n "Do you want to [U]pdate, [R]emove or Ca[N]cel it? [U/R/N]: "
  read going_to
else
  echo "FESK project is going to install"
  echo -n "Are you sure? [y/N]: "
  read sure
  case "$sure" in
    y|Y) echo Installing on $ID ;;
    *) exit 1 ;;
  esac
  going_to=install
fi

case "$going_to" in
    R|REMOVE|r) operation=remove ;;
    U|UPDATE|u) operation=update ;;
    install) operation=install ;;
    *) echo "Operation cancelled" && exit 1 ;;
    esac
install_funct
