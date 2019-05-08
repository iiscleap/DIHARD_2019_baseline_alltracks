#!/bin/bash
DIR=`dirname $0`
BINDIR=$DIR/denoising_DIHARD18
PYTHON=python
USE_GPU=true  # Use GPU instead of CPU. To instead use CPU, set to 'false'.
GPU_DEVICE_ID=0  # Use GPU with device id 0. Irrelevant if using CPU.
TRUNCATE_MINUTES=10  # Duration in minutes of chunks for enhancement. If you experience
                     # OOM errors with your GPU, try reducing this.
wav_dir=$1
output_dir=$2
echo $BINDIR
if [[ ! -d $BINDIR ]]; then
    echo "ERROR: Could not locate the main_denoising.py script. Please change to "
    echo "the directory containing this script and run the following command "
    echo ""
    echo "    git lfs clone https://github.com/staplesinLA/denoising_DIHARD18.git"
    exit 1
fi
$PYTHON $BINDIR/main_denoising.py \
       --verbose \
       --wav_dir $wav_dir --output_dir $output_dir \
       --use_gpu $USE_GPU --gpu_id $GPU_DEVICE_ID \
       --truncate_minutes $TRUNCATE_MINUTES 
