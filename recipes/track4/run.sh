#!/bin/bash

set -e

NJOBS=40
PYTHON=python

#####################################
#### Set following paths  ###########
#####################################
# Path to root of DIHARD II dev release (LDC2019E31).
DIHARD_DEV_DIR=/scratch/nryant/dihard2/deliveries/LDC2019E31_Second_DIHARD_Challenge_Development_Data/

# Path to root of DIHARD II eval release (LDC2019E32).
DIHARD_EVAL_DIR=/scratch/nryant/dihard2/deliveries/LDC2019E32_Second_DIHARD_Challenge_Evaluation_Data_SCRUBBED/

# Path to root of CHiME-5 release.
CHIME_DIR=/data/corpora/CHiME5/


#####################################
#### Check deps satisfied ###########
#####################################
THIS_DIR=`realpath $(dirname "$0")`
TOOLS_DIR=$THIS_DIR/../../tools
SCRIPTS_DIR=$THIS_DIR/../../scripts
[ -f $TOOLS_DIR/env.sh ] && . $TOOLS_DIR/env.sh
if [ -z	$KALDI_DIR ]; then
    echo "KALDI_DIR not defined. Please run tools/install_kaldi.sh"
    exit
fi
$SCRIPTS_DIR/prep_eg_dir.sh


#####################################
#### Run experiment  ################
#####################################
EG_DIR=$KALDI_DIR/egs/dihard_2018/v2
pushd $EG_DIR > /dev/null

# Perform beamforming for all Kinects.
DEV_WAV_DIR=exp/dihard_dev_2019_multichan_wav
echo "Performing beamforming for DEV..."
if [ -d "$DEV_WAV_DIR" ]; then
    echo "Found existing beamformed WAV files at:"
    echo ""
    echo "    $DEV_WAV_DIR"
    echo ""
else
    local/run_beamformit.sh $CHIME_DIR/audio/dev $DEV_WAV_DIR
    local/run_beamformit.sh $CHIME_DIR/audio/train $DEV_WAV_DIR
fi
EVAL_WAV_DIR=exp/dihard_eval_2019_multichan_wav
echo "Performing beamforming for EVAL..."
if [ -d $EVAL_WAV_DIR ]; then
    echo "Found existing beamformed WAV files at:"
    echo ""
    echo "    $EVAL_WAV_DIR"
    echo ""
else
    local/run_beamformit.sh $CHIME_DIR/audio/eval $EVAL_WAV_DIR
fi

# Perform VAD.
DEV_VAD_DIR=exp/dihard_dev_2019_multichan_vad
echo "Performing VAD for DEV set..."
if [ -d $DEV_VAD_DIR ]; then
    echo "Found existing VAD output files at:"
    echo ""
    echo "    $DEV_VAD_DIR"
    echo ""
else
    local/run_vad.sh $DEV_WAV_DIR $DEV_VAD_DIR $NJOBS
fi
EVAL_VAD_DIR=exp/dihard_eval_2019_multichan_vad
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
DEV_DATA_DIR=data/dihard_dev_2019_track4
rm -fr $DEV_DATA_DIR
local/make_data_dir.py \
   --audio_ext '.wav' \
   --rttm_dir $DIHARD_DEV_DIR/data/multichannel/rttm \
   $DEV_DATA_DIR \
   $DEV_WAV_DIR \
   $DEV_VAD_DIR
utils/fix_data_dir.sh $DEV_DATA_DIR

# Prepare data directory for EVAL set.
echo "Preparing data directory for EVAL set...."
EVAL_DATA_DIR=data/dihard_eval_2019_track4
rm -fr $EVAL_DATA_DIR
local/make_data_dir.py \
   --audio_ext	'.wav'	\
   $EVAL_DATA_DIR \
   $EVAL_WAV_DIR \
   $EVAL_VAD_DIR
utils/fix_data_dir.sh $EVAL_DATA_DIR

# Diarize.
echo "Diarizing..."
./alltracksrun.sh --tracknum 4 --plda_path exp/xvector_nnet_1a/plda_track4

# Extract dev/eval RTTM files.
echo "Extracting RTTM files..."
DEV_RTTM_DIR=$THIS_DIR/rttm_dev
local/split_rttm.py \
    exp/xvector_nnet_1a/xvectors_dihard_dev_2019_track4/plda_scores/rttm $DEV_RTTM_DIR
EVAL_RTTM_DIR=$THIS_DIR/rttm_eval
local/split_rttm.py \
    exp/xvector_nnet_1a/xvectors_dihard_eval_2019_track4/plda_scores/rttm $EVAL_RTTM_DIR

popd > /dev/null

# Score system outputs for DEV set against reference.
echo "Scoring DEV set RTTM..."
$PYTHON $DSCORE_DIR/score.py \
    -u $DIHARD_DEV_DIR/data/multichannel/uem/all.uem \
    -r $DIHARD_DEV_DIR/data/multichannel/rttm/*.rttm \
    -s $DEV_RTTM_DIR/*.rttm \
    > metrics_dev.stdout 2> metrics_dev.stderr

echo "Run finished successfully."
