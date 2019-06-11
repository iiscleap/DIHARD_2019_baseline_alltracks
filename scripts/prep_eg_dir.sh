#!/bin/bash
# Prepare the ``egs/dihard_2018/v2`` directory for experiments.
THIS_DIR=`realpath $(dirname "$0")`
DATA_DIR=$THIS_DIR/../data
KALDI_DIR=$THIS_DIR/../tools/kaldi
SCRIPTS_DIR=$THIS_DIR/../scripts
DIHARD_EG_DIR=$KALDI_DIR/egs/dihard_2018/v2

if [ -f $KALDI_DIR ]; then
    echo "$KALDI_DIR not found. Please run ``tools/install_kaldi.sh``"
    exit 1
fi
if [ -f $DIHARD_EG_DIR ]; then
    "$DIHARD_EG_DIR not found. Please run ``tools/install_kaldi.sh``"
    exit 1
fi

BNS="alltracksrun.sh md_eval.pl"
for bn in $BNS; do
    src_path=$SCRIPTS_DIR/$bn
    dest_path=$DIHARD_EG_DIR/$bn
    if [ ! -f $dest_path ]; then
	cp $src_path $dest_path
    fi
done

BNS="beamformit.cfg"
CONF_DIR=$DIHARD_EG_DIR/conf
for bn in $BNS; do
    src_path=$DATA_DIR/$bn
    dest_path=$CONF_DIR/$bn
    if [ ! -f $dest_path ]; then
        cp $src_path $dest_path
    fi
done
BNS="flac_to_wav.sh make_data_dir.py run_beamformit.sh run_denoising.sh run_vad.sh split_rttm.py"
for bn in $BNS; do
    src_path=$SCRIPTS_DIR/$bn
    dest_path=$DIHARD_EG_DIR/local/$bn
    if [ ! -f $dest_path ]; then
	cp $src_path $dest_path
    fi
done

XVEC_DIR=$DIHARD_EG_DIR/exp/xvector_nnet_1a
mkdir -p $XVEC_DIR
BNS="final.raw max_chunk_size min_chunk_size extract.config plda_track1 plda_track2 plda_track3 plda_track4"
for bn in $BNS; do
    src_path=$DATA_DIR/$bn
    dest_path=$XVEC_DIR/$bn
    if [ ! -f $dest_path ]; then
        cp $src_path $dest_path
    fi
done
