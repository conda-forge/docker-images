#!/usr/bin/env bash

set -xeuo pipefail

echo 'Validating correctly configured en_US.UTF-8 locale...'
locale -a | grep -i 'en_US.UTF.\?8'
[ "$( LC_ALL=en_US.UTF-8 sh -c : 2>&1 )" = "" ]
# make sure the above fails for non-existent locale
[ ! "$( LC_ALL=badlocale sh -c : 2>&1 )" = "" ]

# check that /opt/conda has correct permissions
touch /opt/conda/bin/test_conda_forge

# check that conda is activated
conda info

# check that conda version matches
IFS='-' read -ra miniforge_version_array <<< "$MINIFORGE_VERSION"
conda_version=${`conda --version`/conda /""}
if [[ "${miniforge_version_array[0]}" != "${conda_version}" ]]
 then
  exit 1
fi

# show all packages installed in root
conda list

# check that we can install a conda package
conda install --yes --quiet conda-forge-pinning -c conda-forge

touch /home/conda/feedstock_root/build_artifacts/conda-forge-build-done
