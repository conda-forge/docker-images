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
                   which \
                   libXext-devel \
                   libXrender-devel \
                   libSM-devel \
                   libX11-devel \
                   mesa-libGL-devel && \
    yum clean all

# Install devtoolset 4.
RUN yum update -y && \
    yum install -y \
                   centos-release-scl \
    yum update -y && \
    yum install -y \
                   devtoolset-4-binutils \
                   devtoolset-4-gcc \
                   devtoolset-4-gcc-c++ && \
    yum clean all

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
RUN curl -s -L https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh > miniconda.sh && \
    openssl md5 miniconda.sh | grep c1c15d3baba15bf50293ae963abef853 && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    touch /opt/conda/conda-meta/pinned && \
    export PATH=/opt/conda/bin:$PATH && \
    conda config --set show_channel_urls True && \
    conda config --add channels conda-forge && \
    conda update --all --yes && \
    conda clean -tipy

# Install conda build and deployment tools.
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install --yes --quiet conda-build anaconda-client jinja2 setuptools && \
    conda install --yes git && \
    conda install --yes tini && \
    export CONDA_TINI_INFO=( `conda list tini | grep tini` ) && \
    echo "tini ${CONDA_TINI_INFO[1]}" >> /opt/conda/conda-meta/pinned && \
    conda clean -tipsy

# Add a file for users to source to activate the `conda`
# environment `root` and the devtoolset compiler. Also
# add a file that wraps that for use with the `ENTRYPOINT`.
COPY entrypoint_source /opt/docker/bin/entrypoint_source
COPY entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
