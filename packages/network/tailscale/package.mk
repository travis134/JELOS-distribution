# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present kkoshelev (https://github.com/kkoshelev)

PKG_NAME="tailscale"
PKG_VERSION="1.26.1"
PKG_ARCH="aarch64"
PKG_SITE="https://tailscale.com/"
PKG_URL="https://pkgs.tailscale.com/stable/tailscale_${PKG_VERSION}_arm64.tgz"
PKG_DEPENDS_TARGET="toolchain wireguard-tools wireguard-linux-compat"
PKG_SHORTDESC="Zero config VPN. Installs on any device in minutes, manages firewall rules for you, and works from anywhere."
PKG_TOOLCHAIN="manual"

pre_unpack() {
  mkdir -p $PKG_BUILD
  tar --strip-components=1 -xf $SOURCES/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tgz -C $PKG_BUILD tailscale_${PKG_VERSION}_arm64
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin/
    cp ${PKG_BUILD}/tailscale ${INSTALL}/usr/sbin/
    cp ${PKG_BUILD}/tailscaled ${INSTALL}/usr/sbin/

  mkdir -p ${INSTALL}/usr/config
    cp -R ${PKG_DIR}/config/tailscaled.defaults ${INSTALL}/usr/config
}

post_install() {
  enable_service tailscaled.service
}
