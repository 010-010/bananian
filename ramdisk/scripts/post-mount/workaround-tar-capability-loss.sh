#!/bin/sh

chroot /root /sbin/setcap cap_block_suspend=pe /usr/bin/bananui-compositor
