# Install dependencies
Install build tools (skip if already installed):

    $ sudo apt install build-essential

Note: this example assumes you are using a Debian-based Linux distro. If you
are using some other system, it probably has a different package manager. The
package names might also differ, so do a package search first.

Install GCC 4.9.4 dependencies:

    $ sudo apt install libgmp-dev libmpc-dev libmpfr-dev crossbuild-essential-armhf

Download GCC 4.9.4 <ftp://ftp.gnu.org/gnu/gcc/gcc-4.9.4/gcc-4.9.4.tar.gz>
into your current directory

Compile GCC 4.9.4:

```sh
$ tar xf gcc-4.9.4.tar.gz
$ cd gcc-4.9.4
$ mkdir bld
$ cd bld
$ CFLAGS_FOR_TARGET='-g -O2 -mfloat-abi=hard -D__ARM_PCS_VFP' \
  $(pwd)/../configure --prefix=/usr \
  --target=arm-linux-unknown-gnueabi \
  --enable-languages=c,c++
$ make all-gcc
$ sudo make install-gcc
$ cd ..
```

# Compiling the forked kernel

Clone the kernel from <https://gitlab.com/bananian/kernel-nokia-8110>
recursively:

```sh
$ git clone --recursive https://gitlab.com/bananian/kernel-nokia-8110
```

Compile the kernel:

```sh
$ cd kernel
$ cp kernel-config .config
$ make menuconfig ARCH=arm
  < add/remove some configuration options >
$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- TARGET_PRODUCT=argon
```

The produced file `arch/arm/boot/zImage` is the kernel.
Since this is the official stock kernel and the configuration is based on
/proc/config.gz on the phone, this kernel should work with KaiOS, except for
some minor incompatibilities (like the slide not working)
Note that you have to replace the modules in /system/lib/modules if you want to
use it with KaiOS.

# Compiling the CodeAurora kernel (no longer supported)

Download kernel:

    $ git clone -b LF.BR.1.2.8 https://source.codeaurora.org/quic/la/kernel/msm-3.10 kernel

Download <https://gitlab.com/bananian/bananian/-/raw/master/kernel-config>
into the kernel.

Add Prima WLAN kernel module:

```sh
$ cd kernel/drivers/net/wireless
$ git clone https://gitlab.com/affenull2345/prima-wlan prima
$ echo 'obj-$(CONFIG_PRIMA) += prima/' >> Makefile
$ echo 'source "drivers/net/wireless/prima/Kconfig"' >> Kconfig
$ cd ../../../..
```

Compile kernel:

```sh
$ cd kernel
$ cp kernel-config .config
$ make menuconfig ARCH=arm
  < add/remove some configuration options >
$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
$ cat dtb arch/arm/boot/zImage > zImage
```

The zImage file is the kernel, you can now put it into a bootimage and flash it.
WARNING: This kernel does not work with KaiOS. It crashes on boot.
