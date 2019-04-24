. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc
vaddir=`pwd`/vad


tracknum=-1
nnet_dir=exp/xvector_nnet_1a
plda_path=default

. parse_options.sh || exit 1;

if [ $# != 0 -o "$plda_path" = "default" -o "$tracknum" = "-1" ]; then
  echo "Usage: $0 --tracknum <1|2> --plda_path <path of plda file>"
  echo "main options (for others, see top of script file)"
  echo "  --tracknum                        # number associated with the track to be run"
  echo "  --plda_path                       # path of plda file"

  exit 1;
fi


if [[ "$tracknum" == "2_den" || $tracknum -eq 1 || $tracknum -eq 2 || $tracknum -eq 3 || $tracknum -eq 4 ]]; then

  echo "Track 2 on denoised audio"
  track=track$tracknum

  dihard_dev=dihard_dev_2019_$track
  dihard_eval=dihard_eval_2019_$track
  echo "Make MFCCs for each dataset."

  for name in ${dihard_dev} ${dihard_eval}; do
      steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 40 --cmd "$train_cmd --max-jobs-run 20" \
        data/${name} exp/make_mfcc $mfccdir
      utils/fix_data_dir.sh data/${name}
  done

  echo "MFCC extraction done!"
  echo "performing ceptral mean normalisation (cmn) for both dev and eval"

  for name in ${dihard_dev} ${dihard_eval}; do
    local/nnet3/xvector/prepare_feats.sh --nj 40 --cmd "$train_cmd" \
      data/$name data/${name}_cmn exp/${name}_cmn
    if [ -f data/$name/vad.scp ]; then
      echo "vad.scp found .. copying it"
      cp data/$name/vad.scp data/${name}_cmn/
    fi
    if [ -f data/$name/segments ]; then
      echo "Segments found .. copying it"
      cp data/$name/segments data/${name}_cmn/
    fi
    utils/fix_data_dir.sh data/${name}_cmn
  done


  echo "Extracting x-vectors"

  #Extract x-vectors for DIHARD 2019 development and evaluation set.
  diarization/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 5G" \
    --nj 40 --window 1.5 --period 0.75 --apply-cmn false \
    --min-segment 0.5 $nnet_dir \
  data/${dihard_dev}_cmn $nnet_dir/xvectors_${dihard_dev}

  diarization/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 5G" \
    --nj 40 --window 1.5 --period 0.75 --apply-cmn false \
    --min-segment 0.5 $nnet_dir \
  data/${dihard_eval}_cmn $nnet_dir/xvectors_${dihard_eval}



  # Perform PLDA scoring
  echo "Perform PLDA scoring on all pairs of segments for each recording."
  cp $plda_path $nnet_dir/xvectors_${dihard_dev}/plda

  diarization/nnet3/xvector/score_plda.sh --cmd "$train_cmd --mem 4G" \
    --nj 20 $nnet_dir/xvectors_${dihard_dev} $nnet_dir/xvectors_${dihard_dev} \
  $nnet_dir/xvectors_${dihard_dev}/plda_scores

  diarization/nnet3/xvector/score_plda.sh --cmd "$train_cmd --mem 4G" \
    --nj 20 $nnet_dir/xvectors_${dihard_dev} $nnet_dir/xvectors_${dihard_eval} \
  $nnet_dir/xvectors_${dihard_eval}/plda_scores

  echo "***Eval rttm is generated using best_threshold: $best_threshold"



  mkdir -p $nnet_dir/tuning_$track
  echo "Tuning clustering threshold for DIHARD 2019 development set"
  best_der=100
  best_threshold=0




  for threshold in -0.5 -0.4 -0.3 -0.2 -0.1 -0.05 0 0.05 0.1 0.2 0.3 0.4 0.5; do
      diarization/cluster.sh --cmd "$train_cmd --mem 4G" --nj 20 \
        --threshold $threshold --rttm-channel 1 $nnet_dir/xvectors_${dihard_dev}/plda_scores \
      $nnet_dir/xvectors_${dihard_dev}/plda_scores_t$threshold

      perl md_eval.pl -r data/${dihard_dev}/rttm \
       -s $nnet_dir/xvectors_${dihard_dev}/plda_scores_t$threshold/rttm \
       2> $nnet_dir/tuning_$track/${dihard_dev}_t${threshold}.log \
       > $nnet_dir/tuning_$track/${dihard_dev}_t${threshold}

      der=$(grep -oP 'DIARIZATION\ ERROR\ =\ \K[0-9]+([.][0-9]+)?' \
        $nnet_dir/tuning_$track/${dihard_dev}_t${threshold})
      if [ $(echo $der'<'$best_der | bc -l) -eq 1 ]; then
        best_der=$der
        best_threshold=$threshold
      fi
  done

  echo "*** Best threshold got on dev is : $best_threshold. PLDA scores of eval x-vectors will be clustered using this threshold"
  echo "*** DER got by using best threshold on dev is : $best_der"
  echo "$best_threshold" > $nnet_dir/tuning_$track/${dihard_dev}_best

  diarization/cluster.sh --cmd "$train_cmd --mem 4G" --nj 20 \
    --threshold $(cat $nnet_dir/tuning_$track/${dihard_dev}_best) --rttm-channel 1 \
  $nnet_dir/xvectors_${dihard_dev}/plda_scores $nnet_dir/xvectors_${dihard_dev}/plda_scores


  diarization/cluster.sh --cmd "$train_cmd --mem 4G" --nj 20 \
    --threshold $(cat $nnet_dir/tuning_$track/${dihard_dev}_best) --rttm-channel 1 \
    $nnet_dir/xvectors_${dihard_eval}/plda_scores $nnet_dir/xvectors_${dihard_eval}/plda_scores
    
  echo "***Eval rttm is generated using best_threshold: $best_threshold"

fi

