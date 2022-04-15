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

periodic_blink () {
  while true; do
    echo 255 > /sys/class/leds/button-backlight/brightness
    sleep 1
    echo 0 > /sys/class/leds/button-backlight/brightness
    sleep 1
  done
}

case "$1" in
  work)
    periodic_blink &
    while read line; do
      echo '<bootstrap>' "$line"
    done
    kill %
    ;;
  error)
    sync
    for step in 0 1 2 3 4; do
      echo 255 > /sys/class/leds/button-backlight/brightness
      echo 500 > /sys/class/timed_output/vibrator/enable
      sleep 0.5
      echo 0 > /sys/class/leds/button-backlight/brightness
      sleep 0.5
    done
    ;;
  success)
    echo 100 > /sys/class/timed_output/vibrator/enable
    ;;
  *)
    echo '<bootstrap-progress> invalid cmd' "$1"
esac
