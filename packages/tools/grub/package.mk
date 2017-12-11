################################################################################
#      This file is part of LibreELEC - https://libreelec.tv
#      Copyright (C) 2016-present Team LibreELEC
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="grub"
PKG_VERSION="2.02"
PKG_ARCH="x86_64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://www.gnu.org/software/grub/index.html"
PKG_URL="http://git.savannah.gnu.org/cgit/grub.git/snapshot/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_HOST="freetype"
PKG_DEPENDS_TARGET="toolchain flex freetype:host grub:host"
PKG_SECTION="tools"
PKG_SHORTDESC="GNU GRUB is a Multiboot boot loader."
PKG_LONGDESC="GNU GRUB is a Multiboot boot loader that was derived from GRUB, the GRand Unified Bootloader, which was originally designed and implemented by Erich Stefan Boleyn"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

  unset CFLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset LDFLAGS

pre_build_host() {
  mkdir -p $PKG_BUILD/.$HOST_NAME
  cp -RP $PKG_BUILD/* $PKG_BUILD/.$HOST_NAME
}

pre_build_target() {
  mkdir -p $PKG_BUILD/.$TARGET_NAME
  cp -RP $PKG_BUILD/* $PKG_BUILD/.$TARGET_NAME
}

pre_configure_host() {
  unset CPP
  strip_lto
  cd $PKG_BUILD/.$HOST_NAME
     ./autogen.sh
}

pre_configure_target() {
  unset CPP
  strip_lto
  cd $PKG_BUILD/.$TARGET_NAME
     ./autogen.sh
}

configure_host() {
     ./configure --disable-nls \
                 --with-platform=efi
}

configure_target() {
     ./configure --target=i386-pc-linux \
                 --disable-nls \
                 --with-platform=efi
}

pre_make_host() {
  cd $PKG_BUILD/.$HOST_NAME
}

pre_make_target() {
  cd $PKG_BUILD/.$TARGET_NAME
}

make_host() {
  make CC=$CC \
       AR=$AR \
       RANLIB=$RANLIB \
       CFLAGS="-I$TOOLCHAIN/include" \
       LDFLAGS="-L$TOOLCHAIN/lib"
}

make_target() {
  make CC=$CC \
       AR=$AR \
       RANLIB=$RANLIB \
       CFLAGS="-I$SYSROOT_PREFIX/usr/include -fomit-frame-pointer -D_FILE_OFFSET_BITS=64" \
       LDFLAGS="-L$SYSROOT_PREFIX/usr/lib"
}

makeinstall_host() {
  cd $PKG_BUILD/.$HOST_NAME/grub-core
     $PKG_BUILD/.$HOST_NAME/grub-mkimage -d . -o bootx64.efi -O x86_64-efi -p /EFI/BOOT \
                                boot chain configfile ext2 fat linux search \
                                efi_gop efi_uga part_gpt gzio \
                                gettext loadenv loadbios memrw hfs hfsplus msdospart
}

makeinstall_target() {
  cd $PKG_BUILD/.$TARGET_NAME/grub-core
     $PKG_BUILD/.$TARGET_NAME/grub-mkimage -d . -o bootia32.efi -O i386-efi -p /EFI/BOOT \
                                boot chain configfile ext2 fat linux search \
                                efi_gop efi_uga part_gpt gzio \
                                gettext loadenv loadbios memrw hfs hfsplus msdospart

  mkdir -p $INSTALL/usr/share/grub
     cp -P $PKG_BUILD/.$TARGET_NAME/grub-core/bootia32.efi $INSTALL/usr/share/grub
     cp -P $PKG_BUILD/.$HOST_NAME/grub-core/bootx64.efi $INSTALL/usr/share/grub

  mkdir -p $TOOLCHAIN/share/grub
     cp -P $PKG_BUILD/.$TARGET_NAME/grub-core/bootia32.efi $TOOLCHAIN/share/grub
     cp -P $PKG_BUILD/.$HOST_NAME/grub-core/bootx64.efi $TOOLCHAIN/share/grub
}
