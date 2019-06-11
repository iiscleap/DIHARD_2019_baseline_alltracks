#!/bin/bash
# Run VAD algorithm on WAV files with defaults.
WAV_DIR=$1
OUTPUT_DIR=$2
NJOBS=${3:-1}
PYTHON=python
if [ -z "$DEN_DIR" ]; then
    echo "DEN_DIR not defined. Please run tools/install_den.sh."
    exit 1
fi
$PYTHON $DEN_DIR/main_get_vad.py \
	--mode 3 --hoplength 30 --fs_vad 16000 --med_filt_width 7 \
	--speech_label speech --output_ext .lab --n_jobs $NJOBS \
	--wav_dir $WAV_DIR --output_dir $OUTPUT_DIR
