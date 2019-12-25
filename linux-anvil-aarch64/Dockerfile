FROM arm64v8/centos:7

ADD qemu-aarch64-static /usr/bin/qemu-aarch64-static

LABEL maintainer="conda-forge <conda-forge@googlegroups.com>"

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Add a timestamp for the build. Also, bust the cache.
ADD http://worldclockapi.com/api/json/utc/now /opt/docker/etc/timestamp

# Resolves a nasty NOKEY warning that appears when using yum.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7-aarch64

# (arm64v8/centos:7 only) Fix language override to get a working en_US.UTF-8 locale; backports:
# https://github.com/CentOS/sig-cloud-instance-build/commit/2892c17fa8a520e58c3f42cd56587863fe675670
RUN sed -i 's/override_install_langs=en_US\.UTF-8/override_install_langs=en_US.utf8/' /etc/yum.conf
# Install basic requirements.
COPY scripts/yum_clean_all /opt/docker/bin/
RUN yum update -y && \
    yum install -y \
        bzip2 \
        sudo \
        tar \
        which && \
    /opt/docker/bin/yum_clean_all

# Run common commands
COPY scripts/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Download and cache new compiler packages.
# Should speedup installation of them on CIs.
ENV _channel="c4aarch64"
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --quiet --download-only \
        $_channel::binutils_impl_linux-aarch64 \
        $_channel::binutils_linux-aarch64 \
        $_channel::gcc_impl_linux-aarch64 \
        $_channel::gcc_linux-aarch64 \
        $_channel::gfortran_impl_linux-aarch64 \
        $_channel::gfortran_linux-aarch64 \
        $_channel::gxx_impl_linux-aarch64 \
        $_channel::gxx_linux-aarch64 \
        $_channel::libgcc-ng \
        $_channel::libgfortran-ng \
        $_channel::libstdcxx-ng && \
    conda remove --yes --quiet -n test --all && \
    conda clean -tiy && \
    chgrp -R lucky /opt/conda && \
    chmod -R g=u /opt/conda

# Add a file for users to source to activate the `conda`
# environment `base`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY linux-anvil-aarch64/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `base` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/opt/conda/bin/bash" ]
