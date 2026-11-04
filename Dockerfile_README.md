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

The tag on this image is the Linux distro and version used in the image:

- @@DOCKERTAG@@

## Getting Started & Usage

To get started with this image, you can simply run it at the command line with some command:

```bash
docker run --rm -t condaforge/@@IMAGENAME@@:@@DOCKERTAG@@ echo "hi"
```

or use it in your Dockerfile:

```Dockerfile
FROM condaforge/@@IMAGENAME@@:@@DOCKERTAG@@
```

The image is meant for use in our CI system, but can be used as a base image for other purposes.
