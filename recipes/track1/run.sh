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
$SCRIPTS_DIR/prep_eg_dir.sh


#####################################
#### Run experiment  ################
#####################################
EG_DIR=$KALDI_DIR/egs/dihard_2018/v2
pushd $EG_DIR > /dev/null
echo $PWD

# Prepare data directory for DEV set.
echo "Preparing data directory for DEV set..."
DEV_DATA_DIR=data/dihard_dev_2019_track1
rm -fr $DEV_DATA_DIR
local/make_data_dir.py \
   --audio_ext '.flac' \
   --rttm_dir $DIHARD_DEV_DIR/data/single_channel/rttm \
   $DEV_DATA_DIR \
   $DIHARD_DEV_DIR/data/single_channel/flac \
   $DIHARD_DEV_DIR/data/single_channel/sad
utils/fix_data_dir.sh $DEV_DATA_DIR

# Prepare data directory for EVAL set.
echo "Preparing data directory for EVAL set...."
EVAL_DATA_DIR=data/dihard_eval_2019_track1
rm -fr $EVAL_DATA_DIR
local/make_data_dir.py \
   --audio_ext	'.flac'	\
   $EVAL_DATA_DIR \
   $DIHARD_EVAL_DIR/data/single_channel/flac \
   $DIHARD_EVAL_DIR/data/single_channel/sad
utils/fix_data_dir.sh $EVAL_DATA_DIR

# Diarize.
echo "Diarizing..."
./alltracksrun.sh --tracknum 1 --plda_path exp/xvector_nnet_1a/plda_track1 --njobs $NJOBS

# Extract dev/eval RTTM files.
echo "Extracting RTTM files..."
DEV_RTTM_DIR=$THIS_DIR/rttm_dev
local/split_rttm.py \
    exp/xvector_nnet_1a/xvectors_dihard_dev_2019_track1/plda_scores/rttm $DEV_RTTM_DIR
EVAL_RTTM_DIR=$THIS_DIR/rttm_eval
local/split_rttm.py \
    exp/xvector_nnet_1a/xvectors_dihard_eval_2019_track1/plda_scores/rttm $EVAL_RTTM_DIR

popd > /dev/null

# Score system outputs for DEV set against reference.
echo "Scoring DEV set RTTM..."
$PYTHON $DSCORE_DIR/score.py \
    -u $DIHARD_DEV_DIR/data/single_channel/uem/all.uem \
    -r $DIHARD_DEV_DIR/data/single_channel/rttm/*.rttm \
    -s $DEV_RTTM_DIR/*.rttm \
    > metrics_dev.stdout 2> metrics_dev.stderr

echo "Run finished successfully."
