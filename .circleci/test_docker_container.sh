#!/usr/bin/env bash

set -xeuo pipefail

echo 'Validating correctly configured en_US.UTF-8 locale...'
locale -a | grep -i 'en_US.UTF.\?8'
[ "$( LC_ALL=en_US.UTF-8 sh -c : 2>&1 )" = "" ]
# make sure the above fails for non-existent locale
[ ! "$( LC_ALL=badlocale sh -c : 2>&1 )" = "" ]

# check that /opt/conda has correct permissions
touch /opt/conda/bin/test_conda_forge

# check that conda and micromamba are activated
conda info
micromamba info --root-prefix /opt/conda

# show all packages installed in base
conda list

# check that we can install a conda package with conda
conda install --yes --quiet conda-forge-pinning -c conda-forge

# check that we can install a conda package with micromamba
MAMBA_PKGS_DIRS=/opt/conda/pkgs micromamba install \
    --root-prefix ~/.conda --prefix=/opt/conda \
    --yes --quiet --override-channels -c conda-forge \
    conda-forge-ci-setup

set +e
/usr/bin/sudo -n yum install mesa-libGL mesa-dri-drivers libselinux libXdamage libXxf86vm libXext

touch /home/conda/feedstock_root/build_artifacts/conda-forge-build-done
