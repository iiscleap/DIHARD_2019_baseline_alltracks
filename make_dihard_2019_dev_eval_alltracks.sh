#!/bin/bash

devoreval="dev"
tracknum=1

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;



if [ $# != 2 ]; then
  echo "Usage: $0 --devoreval <dev|eval> --tracknum <1|2> <path-to-dihard_2018_dev> <path-to-output>"
  echo " e.g.: --devoreval dev --tracknum 1 $0 /export/corpora/LDC/LDC2018E31 data/dihard_2018_dev"
  echo "main options (for others, see top of script file)"
  echo "  --devoreval|dev                           # option to select dev or eval for data preparation"
  echo "  --tracknum|1                           # option to track number for data preparation"

  exit 1;
fi

echo 'devoreval is' $devoreval
echo 'tracknum is' $tracknum

data_dir=$2
if [ "$devoreval" = "dev" ]; then
	path_to_dihard_2019_dev=$1

	echo "Preparing ${data_dir}..."
	local/make_dihard_2019_dev_eval_alltracks.py ${path_to_dihard_2019_dev} ${data_dir} $tracknum $devoreval
	sort -k 2,2 -s ${data_dir}/rttm > ${data_dir}/rttm_tmp
	mv ${data_dir}/rttm_tmp ${data_dir}/rttm
	sort -k 1,1 -s ${data_dir}/reco2num_spk > ${data_dir}/reco2num_spk_tmp
	mv ${data_dir}/reco2num_spk_tmp ${data_dir}/reco2num_spk
	utils/fix_data_dir.sh ${data_dir}


elif [ "$devoreval" = "eval" ]; then
	path_to_dihard_2018_eval=$1

	echo "Preparing ${data_dir}..."
	local/make_dihard_2019_dev_eval_alltracks.py ${path_to_dihard_2018_eval} ${data_dir} $tracknum $devoreval
	utils/fix_data_dir.sh ${data_dir}
fi	






