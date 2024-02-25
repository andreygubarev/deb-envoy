#!/usr/bin/env bash
set -euxo pipefail

ENVOY_VERSION=1.29.1
ENVOY_ARCH=${ENVOY_ARCH:-linux-x86_64}


# create the directory structure
PKG_NAME=envoy
PKG_VERSION=${ENVOY_VERSION}
PKG_RELEASE=0
case ${ENVOY_ARCH} in
  linux-x86_64)
    PKG_ARCH=amd64
    ;;
  linux-aarch_64)
    PKG_ARCH=arm64
    ;;
  *)
    echo "Unsupported architecture: ${ENVOY_ARCH}"
    exit 1
    ;;
esac

PKG_DIR=${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}
mkdir -p ${PKG_DIR}/DEBIAN

# create the control file
cat > ${PKG_DIR}/DEBIAN/control <<EOF
Package: ${PKG_NAME}
Version: ${PKG_VERSION}-${PKG_RELEASE}
Section: base
Priority: optional
Architecture: ${PKG_ARCH}
Maintainer: Andrey Gubarev <andrey@andreygubarev.com>
Description: Envoy proxy
EOF

# create the directory structure
mkdir -p ${PKG_DIR}/usr/bin

# download the envoy binary
curl -L -o ${PKG_DIR}/usr/bin/envoy https://github.com/envoyproxy/envoy/releases/download/v${ENVOY_VERSION}/envoy-${ENVOY_VERSION}-${ENVOY_ARCH}

# copyright
mkdir -p ${PKG_DIR}/usr/share/doc/${PKG_NAME}
cat > ${PKG_DIR}/usr/share/doc/${PKG_NAME}/copyright <<EOF
Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: Envoy
Source: <https://github.com/envoyproxy/envoy>

Files: *
Copyright: Copyright 2016-2022 Envoy Project Authors
License: Apache
/usr/share/common-licenses/Apache-2.0
EOF

# create the package
dpkg-deb --build ${PKG_DIR}
