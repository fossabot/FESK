# FIREWALL EASY SETUP KIT
![](https://i.imgur.com/y4cBlEA.png)

## What is this?
FESK is a handy firewall with a configurable set of standard rules and quick port settings. Eg for testing Web instances or apps.

#### FESK was tested and works fine on:

##### SYSVINIT
* Debian 6.0 / Squeeze 
* Debian 7.0 / Wheezy 
* Debian 8.0 / Jessie 
* Ubuntu 10.04 LTS / Lucid
* Ubuntu 12.04 LTS / Precise
* Ubuntu 13.10 / Raring
* Ubuntu 14.04 LTS / Trusty
##### SYSTEMD
* Arch Linux
* Debian 8.0 / Jessie
* Debian 9.0 / Stretch
* Ubuntu 15.04 LTS / Vivid Vervet
* Ubuntu 15.10 / Wily Werewolf
* Ubuntu 16.04 / Xenial Xerus
* Ubuntu 16.10 / Yakkety Yak


####  Features
* rock solid defaults
* easy extendable
* one-line opening ports
* one line whitelisting ips
* one line blacklisting ips
* extensively documented (inline comments)

## Installation

### Easy Install
```
    git clone https://github.com/STROHMEYER/FESK.git
    cd FESK
    sudo ./install
```
To uninstall run:
```
    sudo ./install
```
### Manual install:

####Create necessary directories first

```
    sudo mkdir /etc/fesk
    sudo mkdir /etc/fesk/custom
```
####Checkout the github repo and install the files

```
    git clone https://github.com/STROHMEYER/FESK.git
    cd fesk

    # If your system running by systemd 
    sudo cp systemd/fesk.service /usr/lib/systemd/system/fesk.service
    sudo cp firewall /etc/fesk/firewall

    # If your system running by sysvinit
    sudo cp firewall /etc/init.d/firewall

    cd etc/fesk/
    sudo cp *.conf /etc/fesk/
```
####Make sure firewall is executable and update runnlevels
========
```
    # For systemd
    sudo chmod 644 /usr/lib/systemd/system/fesk.service
    sudo chmod 755 /etc/fesk/firewall
    sudo systemctl daemon-reload
```


```
    # For sysvinit
    sudo chmod 755 /etc/init.d/firewall
    sudo update-rc.d firewall defaults
``` 
## Configuration

All configuration-files are to be found at /etc/fesk/

Feel free to read the firewall-script itself and comment/uncomment what you like or dislike.

#### firewall.conf
Main firewall configfile. All settings are on sane defaults, you really should know what you do
if you change them.

#### services.conf
This file is used to open ports for services like ssh or http(s) in your firewall.

###### SYNTAX:

PORT/PROTOCOLL SOURCE
where SOURCE is the source ip or network

n.n.n.n/m - Where n.n.n.n is the IP address range and m is the bitmask.

if SOURCE is empty it defaults to 0.0.0.0/0 (which is any IP)

###### EXAMPLEs:

opens ports for SSH for IP 192.168.0.1:

    22/tcp 192.168.0.1
    22/udp 192.168.0.1

opens ports for HTTP for any IP

    80/tcp 0.0.0.0/0

opens ports for HTTPS for any IP

    443/tcp

#### ip-whitelist.conf:
Add all source IPs you want to have full access to this host.
One IP per line

###### SYNTAX:

n.n.n.n/m.m.m.m  - Where n.n.n.n is the IP address range and m.m.m.m is the netmask.

n.n.n.n/m - Where n.n.n.n is the IP address range and m is the bitmask.

###### EXAMPLEs:

    192.168.0.1
    192.168.1.0/8
    192.168.55.0/255.255.255.148
    
#### ip-blacklist.conf:
Add all source IPs you want to COMPLETELY BLOCK
One IP per line

###### SYNTAX:

n.n.n.n/m.m.m.m  - Where n.n.n.n is the IP address range and m.m.m.m is the netmask.

n.n.n.n/m - Where n.n.n.n is the IP address range and m is the bitmask.

###### EXAMPLEs:

    192.168.0.1
    192.168.1.0/8
    192.168.55.0/255.255.255.148
    
#### custom/*:
Every file/script you place here will be executed during firewall-start.
Place your custom rules in here.

There are some usefull examples in ./custom-examples/ that limit the ammount of new and overall connections.

## Usage

For sysvinit
=======
```
    /etc/init.d/firewall (start|stop|restart|reload|force-reload|status)
```

For systemd
=======
```
    systemctl (start|stop|restart) fesk
```

* start: starts the firewall
* stop: stops the firewall
* restart, reload, force-reload: restarts the firewall (all three the same)
* status: print out the status of the firewall, shows all entries in iptables