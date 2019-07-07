FROM arm64v8/centos:7

ADD qemu-aarch64-static /usr/bin/qemu-aarch64-static

LABEL maintainer="conda-forge <conda-forge@googlegroups.com>"

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Add a timestamp for the build. Also, bust the cache.
ADD http://worldclockapi.com/api/json/utc/now /opt/docker/etc/timestamp

# Resolves a nasty NOKEY warning that appears when using yum.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# Fix up issues with locales because the default images have these minimized
# to the point of not being properly functional
# See: https://github.com/CentOS/sig-cloud-instance-images/issues/71
RUN yum update -y && \
    yum reinstall -y glibc-common && \
    yum clean all
RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# Install basic requirements.
RUN yum update -y && \
    yum install -y \
        bzip2 \
        findutils \
        sudo \
        tar \
        which && \
    yum clean all

# Run common commands
COPY scripts/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Download and cache new compiler packages.
# Should speedup installation of them on CIs.
ENV _channel="c4aarch64"
RUN source /opt/conda/etc/profile.d/conda.sh && \
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
    : 'Find files that are not already in group "lucky" and change their group and mode.' && \
    find /opt/conda ! -group lucky -exec chgrp -h lucky {} + -exec chmod u=g {} +

# Add a file for users to source to activate the `conda`
# environment `base`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY linux-anvil-aarch64/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `base` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
