#!/bin/bash

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

function initcheck {
case $(ps --no-headers -o comm 1) in
    systemd) init=systemd ;;
    init) init=sysvinit ;;
    *) echo "Unsuported distro. However, you could try to install manually by using Makefile. Also, manuals located in README.md" && exit 1 ;;
esac
}

function core() {
case "$1" in
    install)
    mkdir -p /etc/fesk/custom
    mkdir /etc/fesk/post_down
    touch /etc/fesk/post_down/sequence.sh && chmod +x /etc/fesk/post_down/sequence.sh
    cp etc/fesk/*.conf /etc/fesk
    install -m 755 firewall /etc/fesk/firewall
    install -m 755 fesk-utils/fesk-utils.py /etc/fesk/fesk-utils.py
    ln -s /etc/fesk/fesk-utils.py /bin/fesk-utils
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
    install -m 755 fesk-utils/fesk-utils.py /etc/fesk/fesk-utils.py
    ln -s /etc/fesk/fesk-utils.py /bin/fesk-utils
    if [ "$init" == "systemd" ]; then
    systemctl stop fesk
    install -Dm644 systemd/fesk.service /usr/lib/systemd/system/fesk.service
    systemctl daemon-reload
    elif [ "$init" == "sysvinit" ]; then
    /etc/init.d/fesk stop
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
    update-rc.d -f fesk remove
    fi
    rm /bin/fesk-utils
    echo "Removed" ;;
esac
}

initcheck

case "$1" in
  "--update") core update && exit ;;
esac

if [ ! -f "/etc/fesk/firewall" ]; then
echo -n "FESK is going to install, are you sure?[Y/N]: "
read sure
case "$sure" in
    y|Y) core install ;;
    n|N) exit 1 ;;
esac
else
eval $(grep FESK_VERSION= /etc/fesk/firewall)
echo "Fesk $FESK_VERSION already installed on this device"
echo -n "Do you want to [U]pdate, [R]emove or Ca[N]cel it? [U/R/N]: "
read going_to
case "$going_to" in
    R|r) core remove ;;
    U|u) core update ;;
    *) echo "Operation cancelled" && exit 1 ;;
esac
fi
