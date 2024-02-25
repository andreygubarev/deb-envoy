#!/usr/bin/env bash
set -euxo pipefail

export ENVOY_VERSION=1.29.1
export ENVOY_ARCH=${ENVOY_ARCH:-linux-x86_64}

# create the directory structure
export PKG_NAME=envoy
export PKG_VERSION=${ENVOY_VERSION}
export PKG_RELEASE=0
case ${ENVOY_ARCH} in
  linux-x86_64)
    export PKG_ARCH=amd64
    ;;
  linux-aarch_64)
    export PKG_ARCH=arm64
    ;;
  *)
    echo "Unsupported architecture: ${ENVOY_ARCH}"
    exit 1
    ;;
esac

export PKG_DIR=${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}
cp -R envoy ${PKG_DIR}

# create the control file
envsubst < ${PKG_DIR}/DEBIAN/control > ${PKG_DIR}/DEBIAN/control

# create the binary
mkdir -p ${PKG_DIR}/usr/bin
curl -L -o ${PKG_DIR}/usr/bin/envoy https://github.com/envoyproxy/envoy/releases/download/v${ENVOY_VERSION}/envoy-${ENVOY_VERSION}-${ENVOY_ARCH}

# create the package
dpkg-deb --build ${PKG_DIR}
