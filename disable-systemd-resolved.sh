#!/bin/bash

##########################################################################
# Copyright (C) 2021  Philipp Wurm <phiwu@gmx.at>
#
# This program is free software: you can redistribute it and/or modify
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################

OS_RELEASE=`awk -F= '$1=="ID" { print $2 ;}' /etc/os-release`
OS_RELEASE_ID=`awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release`

if [ "$OS_RELEASE" == "fedora" ] && [ "$OS_RELEASE_ID" == "33" ]; then

    # check if service is running
    STATUS="$(systemctl is-active systemd-resolved.service)"

    if [ "${STATUS}" = "active" ]; then

        # switch to sudo
        [ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

        # remove existing resolv.conf
        rm -f /etc/resolv.conf
        echo -e "deleted /etc/resolv.conf ...\n"

        # link NetworkManager resolv.conf
        ln -sf /run/NetworkManager/resolv.conf /etc/resolv.conf
        echo -e "linked /run/NetworkManager/resolv.conf --> /etc/resolv.conf ...\n"

        # disable systemd-resolved service
        systemctl disable --now systemd-resolved.service
        echo -e "disabled systemd-resolved service ...\n"

        # disable loading systemd-resolved by any service
        systemctl mask systemd-resolved.service
        echo -e "masked systemd-resolved service to disable loading service by any other server ...\n"
        
        echo -e "done ... now reboot your system\n"
    else
        echo "systemd-resolved is not running. Nothing to do ..."
    fi
else
    echo "Fedora version 33 is required!"
fi