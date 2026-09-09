#!/bin/bash -ex

set -eux

if [ "$(uname -m)" = "x86_64" ]; then
    docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

rm -f qemu-*-static

# We use curl and bsdtar to obtain QEMU binaries. Install them beforehand.
sudo apt-get update -qq
DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install --yes --no-install-recommends \
    ca-certificates curl libarchive-tools

# see https://gitlab.com/qemu-project/qemu/-/tags for versions;
# we use the RPMs from https://kojipkgs.fedoraproject.org/packages/qemu;
# avoid qemu builds from unreleased fedora versions, compare `build`
# vs. https://en.wikipedia.org/wiki/Fedora_Linux_release_history;
# prefer non-`.0` patch releases to try to avoid potential new regressions;
# if possible, check https://gitlab.com/qemu-project/qemu/-/issues
# for relevant issues in old vs new version;
version='9.2.4'
build='2.fc42'
for arch in aarch64 ppc64le s390x riscv64; do
    pkg_arch="${arch}"
    if [[ "${arch}" == 'ppc64le' ]]; then
        pkg_arch='ppc'
    elif [[ "${arch}" == 'riscv64' ]]; then
        pkg_arch='riscv'
    fi
    curl -sL \
        "https://kojipkgs.fedoraproject.org/packages/qemu/${version}/${build}/x86_64/qemu-user-static-${pkg_arch}-${version}-${build}.x86_64.rpm" |
        bsdtar -xf- --strip-components=3 ./usr/bin/qemu-${arch}-static
done

sha256sum --check << 'EOF'
fbc515a0652b5084a52411f30b3cb0c95e117b417611b53529daf4a3f5fa5035  qemu-aarch64-static
0e15b6a758f8709897dbf911ed9eac66056a68417f466e3a6afc8f76cac80b54  qemu-ppc64le-static
1a34e86319d55c1a781feef11156ec33961600a6cd6a5269c33e5bfa8f306de8  qemu-s390x-static
f6850076fc69d6bdbd1f3002634371c43e20c65942de944cded92b4c927332b2  qemu-riscv64-static
EOF
