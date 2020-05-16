ARG CUDA_VER

FROM nvidia/cuda:${CUDA_VER}-devel-centos6

LABEL maintainer="conda-forge <conda-forge@googlegroups.com>"

# Set CUDA_VER during runtime.
ARG CUDA_VER
ENV CUDA_VER ${CUDA_VER}

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8

# Set path to CUDA install (this is a symlink to /usr/local/cuda-${CUDA_VER})
ENV CUDA_HOME /usr/local/cuda
# the upstream images for 10.x all have libcuda.so under $CUDA_HOME/compat;
# add this to the ldconfig so it will be found correctly. For 9.2, the image
# nvidia/cuda:9.2-devel-centos6 contains neither $CUDA_HOME/compat, nor any
# (non-stub) libcuda.so. For licensing reasons, these cannot be part of the
# conda-forge docker images, but are instead added for CI purposes in:
# github.com/conda-forge/conda-forge-ci-setup-feedstock/blob/master/recipe/run_conda_forge_build_setup_linux
RUN echo "$CUDA_HOME/compat" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    ldconfig
# to do this, we need to enable the conda-user (added in scripts/entrypoint) to perform
# those specific tasks within conda-forge-ci-setup-feedstock that require root privileges
RUN if [ ${CUDA_VER} == "9.2" ]; then \
        echo "conda ALL=NOPASSWD: /bin/mv /usr/local/cuda-10.0/* /usr/local/cuda-9.2" >> /etc/sudoers && \
        echo "conda ALL=NOPASSWD: /bin/rm -rf /usr/local/cuda-10.0" >> /etc/sudoers; \
    fi

# Add a timestamp for the build. Also, bust the cache.
ADD http://worldclockapi.com/api/json/utc/now /opt/docker/etc/timestamp

# Resolves a nasty NOKEY warning that appears when using yum.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Remove preinclude system compilers
RUN rpm -e --nodeps --verbose gcc gcc-c++

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
        conda-forge::binutils_impl_linux-64 \
        conda-forge::binutils_linux-64 \
        conda-forge::gcc_impl_linux-64 \
        conda-forge::gcc_linux-64 \
        conda-forge::gfortran_impl_linux-64 \
        conda-forge::gfortran_linux-64 \
        conda-forge::gxx_impl_linux-64 \
        conda-forge::gxx_linux-64 \
        conda-forge::libgcc-ng \
        conda-forge::libgfortran-ng \
        conda-forge::libstdcxx-ng && \
    conda remove --yes --quiet -n test --all && \
    conda clean -tiy && \
    chgrp -R lucky /opt/conda && \
    chmod -R g=u /opt/conda

# Download and cache CUDA related packages.
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --quiet --download-only \
        defaults::cudatoolkit=${CUDA_VER} \
        && \
    conda remove --yes --quiet -n test --all && \
    conda clean -tiy && \
    chgrp -R lucky /opt/conda && \
    chmod -R g=u /opt/conda

# Symlink CUDA headers that were moved from $CUDA_HOME/include to /usr/include
# in CUDA 10.1.
RUN for HEADER_FILE in cublas_api.h cublas.h cublasLt.h cublas_v2.h cublasXt.h nvblas.h; do \
    if [[ ! -f "${CUDA_HOME}/include/${HEADER_FILE}" ]]; \
    then ln -s "/usr/include/${HEADER_FILE}" "${CUDA_HOME}/include/${HEADER_FILE}"; \
    fi; \
    done

# Add a file for users to source to activate the `conda`
# environment `base`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY linux-anvil-cuda/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `base` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
