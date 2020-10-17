FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]
WORKDIR C:/Users/Administrator

# Download VS 2019 Build Tools and install the 14.16 Version (VS 2017)
# TODO: Merge all these commands into a single layer
# Based on https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019
RUN powershell -Command " \
    $url = \"https://aka.ms/vs/16/release/vs_buildtools.exe\"; \
    $client = new-object System.Net.WebClient; \
    $client.DownloadFile( $url, \"vs_buildtools.exe\"); \
    "
RUN vs_buildtools.exe --quiet --wait --norestart --nocache \
        --installPath C:\BuildTools \
        --add "Microsoft.VisualStudio.Workload.VCTools;includeRecommended" \
        --add Microsoft.VisualStudio.Component.VC.v141 \
        --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 \
        --add Microsoft.VisualStudio.Component.Windows10SDK.17763 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \
        --remove Microsoft.VisualStudio.Component.Windows81SDK
# TODO:    del vs_buildtools.exe ;\

RUN powershell -Command " \
    $url = \"https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe\"; \
    $client = new-object System.Net.WebClient; \
    $client.DownloadFile( $url, \"miniconda3.exe\"); \
    ./miniconda3.exe /S /D=C:\Users\Administrator\miniconda3 | Write-Output; \
    del miniconda3.exe; \
    ./miniconda3/Scripts/conda clean --all -y; \
    "

RUN miniconda3\Scripts\activate.bat && \
    conda config --add channels conda-forge && \
    conda install -y conda-build git && \
    conda config --set always_yes true && \
    conda config --set anaconda_upload false

ENTRYPOINT [ \
    "miniconda3\Scripts\activate.bat", \
    "&&", \
    "C:\BuildTools\VC\Auxiliary\Build\vcvars64.bat", "-vcvars_ver=14.16", "10.0.17763.0", \
    "&&", \
    "cd", "C:/Users/Administrator", \
    "&&", \
    "cmd" \
]
