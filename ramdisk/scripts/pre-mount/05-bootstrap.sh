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

bootstrap () {
  if PATH=$ROOT_PATH chroot /root /debootstrap/debootstrap --second-stage; then
    /scripts/bootstrap-progress.sh success
  else
    /scripts/bootstrap-progress.sh error
  fi
}

if [ -d /root/debootstrap ]; then
  bootstrap | /scripts/bootstrap-progress.sh work
fi
