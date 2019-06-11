#!/bin/bash
# Installation script for denoising/VAD tool.

set -e

PIP=pip3.6
PYTHON=python3.6
SCRIPT_DIR=`realpath $(dirname "$0")`

# Install python deps.
echo "Installing required Python packages as user."
if ! $PIP install --user numpy scipy librosa cntk-gpu webrtcvad wurlitzer joblib; then
    echo ""
    echo "Some Python packages failed to install. Please check pip error output (above)"
    echo "and resolve."
    echo ""
    exit 1
fi
echo "Checking that we can import CNTK"
if ! $PYTHON -c "import cntk"; then
    echo ""
    echo "CNTK install failed. Check that Open MPI and CUDA are installed. E.g."
    echo ""
    echo "    Open MPI: sudo apt-get install openmpi-bin"
    echo "    CUDA: https://developer.nvidia.com/cuda-toolkit"
    echo ""
    exit 1
fi

# Clone repo.
echo "Installing denoising/VAD software."
DEN_GIT=https://github.com/staplesinLA/denoising_DIHARD18
DEN_DIR=`realpath $PWD/denoising_DIHARD18`
if [ ! -d $DEN_DIR ]; then
    git lfs clone $DEN_GIT
else
    echo "$DEN_DIR already exists!"
fi



# Add config into env.sh
unset DEN_DIR
if [ -s ./env.sh ]; then
    source env.sh
fi
if  [ ! -z "${DEN_DIR}" ]; then
    echo "DEN_DIR variable is already in env.sh"
else
    echo "Modifying env.sh."
    echo "export DEN_DIR=$SCRIPT_DIR/denoising_DIHARD18" >> env.sh
    echo "export PATH=\${PATH}:\${DEN_DIR}"  >> env.sh
fi


echo "Successfully installed denoising/VAD software."
