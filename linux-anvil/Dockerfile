FROM centos:6

MAINTAINER conda-forge <conda-forge@googlegroups.com>


# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8

# Add a timestamp for the build. Also, bust the cache.
ADD http://www.timeapi.org/utc/now /opt/docker/etc/timestamp

# Resolves a nasty NOKEY warning that appears when using yum.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Install basic requirements.
RUN yum update -y && \
    yum install -y \
                   bzip2 \
                   gcc-c++ \
                   make \
                   patch \
                   tar \
                   which \
                   libXext-devel \
                   libXrender-devel \
                   libSM-devel \
                   libX11-devel \
                   mesa-libGL-devel && \
    yum clean all

# Install devtoolset 3.
RUN yum update -y && \
    yum install -y \
                   centos-release-scl \
    yum update -y && \
    yum install -y \
                   devtoolset-3-binutils \
                   devtoolset-3-gcc \
                   devtoolset-3-gcc-c++ && \
    yum clean all

# Download and install tini for zombie reaping.
RUN curl -s -L -O https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    openssl md5 tini | grep 07b74be7c14bae738afff855eb24e0d9 && \
    chmod +x tini && \
    mv tini /usr/local/bin

# Install the latest Miniconda with Python 3 and update everything.
RUN curl -s -L -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && rm Miniconda*.sh && \
    export PATH=/opt/conda/bin:$PATH && \
    conda config --set show_channel_urls True && \
    conda config --add channels conda-forge && \
    conda update --all --yes && \
    conda clean -tipy

# Install Obvious-CI.
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install --yes obvious-ci && \
    obvci_install_conda_build_tools.py && \
    conda clean -tipsy

# Install conda-forge git.
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install --yes git && \
    conda clean -tipsy

# udunits2.
# libtool texinfo
# RUN yum install -y expat-devel

COPY entrypoint_source /opt/docker/bin/entrypoint_source
COPY entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/usr/local/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
