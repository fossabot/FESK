#!/bin/bash

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

if [ ! -f "/etc/fesk/utils/feskd" ]; then
echo -n "Do you want to install fesk-utils and build dependencies?[Y/N]: "
read sure
case "$sure" in
  y|Y)
  git clone https://github.com/repology/libversion.git && cd libversion/
  cmake . && make .
  cd version_compare
  make 
  if [ -f "version_compare" ]; then
  cd ../../
  mv libversion/version_compare/version_compare ./
  rm -rf libversion
  mkdir /etc/fesk/utils/
  install -m 755 feskd /etc/fesk/utils/feskd
  install -m 755 version_compare /etc/fesk/utils/version_compare
  ln /etc/fesk/utils/feskd /bin/feskd
  fi
  ;;
esac
fi
