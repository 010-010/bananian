# Bananian - Debian for the Nokia 8110 4G and a UI
### Compiling
Just run make. If it complains about missing compilers, make sure your ARM
cross-compiler is named arm-linux-gnueabi-gcc or arm-linux-gnueabi-gcc-_version_.
### Installing
Create two partitions on your SD card. Format the first one as FAT and the
second as EXT4. Push boot.img to the phone and flash it to boot or recovery:

    (on your phone)
    # dd if=boot.img of=/dev/block/bootdevice/by-name/<boot or recovery>

### Wireless networking
To enable WiFi networking, create a file named debroot/etc/wpa\_supplicant.conf
before compiling and add the following contents:

    network={
        ssid="[your network name]"
        psk="[your network password]"
    }

### Shell access
You need to enable networking first.
To get shell access to your phone, find out its IP address via your router. Then:

    $ ssh root@X.X.X.X # Where X.X.X.X is your the phone's IP address

You should be asked for a password. The password is bananian.
### Window list
To show a list of open windows, press the power button with the slide open.
### Bugs
There some bugs and many things aren't implemented yet.
Here is one bug:
 - The display is very glitchy because some parts don't get refreshed.
 - Color Grid app does not work

Please report other bugs as an issue.
