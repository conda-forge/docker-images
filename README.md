[![CI](https://github.com/conda-forge/docker-images/workflows/CI/badge.svg)](https://github.com/conda-forge/docker-images/actions?query=branch%3Amain+workflow%3Aci)

# docker-images
Repository to host the Docker images files used in conda-forge

## Building and testing locally
It can be useful to build and test these images locally. For many images
this can be done by running `docker build` from the root-level of this
repo and passing in the path to the Dockerfile that you wish to build.
For example:

```sh
docker build --rm --build-arg DISTRO_NAME=centos --build-arg DISTRO_VER=6 -f linux-anvil-comp7/Dockerfile .
```

However, certain images, such as those building CUDA, will need to have
environment variables passed in to be able to build. In this case, you
will want to use a command similar to the following:

```sh
docker build --rm --build-arg DISTRO_NAME=centos --build-arg DISTRO_VER=6 --build-arg CUDA_VER=11.8.0 -f linux-anvil-cuda/Dockerfile .
```

## Environment variables

* `CUDA_VER`: This is the cuda & cudatoolkit version that will be used. The
  value of this variable should be in major-minor-patch format, e.g. `11.8.0`.
* `DISTRO_ARCH`: This is the Linux architecture that the image should use.
  Should match the upstream Docker image, e.g. `amd64`.
* `DISTRO_NAME`: This is the Linux distro image name that should be built with.
  Should match the upstream Docker image, e.g. `centos`.
* `DISTRO_VER`: This is version of Linux distro (typical CentOS) that the image
  should be built with.  This is the major-only version number, e.g. `6` or
  `7`.  You'll usually want to build with the lowest working value for maximum
  compatibility.
