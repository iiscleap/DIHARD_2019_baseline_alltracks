#!/bin/bash
DIR=`dirname $0`
BINDIR=$DIR/denoising_DIHARD18
PYTHON=python
NJOBS=1 # Number of parallel processes to use during VAD. Higher number yield
        # faster runtimes.
wav_dir=$1
output_dir=$2
if [[ ! -d $BINDIR ]]; then
    echo "ERROR: Could not locate the main_get_vad.py script. Please change to "
    echo "the directory containing this script and run the following command "
    echo ""
    echo "    git lfs clone https://github.com/staplesinLA/denoising_DIHARD18.git"
    exit 1
fi
$PYTHON $BINDIR/main_get_vad.py \
	--mode 3 --hoplength 30 --fs_vad 16000 \
	--speech_label speech --output_ext .lab --n_jobs $NJOBS \
	--wav_dir $wav_dir --output_dir $output_dir
