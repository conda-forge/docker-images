ARG CENTOS_VER
FROM arm64v8/centos:${CENTOS_VER}

ADD qemu-aarch64-static /usr/bin/qemu-aarch64-static

LABEL maintainer="conda-forge <conda-forge@googlegroups.com>"

ARG CENTOS_VER
ENV CENTOS_VER=${CENTOS_VER}

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# bust the docker cache so that we always rerun the installs below
ADD https://loripsum.net/api /opt/docker/etc/gibberish

# Resolves a nasty NOKEY warning that appears when using yum.
RUN if [ "$(rpm --eval %{centos_ver})" = "7" ]; then \
      rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER} && \
      rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER}-aarch64; \
    elif [ "$(rpm --eval %{centos_ver})" = "8" ]; then \
      rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial; \
    else \
      echo "Unsupported centos version" && \
      exit 1; \
    fi

# (arm64v8/centos:7) Fix language override to get a working en_US.UTF-8 locale; backports:
# https://github.com/CentOS/sig-cloud-instance-build/commit/2892c17fa8a520e58c3f42cd56587863fe675670
# (arm64v8/centos:8) Install glibc-langpack-en package to get a working en_US.UTF-8 locale
RUN if [ "$(rpm --eval %{centos_ver})" = "7" ]; then \
      sed -i 's/override_install_langs=en_US\.UTF-8/override_install_langs=en_US.utf8/' /etc/yum.conf; \
    elif [ "$(rpm --eval %{centos_ver})" = "8" ]; then \
      yum install -y glibc-langpack-en; \
    else \
      echo "Unsupported centos version" && \
      exit 1; \
    fi

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
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --quiet --download-only \
        conda-forge::binutils_impl_linux-aarch64 \
        conda-forge::binutils_linux-aarch64 \
        conda-forge::gcc_impl_linux-aarch64 \
        conda-forge::gcc_linux-aarch64 \
        conda-forge::gfortran_impl_linux-aarch64 \
        conda-forge::gfortran_linux-aarch64 \
        conda-forge::gxx_impl_linux-aarch64 \
        conda-forge::gxx_linux-aarch64 \
        conda-forge::libgcc-ng \
        conda-forge::libgfortran-ng \
        conda-forge::libstdcxx-ng && \
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
CMD [ "/bin/bash" ]
