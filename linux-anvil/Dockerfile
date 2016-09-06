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
                   make \
                   patch \
                   tar \
                   which \
                   libXext-devel \
                   libXrender-devel \
                   libSM-devel \
                   libX11-devel \
                   mesa-libGL-devel \
                   yum-utils && \
    rpm -Uvh --nodeps $(repoquery --location --archlist=$(arch) redhat-lsb-core) && \
    yum clean all

# Install devtoolset 2.
RUN yum update -y && \
    yum install -y \
                   centos-release-scl && \
    yum-config-manager --add-repo http://people.centos.org/tru/devtools-2/devtools-2.repo && \
    yum update -y && \
    yum install -y \
                   devtoolset-2-binutils \
                   devtoolset-2-gcc \
                   devtoolset-2-gcc-c++ && \
    yum clean all

# Download and install tini for zombie reaping.
RUN curl -s -L -O https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    openssl md5 tini | grep 07b74be7c14bae738afff855eb24e0d9 && \
    chmod +x tini && \
    mv tini /usr/local/bin

# Install the latest Miniconda with Python 3 and update everything.
RUN curl -s -L http://repo.continuum.io/miniconda/Miniconda3-4.1.11-Linux-x86_64.sh > miniconda.sh && \
    openssl md5 miniconda.sh | grep 874dbb0d3c7ec665adf7231bbb575ab2 && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
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

# Add a file for users to source to activate the `conda`
# environment `root` and the devtoolset compiler. Also
# add a file that wraps that for use with the `ENTRYPOINT`.
COPY entrypoint_source /opt/docker/bin/entrypoint_source
COPY entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/usr/local/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
