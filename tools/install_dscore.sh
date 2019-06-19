#!/bin/bash
# Installation script for dscore.

set -e

PIP=pip
PYTHON=python
SCRIPT_DIR=`realpath $(dirname "$0")`

# Install python deps.
echo "Installing required Python packages as user."
if ! $PIP install --user intervaltree numpy scipy tabulate; then
    echo ""
    echo "Some Python packages failed to install. Please check pip error output (above)"
    echo "and resolve."
    echo ""
    exit 1
fi

# Clone repo.
echo "Installing dscore."
DSCORE_GIT=https://github.com/nryant/dscore.git
DSCORE_DIR=`realpath $SCRIPT_DIR/dscore`
if [ ! -d $DSCORE_DIR ]; then
    git clone $DSCORE_GIT
    cd $DSCORE_DIR
    git checkout 824f126
    cd ..
else
    echo "$DSCORE_DIR already exists!"
fi

# Add config into env.sh
unset DSCORE_DIR
if [ -s ./env.sh ]; then
    source env.sh
fi
if  [ ! -z "${DSCORE_DIR}" ]; then
    echo "DSCORE_DIR variable is already in env.sh"
else
    echo "Modifying env.sh."
    echo "export DSCORE_DIR=$SCRIPT_DIR/dscore" >> env.sh
    echo "export PATH=\${PATH}:\${DSCORE_DIR}"  >> env.sh
fi


echo "Successfully installed dscore."
