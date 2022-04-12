#!/sbin/sh

if [ ! -f /root/lib/modules/$(uname -r)/modules.dep ]; then
  chroot /root /sbin/depmod
fi
