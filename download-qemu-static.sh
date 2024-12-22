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
version='8.2.7'
build='1.fc40'
for arch in aarch64 ppc64le s390x; do
    curl -sL \
        "https://kojipkgs.fedoraproject.org/packages/qemu/${version}/${build}/x86_64/qemu-user-static-${arch/ppc64le/ppc}-${version}-${build}.x86_64.rpm" |
        bsdtar -xf- --strip-components=3 ./usr/bin/qemu-${arch}-static
done

sha256sum --check << 'EOF'
537131cbd6596728165e2036c9269e19e575a95d518c805d4462d865c63263eb  qemu-aarch64-static
2ed243a429e4c994515f64c8b2b7b81bc1d2d77eaec4c0de67e393bd914d154d  qemu-ppc64le-static
06d6bcd11b9a13770d1aa2120f37d842b67656d033d99793d21eefcd7775ff51  qemu-s390x-static
EOF
