# Set environment variables during runtime.
ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_NAME
ARG DISTRO_VER
FROM --platform=linux/${DISTRO_ARCH} nvidia/cuda:${CUDA_VER}-devel-${DISTRO_NAME}${DISTRO_VER}

LABEL maintainer="conda-forge <conda-forge@googlegroups.com>"

# Set `ARG`s during runtime.
ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_NAME
ARG DISTRO_VER
ENV CUDA_VER=${CUDA_VER} \
    DISTRO_ARCH=${DISTRO_ARCH} \
    DISTRO_NAME=${DISTRO_NAME} \
    DISTRO_VER=${DISTRO_VER}

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Set path to CUDA install (this is a symlink to /usr/local/cuda-${CUDA_VER})
ENV CUDA_HOME /usr/local/cuda

# bust the docker cache so that we always rerun the installs below
# ADD https://loripsum.net/api /opt/docker/etc/gibberish
# ADD https://worldtimeapi.org/api/timezone/Etc/UTC /opt/docker/etc/gibberish
# Add qemu in here so that we can use this image on regular linux hosts with qemu user installed
ADD qemu-aarch64-static /usr/bin/qemu-aarch64-static
ADD qemu-ppc64le-static /usr/bin/qemu-ppc64le-static

# we want to persist a path in ldconfig (to avoid having to always set LD_LIBRARY_PATH), but *after* the existing entries;
# since entries in ld.so.conf.d have precedence before the preconfigured directories, we first add the latter to the former
# the upstream images all have libcuda.so under $CUDA_HOME/compat;
# add this to the ldconfig so it will be found correctly.
# don't forget to update settings by running ldconfig
RUN ldconfig -v 2>/dev/null | grep -v ^$'\t' | cut -f1 -d":" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    echo "$CUDA_HOME/compat" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    ldconfig

# Add the archived repo URL and fix RPM imports
ADD rpm-repos /tmp/rpm-repos
ADD scripts/fix_rpm /opt/docker/bin/fix_rpm
RUN /opt/docker/bin/fix_rpm

# Add custom `yum_clean_all` script before using `yum`
COPY scripts/yum_clean_all /opt/docker/bin/

# Install basic requirements.
RUN yum update -y --disablerepo=cuda && \
    yum install -y \
        bzip2 \
        sudo \
        tar \
        which \
    && \
    /opt/docker/bin/yum_clean_all

# Fix locale in UBI 8 images
# See https://github.com/CentOS/sig-cloud-instance-images/issues/154
RUN if [ "${DISTRO_NAME}${DISTRO_VER}" = "ubi8" ]; then \
        yum install -y \
            glibc-langpack-en \
        && \
        /opt/docker/bin/yum_clean_all; \
    fi

# Remove preinclude system compilers
RUN rpm -e --nodeps --verbose gcc gcc-c++

# Run common commands
COPY scripts/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Download and cache CUDA related packages.
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --quiet --download-only \
        conda-forge::cudatoolkit=${CUDA_VER} \
        && \
    conda clean -tiy && \
    chgrp -R lucky /opt/conda && \
    chmod -R g=u /opt/conda

# Add a file for users to source to activate the `conda`
# environment `base`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY linux-anvil-cuda/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `base`.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
