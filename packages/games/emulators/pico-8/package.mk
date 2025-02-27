# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2022-present Fewtarius

PKG_NAME="pico-8"
PKG_VERSION="1b1bb06fd65fb3d468a71209d81078c726061159"
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain SDL2 ${OPENGLES}"
PKG_SECTION="emulators"
PKG_SHORTDESC="PICO-8 Fantasy Console"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/start_pico8.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/start_pico8.sh

  mkdir -p ${INSTALL}/usr/lib/autostart/common
  cp ${PKG_DIR}/sources/autostart/common/* ${INSTALL}/usr/lib/autostart/common
  chmod 0755 ${INSTALL}/usr/lib/autostart/common/*
}
