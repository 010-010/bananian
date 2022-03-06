gitlab_kernel () {
  wget -OzImage-dl.zip "https://gitlab.com/$1/-/jobs/artifacts/$2/download?job=build"
  unzip zImage-dl.zip -d zImage-files
  cp zImage-files/arch/arm/boot/zImage-dtb zImage
  cp -rf zImage-files/tmp_modules/lib/modules zImage-modules
  rm -rf zImage-files zImage-dl.zip
}
