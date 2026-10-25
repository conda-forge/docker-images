# conda-forge/@@IMAGENAME@@
[![CI](https://github.com/conda-forge/docker-images/workflows/CI/badge.svg)](https://github.com/conda-forge/docker-images/actions?query=branch%3Amain+workflow%3Aci)

@@SHORTDESCRIPTION@@

## Description

This image is used to power conda-forge's automated package build infrastructure. For more details, see the [conda-forge documentation](https://conda-forge.org/docs/maintainer/infrastructure/) for our infrastructure.

## License

This image is licensed under [BSD-3 Clause](https://github.com/conda-forge/docker-images/blob/main/LICENSE).

## Documentation & Contributing

You can find documentation for how to use the image on the
upstream [repo](https://github.com/conda-forge/docker-images).

To get in touch with the maintainers of this image, please [make an issue](https://github.com/conda-forge/docker-images/issues/new/choose)
and bump the `@conda-forge/core` team.

Contributions are welcome in accordance
with conda-forge's [code of conduct](https://conda-forge.org/community/code-of-conduct/). We accept them through pull requests on the
upstream [repo](https://github.com/conda-forge/docker-images/compare).

## Important Image Tags

The tags on this image are either:

- latest: used for non-CUDA aware images
- @@DOCKERTAG@@: the CUDA version used in the image

## Getting Started & Usage

To get started with this image, you can simply run it at the command line with some command:

```bash
docker run --rm -t condaforge/@@IMAGENAME@@:@@DOCKERTAG@@ echo "hi"
```

### Build and run with rootless podman

```bash
export DOCKER_EXECUTABLE=podman
./.circleci/run_docker_build.sh
```

For local feedstock builds, set the same variable before running
`build-locally.py`:

```bash
export DOCKER_EXECUTABLE=podman
./build-locally.py
```

Under rootless podman the container's root maps to the unprivileged host
user, so the entrypoint skips `useradd`, `chown /home/conda`, and
`su-exec` (all require real root) and runs conda as the host user. That user
owns the mounted volumes, so writes work. The run script passes
`--userns=keep-id` to hold that mapping.

See https://github.com/conda-forge/docker-images/issues/280 and
https://github.com/conda-forge/conda-smithy/issues/2731.

or use it in your Dockerfile:

```Dockerfile
FROM condaforge/@@IMAGENAME@@:@@DOCKERTAG@@
```

The image is meant for use in our CI system, but can be used as a base image for other purposes.
