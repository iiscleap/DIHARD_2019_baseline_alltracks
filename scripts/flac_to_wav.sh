#!/bin/bash
set -e

# Convert FLAC files to WAV.
if [ -z `which sox` ]; then
    echo "SoX not installed. Please install SoX before proceeding. E.g.:"
    echo ""
    echo "    apt-get install sox"
fi
FLAC_DIR=$1
WAV_DIR=$2

if [[ ! -d $WAV_DIR ]]; then
    mkdir $WAV_DIR
fi
for flac_fn in `ls $FLAC_DIR/*.flac`; do
    bn=${flac_fn##*/}
    recid=${bn%%.*}
    wf=$WAV_DIR/${recid}.wav
    sox $flac_fn $wf
done
