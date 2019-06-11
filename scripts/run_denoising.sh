#!/bin/bash
# Run denoising algorithm on WAV files.
THIS_FILE=`realpath $0`

WAV_DIR=$1
OUTPUT_DIR=$2
USE_GPU=true  # Use GPU instead of CPU. To instead use CPU, set to 'false'.
GPU_DEVICE_ID=0  # Use GPU with device id 0. Irrelevant if using CPU.
TRUNCATE_MINUTES=5  # Duration in minutes of chunks for enhancement. If you experience
                    # OOM errors with your GPU, try reducing this.
PYTHON=python
if [ -z "$DEN_DIR" ]; then
    echo "DEN_DIR not defined. Please run tools/install_den.sh."
    exit 1
fi
echo "Running denoising using GPU on device $GPU_DEVICE_ID."
echo "To run using CPU or on a different GPU device, please edit:"
echo ""
echo "         $THIS_FILE"
$PYTHON $DEN_DIR/main_denoising.py \
       --verbose \
       --wav_dir $WAV_DIR --output_dir $OUTPUT_DIR \
       --use_gpu $USE_GPU --gpu_id $GPU_DEVICE_ID \
       --truncate_minutes $TRUNCATE_MINUTES
