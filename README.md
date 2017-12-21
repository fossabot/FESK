FESK - Firewall Easy Setup Kit
==========

Ready package for Archlinux
--------------------------
Starting from 23.11.2017, ready package, is available **[on our github](https://github.com/Entframe/FESK-Archlinux)**.

Table of contents
-----------------

- [Introduction](#introduction)
- [Known issues](#known-issues)
- [Supported distributions](#supported-distributions)
  - [SYSVINIT](#sysvinit)
  - [SYSTEMD](#systemd)
- [Installation](#installation)
  - [Uninstallation](#uninstallation)
  - [Manual install](#manual-Installation)
- [Configuration](#configuration)
  - [firewall.conf](#firewall.conf)
  - [services.conf](#services.conf)
  - [SYNTAX](#syntax)
- [Usage](#usage)
- [FESK-utils](#fesk-utils)
- [Credits](#credits)
  - [Special Thanks](#special-thanks)

Introduction
------------
![](https://i.imgur.com/y4cBlEA.png)

FESK is a handy firewall with a configurable set of standard rules and quick port settings.
For example: for testing Web instances or apps.

Known issues
------------
At this time we haven't any issues reported

Supported distributions
------------

### SYSVINIT
* Debian 6.0 / Squeeze
* Debian 7.0 / Wheezy
* Debian 8.0 / Jessie
* Ubuntu 10.04 LTS / Lucid
* Ubuntu 12.04 LTS / Precise
* Ubuntu 13.10 / Raring
* Ubuntu 14.04 LTS / Trusty

### SYSTEMD
* Arch Linux(Has PKGBUILD support)
* Debian 8.0 / Jessie
* Debian 9.0 / Stretch
* Ubuntu 15.04 LTS / Vivid Vervet
* Ubuntu 15.10 / Wily Werewolf
* Ubuntu 16.04 / Xenial Xerus
* Ubuntu 16.10 / Yakkety Yak

Installation
------------
Firstfully, you need to clone our repo and run `install.sh`:

```
git clone https://github.com/Entframe/FESK.git
cd FESK
sudo ./install # Yes, with sudo
```

### Uninstallation

To uninstall run:
```
    sudo ./install
```

### Manual Installation

```
# Create important directories

sudo mkdir -p /etc/fesk/custom

# Clone our repo

git clone https://github.com/Entframe/FESK.git && cd FESK

# If your system running by systemd
sudo install -Dm644 systemd/fesk.service /usr/lib/systemd/system/fesk.service
sudo install -m 755 firewall /etc/fesk/firewall

# If your system running by sysvinit
sudo install -m 755 firewall /etc/fesk/firewall
# Create symlink to init.d directory
sudo ln /etc/fesk/firewall /etc/init.d/fesk

# Copy rules
sudo cp etc/fesk/*.conf /etc/fesk/

# Reload rules

# For systemd
sudo systemctl daemon-reload

# For sysvinit
sudo update-rc.d firewall defaults
```

Configuration
------------
All configuration-files are located in `/etc/fesk` directory

Feel free to edit the firewall-script itself and comment/uncomment what you like/dislike.

### firewall.conf
Main firewall configfile. All settings are on sane defaults, you really must know what you doing.

### services.conf
This file is used to open ports for services like ssh or http(s) in your firewall.

### ip-whitelist.conf
Add all source IPs you want to have full access to this host. One IP per line

### ip-blacklist.conf
Same as whitelist.

Add all source IPs you want to COMPLETELY BLOCK
One IP per line

### custom-rules
Every file/script you place here will be executed during firewall-start.
Place your custom rules in here.

There are some usefull examples in ./custom-examples/ that limit the ammount of new and overall connections.

### SYNTAX

PORT/PROTOCOLL SOURCE
where SOURCE is the source ip or network

n.n.n.n/m - Where n.n.n.n is the IP address range and m is the bitmask.

if SOURCE is empty it defaults to 0.0.0.0/0 (which is any IP)

### Examples:

opens ports for SSH for IP 192.168.0.1:
```
    22/tcp 192.168.0.1
    22/udp 192.168.0.1
```
opens ports for HTTP for any IP
```
    80/tcp 0.0.0.0/0
```
opens ports for HTTPS for any IP
```
    443/tcp
```

Usage
------------

#### For sysvinit
```
    /etc/init.d/firewall (start|stop|restart|reload|force-reload|status)
```

#### For systemd
```
    systemctl (start|stop|restart) fesk

    # To get status you shall execute main buildscripts
    /etc/fesk/firewall status
```

* start: starts the firewall
* stop: stops the firewall
* restart, reload, force-reload: restarts the firewall (all three the same)
* status: print out the status of the firewall, shows all entries in iptables

FESK-Utils
------------
I've writed small script for Simplifying Life

They located in `fesk-utils` directory. Main script and installer

You need to have `CMake` and `Make` installed to compile C library

Credits
------------
We used @bmaeser's iptables-boilerplace as base. And this project isn't a fork, we decided to make another for searching proposes

FESK project is Free Software, licensed under version 2 of the **GNU General Public License**. All information about license, contributors etc., are included with sources, inside *our* repo.

### Special Thanks
 - Thanks to Bmaeser for his codebase for our project (@bmaeser)
 - Thanks to @AMDmi3 and @repology for their great libversion tool that we used in fesk-utils
