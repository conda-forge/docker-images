# This docker image is cached on Azure's 2019 VMs
# https://github.com/actions/virtual-environments/blob/main/images/win/Windows2019-Readme.md
FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["cmd", "/S", "/C"]

WORKDIR C:/Users/Administrator

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
    conda config --remove channels defaults && \
    conda install -y conda-build git mamba boa && \
    conda config --set always_yes true && \
    conda config --set anaconda_upload false && \
    conda update --all -n base --yes && \
    conda clean --all --yes

CMD cmd.exe /k miniconda3\Scripts\activate.bat

ARG VS_MAJOR="15"
ENV VS_MAJOR=$VS_MAJOR

# Put the Visual Studio layer last because it is the most annoying to redo.
# Be patient, this takes quite a while and you see no action.
# Component names are documented here:
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2017
RUN powershell -Command " \
    $url = \"https://aka.ms/vs/$env:VS_MAJOR/release/vs_buildtools.exe\"; \
    $client = new-object System.Net.WebClient; \
    $client.DownloadFile( $url, \"msvc_build_tools.exe\"); \
    ./msvc_build_tools.exe --quiet --wait --nocache \
    --add Microsoft.Component.MSBuild \
    --add Microsoft.VisualStudio.Component.CoreBuildTools \
    --add Microsoft.VisualStudio.Component.Roslyn.Compiler \
    --add Microsoft.VisualStudio.Component.Static.Analysis.Tools \
    --add Microsoft.VisualStudio.Component.VC.CMake.Project \
    --add Microsoft.VisualStudio.Component.VC.CoreBuildTools \
    --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest \
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    --add Microsoft.VisualStudio.Component.Windows10SDK \
    --add Microsoft.VisualStudio.Workload.MSBuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \
    | Write-Output; \
    Start-Sleep -s 20; \
    del msvc_build_tools.exe; \
    Remove-Item $env:TEMP\* -Recurse; \
    "
