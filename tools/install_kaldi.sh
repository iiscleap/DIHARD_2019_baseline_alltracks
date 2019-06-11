#!/bin/bash
# Installation script for Kaldi

set -e

SCRIPT_DIR=`realpath $(dirname "$0")`
NJOBS=40 # Number of parallel jobs to run during build.
KALDI_GIT=https://github.com/kaldi-asr/kaldi
KALDI_DIR=`realpath -s $PWD/kaldi`


# Clone Kaldi and checkout to known working version.
echo "Cloning Kaldi."
if [ ! -d "$KALDI_DIR" ]; then
    git clone $KALDI_GIT $KALDI_DIR
    pushd $KALDI_DIR > /dev/null
    git checkout 213ae52ac
    popd > /dev/null
else
  echo "$KALDI_DIR already exists!"
fi

# Perform full Kaldi build with:
# - OpenBLAS linkage
# - compiled beamformit
echo $KALDI_DIR
if [ -L $KALDI_DIR ]; then
    echo "$KALDI_DIR exists and is symlink. Skipping rest of build."
else
    echo "Building Kaldi."
    pushd $KALDI_DIR > /dev/null
    
    # Prevent Kaldi from switching default python version
    mkdir -p "tools/python"
    touch "tools/python/.use_default_python"

    # Build tools.
    cd tools
    ./extras/check_dependencies.sh
    make -j $NJOBS
    make -j $NJOBS openblas
    ./extras/install_beamformit.sh
    cd ../src
    ./configure \
    	--mathlib=OPENBLAS --openblas-root=../tools/OpenBLAS/install
    make depend -j $NJOBS
    make -j $NJOBS

    popd
fi


# Add config into env.sh
unset KALDI_DIR
if [ -s ./env.sh ]; then
    source env.sh
fi
if [ ! -z "${KALDI_DIR}" ]; then
    echo "KALDI_DIR variable is already in env.sh"
else
    echo "Modifying env.sh."
    echo "export KALDI_DIR=${SCRIPT_DIR}/kaldi" >> env.sh
    echo "export PATH=\${PATH}:\${KALDI_DIR}" >> env.sh
fi


echo "Successfully installed Kaldi."
