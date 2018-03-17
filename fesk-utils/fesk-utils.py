#!/bin/python
# This file is part of FESK project
# Copyright (C) 2018  EntFrame

# FESK-Utils program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import os, getpass, sys
import subprocess
import argparse
from git import Repo
from distutils.version import LooseVersion, StrictVersion
from shutil import rmtree

class MAINW:
    __fesk_lexe = "/etc/FESK/firewall"
    __local_argv = None
    __whoami = ""

    def __init__(self):
        self.__whoami = getpass.getuser()
        if self.__whoami != 'root':
            print("You're running without root privileges, exiting...")
            sys.exit(1)
        if os.path.exists(self.__fesk_lexe):
            self.__local_argv = argparse.ArgumentParser()
            self.__local_argv.add_argument("-U", "--update", help='Calls update function', action="store_true")
            self.__local_argv.add_argument("-S", "--status", help='Shows FESK status', action="store_true")
            self.parse(self.__local_argv.parse_args())
        else:
            print("FESK isn't installed. Exiting...")
            sys.exit(1)

    def parse(self,args):
        if args.update:
            self.update()
        elif args.status:
            subprocess.call([self.__fesk_lexe,"status"])
        else:
            self.__local_argv.print_help()

    def update(self):
        print('Checking for updates...')
        print('Downloading upstream sources...')
        Repo.clone_from("https://github.com/Entframe/FESK.git", "/tmp/FESK")
        
        fesk_local_ver = subprocess.run([self.__fesk_lexe, 'version'], stdout=subprocess.PIPE, universal_newlines=True)
        fesk_upstream_ver = subprocess.run(['/tmp/FESK/firewall', 'version'], stdout=subprocess.PIPE, universal_newlines=True)
        
        print('Installed version is: ', fesk_local_ver.stdout)
        print('Upstream version is: ', fesk_upstream_ver.stdout)
        
        compare = LooseVersion(fesk_local_ver.stdout) < LooseVersion(fesk_upstream_ver.stdout)
        if compare == True:
            print('Updating to latest...')
            subprocess.call(['/tmp/FESK/install.sh', '--update'])
            print('Everything is OK, removing TEMP files and exiting...')
        else: 
            print("There's nothing to do")
        rmtree("/tmp/FESK")

classcall = MAINW()
