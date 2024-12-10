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
version='9.1.2'
build='2.fc41'
for arch in aarch64 ppc64le s390x; do
    curl -sL \
        "https://kojipkgs.fedoraproject.org/packages/qemu/${version}/${build}/x86_64/qemu-user-static-${arch/ppc64le/ppc}-${version}-${build}.x86_64.rpm" |
        bsdtar -xf- --strip-components=3 ./usr/bin/qemu-${arch}-static
done

sha256sum --check << 'EOF'
24430d7864630c06fcb4865bee63f7a5b57b37b462e7e8a61afef0b9de9d91b6  qemu-aarch64-static
1391cfcf75de6a13a33b47107b89d711af661538f632b088d4d2c11460b3bce0  qemu-ppc64le-static
9f9229f2b3baacbebf323f035f216083ea97c125f1ca18525f14c39b60c2e545  qemu-s390x-static
EOF
