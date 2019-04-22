#!/bin/bash
# Copyright   2017   Johns Hopkins University (Author: Daniel Garcia-Romero)
#             2017   Johns Hopkins University (Author: Daniel Povey)
#        2017-2018   David Snyder
#             2018   Ewald Enzinger
#             2018   Zili Huang
# Apache 2.0.
#
# See ../README.txt for more info on data required.
# Results (diarization error rate) are inline in comments below.

stage=$1


. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc
nnet_dir=exp/xvector_nnet_1a


if [ $stage -eq 0 ]; then
  # STAGE 1 in JHU's xvector implementation
  for name in dihard_2018_dev; do
    steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 40 --cmd "$train_cmd --max-jobs-run 20" \
      data/${name} exp/make_mfcc $mfccdir
    utils/fix_data_dir.sh data/${name}
  done

  # This writes features to disk after applying the sliding window CMN.
  # Although this is somewhat wasteful in terms of disk space, for diarization
  # it ends up being preferable to performing the CMN in memory.  If the CMN
  # were performed in memory (e.g., we used --apply-cmn true in
  # diarization/nnet3/xvector/extract_xvectors.sh) it would need to be
  # performed after the subsegmentation, which leads to poorer results.
  for name in dihard_2018_dev; do
    local/nnet3/xvector/prepare_feats.sh --nj 40 --cmd "$train_cmd" \
      data/$name data/${name}_cmn exp/${name}_cmn
    if [ -f data/$name/vad.scp ]; then
      cp data/$name/vad.scp data/${name}_cmn/
    fi
    if [ -f data/$name/segments ]; then
      cp data/$name/segments data/${name}_cmn/
    fi
    utils/fix_data_dir.sh data/${name}_cmn
  done

fi


if [ $stage -eq 1 ]; then
  # STAGE 9 in JHU's xvector implementation
  diarization/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 5G" \
    --nj 40 --window 1.5 --period 0.75 --apply-cmn false \
    --min-segment 0.5 $nnet_dir \
    data/dihard_2018_dev_cmn $nnet_dir/xvectors_dihard_2018_dev
fi



# Perform PLDA scoring
if [ $stage -eq 2 ]; then
  # Perform PLDA scoring on all pairs of segments for each recording.
  diarization/nnet3/xvector/score_plda.sh --cmd "$train_cmd --mem 4G" \
    --nj 20 $nnet_dir/xvectors_dihard_2018_dev $nnet_dir/xvectors_dihard_2018_dev \
    $nnet_dir/xvectors_dihard_2018_dev/plda_scores

fi




if [ $stage -le 3 ]; then
  # STAGE 12 in JHU's xvector implementation 
  # Cluster the PLDA scores using a stopping threshold.
  # First, we find the threshold that minimizes the DER on DIHARD 2018 development set.
  mkdir -p $nnet_dir/tuning
  echo "Tuning clustering threshold for DIHARD 2018 development set"
  best_der=100
  best_threshold=0

  # The threshold is in terms of the log likelihood ratio provided by the
  # PLDA scores.  In a perfectly calibrated system, the threshold is 0.
  # In the following loop, we evaluate DER performance on DIHARD 2018 development 
  # set using some reasonable thresholds for a well-calibrated system.
  for threshold in -0.5 -0.4 -0.3 -0.2 -0.1 -0.05 0 0.05 0.1 0.2 0.3 0.4 0.5; do
    diarization/cluster.sh --cmd "$train_cmd --mem 4G" --nj 20 \
      --threshold $threshold --rttm-channel 1 $nnet_dir/xvectors_dihard_2018_dev/plda_scores \
      $nnet_dir/xvectors_dihard_2018_dev/plda_scores_t$threshold

    md-eval.pl -r data/dihard_2018_dev/rttm \
     -s $nnet_dir/xvectors_dihard_2018_dev/plda_scores_t$threshold/rttm \
     2> $nnet_dir/tuning/dihard_2018_dev_t${threshold}.log \
     > $nnet_dir/tuning/dihard_2018_dev_t${threshold}

    der=$(grep -oP 'DIARIZATION\ ERROR\ =\ \K[0-9]+([.][0-9]+)?' \
      $nnet_dir/tuning/dihard_2018_dev_t${threshold})
    if [ $(echo $der'<'$best_der | bc -l) -eq 1 ]; then
      best_der=$der
      best_threshold=$threshold
    fi
  done
  echo "$best_threshold" > $nnet_dir/tuning/dihard_2018_dev_best

  diarization/cluster.sh --cmd "$train_cmd --mem 4G" --nj 20 \
    --threshold $(cat $nnet_dir/tuning/dihard_2018_dev_best) --rttm-channel 1 \
    $nnet_dir/xvectors_dihard_2018_dev/plda_scores $nnet_dir/xvectors_dihard_2018_dev/plda_scores
fi
