# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)

PKG_NAME="retroarch"
PKG_VERSION="e9d67f2bbe01f3fe66de5eda6430bccfba95b663"
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL="${PKG_SITE}.git"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain SDL2 alsa-lib openssl freetype zlib retroarch-assets core-info ffmpeg libass joyutils empty ${OPENGLES} nss-mdns openal-soft libogg libvorbisidec libvorbis libvpx libpng libdrm librga pulseaudio miniupnpc flac"
PKG_LONGDESC="Reference frontend for the libretro API."
GET_HANDLER_SUPPORT="git"

PKG_PATCH_DIRS+="${DEVICE}"

pre_configure_target() {
  TARGET_CONFIGURE_OPTS=""
  PKG_CONFIGURE_OPTS_TARGET="--disable-qt \
                             --enable-alsa \
                             --enable-udev \
                             --disable-opengl1 \
                             --disable-opengl \
                             --disable-vulkan \
                             --disable-vulkan_display \
                             --enable-egl \
                             --enable-opengles \
                             --disable-wayland \
                             --disable-x11 \
                             --enable-zlib \
                             --enable-freetype \
                             --disable-discord \
                             --disable-vg \
                             --disable-sdl \
                             --enable-sdl2 \
                             --disable-ffmpeg \
                             --enable-opengles3 \
                             --enable-opengles3_1 \
                             --enable-kms \
                             --disable-mali_fbdev \
                             --enable-odroidgo2"

  if [ "${ARCH}" == "arm" ]; then
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon"
  fi

  cd ${PKG_BUILD}
}

make_target() {
  make HAVE_UPDATE_ASSETS=1 HAVE_LIBRETRODB=1 HAVE_BLUETOOTH=1 HAVE_NETWORKING=1 HAVE_ZARCH=1 HAVE_QT=0 HAVE_LANGEXTRA=1
  [ $? -eq 0 ] && echo "(retroarch ok)" || { echo "(retroarch failed)" ; exit 1 ; }
  make -C gfx/video_filters compiler=$CC extra_flags="$CFLAGS"
  [ $? -eq 0 ] && echo "(video filters ok)" || { echo "(video filters failed)" ; exit 1 ; }
  make -C libretro-common/audio/dsp_filters compiler=$CC extra_flags="$CFLAGS"
  [ $? -eq 0 ] && echo "(audio filters ok)" || { echo "(audio filters failed)" ; exit 1 ; }
}

makeinstall_target() {
  if [ "${ARCH}" == "aarch64" ]; then
    mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/retroarch ${INSTALL}/usr/bin
    cp -vP ${PKG_BUILD}/../../build.${DISTRO}-${DEVICE}.arm/retroarch-*/.install_pkg/usr/bin/retroarch ${INSTALL}/usr/bin/retroarch32

    mkdir -p ${INSTALL}/usr/share/retroarch/filters
    cp -rvP ${PKG_BUILD}/../../build.${DISTRO}-${DEVICE}.arm/retroarch-*/.install_pkg/usr/share/retroarch/filters/* ${INSTALL}/usr/share/retroarch/filters

    mkdir -p ${INSTALL}/etc
    cp ${PKG_BUILD}/retroarch.cfg ${INSTALL}/etc

    mkdir -p ${INSTALL}/usr/share/retroarch/filters/64bit/video
    cp ${PKG_BUILD}/gfx/video_filters/*.so ${INSTALL}/usr/share/retroarch/filters/64bit/video
    cp ${PKG_BUILD}/gfx/video_filters/*.filt ${INSTALL}/usr/share/retroarch/filters/64bit/video

    mkdir -p ${INSTALL}/usr/share/retroarch/filters/64bit/audio
    cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.so ${INSTALL}/usr/share/retroarch/filters/64bit/audio
    cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.dsp ${INSTALL}/usr/share/retroarch/filters/64bit/audio

    # General configuration
    mkdir -p ${INSTALL}/usr/config/retroarch/
    if [ -d "${PKG_DIR}/sources/${DEVICE}" ]; then
		cp -rf ${PKG_DIR}/sources/${DEVICE}/* ${INSTALL}/usr/config/retroarch/
	else
		cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/config/retroarch/
	fi
  else
    mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/retroarch ${INSTALL}/usr/bin

    mkdir -p ${INSTALL}/usr/share/retroarch/filters/32bit/video
    cp ${PKG_BUILD}/gfx/video_filters/*.so ${INSTALL}/usr/share/retroarch/filters/32bit/video
    cp ${PKG_BUILD}/gfx/video_filters/*.filt ${INSTALL}/usr/share/retroarch/filters/32bit/video

    mkdir -p ${INSTALL}/usr/share/retroarch/filters/32bit/audio
    cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.so ${INSTALL}/usr/share/retroarch/filters/32bit/audio
    cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.dsp ${INSTALL}/usr/share/retroarch/filters/32bit/audio
  fi
}

post_install() {
  mkdir -p ${INSTALL}/etc/retroarch-joypad-autoconfig
  cp -r ${PKG_DIR}/gamepads/device/${DEVICE}/* ${INSTALL}/etc/retroarch-joypad-autoconfig

  # Remove unnecesary Retroarch Assets and overlays
  for i in FlatUX Automatic Systematic branding nuklear nxrgui pkg switch wallpapers zarch
  do
    rm -rf "${INSTALL}/usr/share/retroarch-assets/$i"
  done

  for i in automatic dot-art flatui neoactive pixel retroactive retrosystem systematic convert.sh NPMApng2PMApng.py; do
    rm -rf "${INSTALL}/usr/share/retroarch-assets/xmb/$i"
  done
}
