#!/usr/bin/env bash

# Check that register-binfmt registers the image's emulators, can be rerun,
# and leaves binfmt_misc handlers it does not own in place.

set -xeuo pipefail

BINFMT=/proc/sys/fs/binfmt_misc
SENTINEL=conda-forge-test-sentinel
SUDO=""
if [ "$(id -u)" != "0" ]; then
    SUDO=sudo
fi

build_arch="$(uname -m)"
if [ "${build_arch}" = "x86_64" ]; then
    target=aarch64
    interpreter=/usr/bin/qemu-aarch64-static
else
    target=x86_64
    interpreter=/usr/bin/qemu-x86_64-static-${build_arch}
fi

cleanup() {
    if [ -e "${BINFMT}/${SENTINEL}" ]; then
        echo -1 | ${SUDO} tee "${BINFMT}/${SENTINEL}" > /dev/null
    fi
}
trap cleanup EXIT

# A handler owned by someone else, such as the host's own binfmt setup.
echo ":${SENTINEL}:M::cfsentinel::/bin/false:" | ${SUDO} tee "${BINFMT}/register" > /dev/null

# The second run checks that existing registrations are replaced.
for _ in 1 2; do
    docker run --rm --privileged --platform "linux/${DISTRO_ARCH}" \
        --entrypoint /opt/docker/bin/register-binfmt \
        "condaforge/${DOCKERIMAGE}:${DOCKERTAG}" "${build_arch}"
done

grep -qx "interpreter ${interpreter}" "${BINFMT}/qemu-${target}"
test -e "${BINFMT}/${SENTINEL}"
