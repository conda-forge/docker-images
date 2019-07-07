#!/usr/bin/env bash

set -xeuo pipefail

FEEDSTOCK_ROOT=$(cd "$(dirname "$0")/.."; pwd;)

docker info
docker history "$( docker images -q "condaforge/${DOCKERIMAGE}" )"

# In order for the conda-build process in the container to write to the mounted
# volumes, we need to run with the same id as the host machine, which is
# normally the owner of the mounted volumes, or at least has write permission
export HOST_USER_ID=$(id -u)
# Check if docker-machine is being used (normally on OSX) and get the uid from
# the VM
if hash docker-machine 2> /dev/null && docker-machine active > /dev/null; then
    export HOST_USER_ID=$(docker-machine ssh $(docker-machine active) id -u)
fi

ARTIFACTS="$FEEDSTOCK_ROOT/build_artifacts"

mkdir -p "$ARTIFACTS"
DONE_CANARY="$ARTIFACTS/conda-forge-build-done"
rm -f "$DONE_CANARY"

docker run -it \
           -v "${FEEDSTOCK_ROOT}":/home/conda/feedstock_root \
           -e HOST_USER_ID \
           `docker images -q condaforge/$DOCKERIMAGE` \
           bash \
           /home/conda/feedstock_root/.circleci/test_docker_container.sh

# verify that the end of the script was reached
test -f "$DONE_CANARY"
