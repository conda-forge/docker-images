#!/bin/bash -ex

set -eux

if [ "$(uname -m)" = "x86_64" ]; then
    docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

rm -f qemu-*-static*

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
version='8.2.8'
build='2.fc40'
# An emulator runs on the HOST while emulating a foreign target, so images used
# on aarch64 build hosts need aarch64-native emulators; the x86_64 ones cannot
# be executed there at all. x86_64 keeps the historical unsuffixed names so that
# existing binfmt registrations are unaffected.
for host_arch in x86_64 aarch64; do
    suffix=''
    [[ "${host_arch}" == 'x86_64' ]] || suffix="-${host_arch}"
    for arch in aarch64 ppc64le s390x riscv64 x86_64; do
        # emulating a CPU with itself is pointless
        if [[ "${arch}" == "${host_arch}" ]]; then
            continue
        fi
        pkg_arch="${arch}"
        if [[ "${arch}" == 'ppc64le' ]]; then
            pkg_arch='ppc'
        elif [[ "${arch}" == 'riscv64' ]]; then
            pkg_arch='riscv'
        elif [[ "${arch}" == 'x86_64' ]]; then
            pkg_arch='x86'
        fi
        # Stream the member to an explicitly named file rather than extracting
        # in place: the member name is the same for every host_arch, so an
        # in-place extract would clobber the previous pass's binary.
        curl -sL \
            "https://kojipkgs.fedoraproject.org/packages/qemu/${version}/${build}/${host_arch}/qemu-user-static-${pkg_arch}-${version}-${build}.${host_arch}.rpm" |
            bsdtar -xOf- ./usr/bin/qemu-${arch}-static > "qemu-${arch}-static${suffix}"
        chmod +x "qemu-${arch}-static${suffix}"
    done
done

sha256sum --check << 'EOF'
c41cd478bdcccbc76a0e35db8ba65861038cd8f0d6339abc0cfd19eadc335fc6  qemu-aarch64-static
9b5c44f35eceaf6484ec11bc03047001293586f9ae73861dde87329243d56ae7  qemu-ppc64le-static
767a23c0ec4570b28d352ad00c55c4fc2315d5707078d022c1d2cc07d827561e  qemu-s390x-static
c71ac58f8749dc5334fc85d92ffb1bb41e54ebb143b7a79e9eac95d7efe283ca  qemu-riscv64-static
1449f84069ce0b30ec432eea6881185ed85b6a7ae6048fb62d22264129575fa6  qemu-ppc64le-static-aarch64
6d981c9388785ffdf222174e165a89ad60f00be08b52c46047c774eb621b887b  qemu-s390x-static-aarch64
cc04d3607b123e325db5dfb8ec3a50562a52b2096ad296263b87827a0842cbfa  qemu-riscv64-static-aarch64
d0243a173c61f88ceac8f7d9aca6f9b947200398e05632381669b736aa7a2b03  qemu-x86_64-static-aarch64
EOF
