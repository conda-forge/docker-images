FROM centos:6

MAINTAINER conda-forge <conda-forge@googlegroups.com>


# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8

# Add a timestamp for the build. Also, bust the cache.
ADD http://tycho.usno.navy.mil/timer.html /opt/docker/etc/timestamp

# Resolves a nasty NOKEY warning that appears when using yum.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Install basic requirements.
RUN yum update -y && \
    yum install -y \
                   bzip2 \
                   make \
                   patch \
                   sudo \
                   tar \
                   zip \
                   unzip \
                   which \
                   libXext-devel \
                   libXrender-devel \
                   libSM-devel \
                   libX11-devel \
                   mesa-libGL-devel && \
    yum clean all

# Install devtoolset 2.
RUN yum update -y && \
    yum install -y \
                   centos-release-scl \
                   yum-utils && \
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

# Install gosu to be used in the entrypoint, reason why to use it instead of
# su or sudo can be found on the project docs
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" && \
    openssl sha256 /usr/local/bin/gosu | grep 5b3b03713a888cee84ecbf4582b21ac9fd46c3d935ff2d7ea25dd5055d302d3c && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64.asc" && \
    openssl sha256 /usr/local/bin/gosu.asc | grep b026f831a268f6c31daec4234547e4bb0228400babad3d6f6561b6626855af44 && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

# give sudo permission for conda user to run yum (user creation is postponed
# to the entrypoint, so we can create a user with the same id as the host)
RUN echo 'conda ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

# Install the latest Miniconda with Python 3 and update everything.
RUN curl -s -L https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh > miniconda.sh && \
    openssl md5 miniconda.sh | grep d0c7c71cc5659e54ab51f2005a8d96f3 && \
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
