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

set -e

find_part () {
  cd /sys/block/mmcblk0
  for part in mmcblk0p*; do
    if grep -qxF "PARTNAME=$1" $part/uevent; then
      echo /dev/$part
      return
    fi
  done
}

mount_part () {
  mount -o ro -t $1 $(find_part $2) /mnt
}

set +e
# Ignore errors from now on. The system might still boot if some of the
# copying fails, and we must try to copy everything

mkdir -p /root/lib/firmware

if [ ! -f /root/lib/firmware/FW_COPIED ]; then
  mount_part vfat modem
  cp -rf /mnt/image/* /root/lib/firmware/
  umount /mnt
  :>/root/lib/firmware/FW_COPIED
fi

if [ ! -f /root/lib/firmware/SYS_COPIED ]; then
  mount_part ext4 system
  cp -rf /mnt/etc/firmware/* /root/lib/firmware/
  rm -f /root/lib/firmware/wlan/prima/WCNSS_qcom_cfg.ini
  cp -f /mnt/etc/wifi/WCNSS_qcom_cfg.ini /root/lib/firmware/wlan/prima/
  rm -f /root/lib/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin
  rm -f /root/lib/firmware/wlan/prima/WCNSS_wlan_dictionary.dat
  umount /mnt
  :>/root/lib/firmware/SYS_COPIED
fi

if [ ! -f /root/lib/firmware/PERSIST_COPIED ]; then
  mount_part ext4 persist
  cp -rf /mnt/WCNSS_qcom_wlan_nv.bin /mnt/WCNSS_wlan_dictionary.dat \
    /root/lib/firmware/wlan/prima/
  umount /mnt
  :>/root/lib/firmware/PERSIST_COPIED
fi
