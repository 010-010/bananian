#!/sbin/sh
# Copyright (C) 2020-2021 Affe Null <affenull2345@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

ROOT_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

setup () {
  PATH=$ROOT_PATH chroot /root /bin/bash -c 'cd /var/cache/bananian-bootstrap && dpkg -i *.deb && rm -f *.deb && adduser --gecos "Bananian User" --disabled-password user && adduser user sudo && addgroup --system ofono && adduser user ofono && adduser user audio && adduser user video && (echo user:bananian | chpasswd user) && touch /var/log/bananian/setup.stamp'
  if [ "$?" = 0 ]; then
    /scripts/bootstrap-progress.sh success
  else
    /scripts/bootstrap-progress.sh error
  fi
}

if [ ! -f /root/var/log/bananian/setup.stamp ]; then
  setup | /scripts/bootstrap-progress.sh work
fi
