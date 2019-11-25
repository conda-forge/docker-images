FROM condaforge/linux-anvil-ppc64le

# Download and cache cuda packages.
# Should speedup installation of them on CIs.
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --download-only \
        -c https://public.dhe.ibm.com/ibmdl/export/pub/software/server/ibm-ai/conda cudatoolkit cudatoolkit-dev cudnn && \
    conda remove --yes -n test --all && \
    conda clean -tiy

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root`.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
