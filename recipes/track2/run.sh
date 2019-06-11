#!/bin/bash

set -e

NJOBS=40
PYTHON=python

#####################################
#### Set following paths  ###########
#####################################
# Path to root of DIHARD II dev release (LDC2019E31).
DIHARD_DEV_DIR=/scratch/nryant/dihard2/deliveries/LDC2019E31_Second_DIHARD_Challenge_Development_Data/

# Path to root of DIHARD II eval release (LDC2019E32)
DIHARD_EVAL_DIR=/scratch/nryant/dihard2/deliveries/LDC2019E32_Second_DIHARD_Challenge_Evaluation_Data_SCRUBBED/


#####################################
#### Check deps satisfied ###########
#####################################
THIS_DIR=`realpath $(dirname "$0")`
TOOLS_DIR=$THIS_DIR/../../tools
SCRIPTS_DIR=$THIS_DIR/../../scripts
[ -f $TOOLS_DIR/env.sh ] && . $TOOLS_DIR/env.sh
if [ -z	$KALDI_DIR ]; then
    echo "KALDI_DIR not defined. Please run tools/install_kaldi.sh"
    exit 1
fi
if [ -z "$DEN_DIR" ]; then
    echo "DEN_DIR not defined. Please run tools/install_den.sh."
    exit 1
fi
$SCRIPTS_DIR/prep_eg_dir.sh


#####################################
#### Run experiment  ################
#####################################
EG_DIR=$KALDI_DIR/egs/dihard_2018/v2
pushd $EG_DIR > /dev/null

# Convert FLAC to WAV as precursor to VAD.
DEV_WAV_DIR=exp/dihard_dev_2019_single_chan_wav
echo "Converting DEV FLAC to WAV..."
if [ -d "$DEV_WAV_DIR" ]; then
    echo "Found existing WAV files at:"
    echo ""
    echo "    $DEV_WAV_DIR"
    echo ""
else
    local/flac_to_wav.sh $DIHARD_DEV_DIR/data/single_channel/flac $DEV_WAV_DIR
fi
EVAL_WAV_DIR=exp/dihard_eval_2019_single_chan_wav
echo "Converting EVAL FLAC to WAV..."
if [ -d $EVAL_WAV_DIR ]; then
    echo "Found existing WAV files at:"
    echo ""
    echo "    $EVAL_WAV_DIR"
    echo ""
else
    local/flac_to_wav.sh $DIHARD_EVAL_DIR/data/single_channel/flac $EVAL_WAV_DIR
fi

# Perform VAD.
DEV_VAD_DIR=exp/dihard_dev_2019_single_chan_vad
echo "Performing VAD for DEV set..."
if [ -d $DEV_VAD_DIR ]; then
    echo "Found existing VAD output files at:"
    echo ""
    echo "    $DEV_VAD_DIR"
    echo ""
else
    local/run_vad.sh $DEV_WAV_DIR $DEV_VAD_DIR $NJOBS
fi
EVAL_VAD_DIR=exp/dihard_eval_2019_single_chan_vad
echo "Performing VAD for EVAL set..."
if [ -d $EVAL_VAD_DIR ]; then
    echo "Found existing VAD output files at:"
    echo ""
    echo "    $EVAL_VAD_DIR"
    echo ""
else
    local/run_vad.sh $EVAL_WAV_DIR $EVAL_VAD_DIR $NJOBS
fi

# Prepare data directory for DEV set.
echo "Preparing data directory for DEV set..."
DEV_DATA_DIR=data/dihard_dev_2019_track2
local/make_data_dir.py \
   --audio_ext '.flac' \
   --rttm_dir $DIHARD_DEV_DIR/data/single_channel/rttm \
   $DEV_DATA_DIR \
   $DIHARD_DEV_DIR/data/single_channel/flac \
   $DEV_VAD_DIR
utils/fix_data_dir.sh $DEV_DATA_DIR

# Prepare data directory for EVAL set.
echo "Preparing data directory for EVAL set...."
EVAL_DATA_DIR=data/dihard_eval_2019_track2
local/make_data_dir.py \
   --audio_ext	'.flac'	\
   $EVAL_DATA_DIR \
   $DIHARD_EVAL_DIR/data/single_channel/flac \
   $EVAL_VAD_DIR
utils/fix_data_dir.sh $EVAL_DATA_DIR

# Diarize.
echo "Diarizing..."
./alltracksrun.sh --tracknum 2 --plda_path exp/xvector_nnet_1a/plda_track2

# Extract dev/eval RTTM files.
echo "Extracting RTTM files..."
DEV_RTTM_DIR=$THIS_DIR/rttm_dev
local/split_rttm.py \
    exp/xvector_nnet_1a/xvectors_dihard_dev_2019_track2/plda_scores/rttm $DEV_RTTM_DIR
EVAL_RTTM_DIR=$THIS_DIR/rttm_eval
local/split_rttm.py \
    exp/xvector_nnet_1a/xvectors_dihard_eval_2019_track2/plda_scores/rttm $EVAL_RTTM_DIR

popd > /dev/null

# Score system outputs for DEV set against reference.
echo "Scoring DEV set RTTM..."
$PYTHON $DSCORE_DIR/score.py \
    -u $DIHARD_DEV_DIR/data/single_channel/uem/all.uem \
    -r $DIHARD_DEV_DIR/data/single_channel/rttm/*.rttm \
    -s $DEV_RTTM_DIR/*.rttm \
    > metrics_dev.txt 2> metrics_dev.stderr
