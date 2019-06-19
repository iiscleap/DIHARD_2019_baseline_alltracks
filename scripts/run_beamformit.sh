#!/bin/bash
# Adapted from ``egs/chime5/s5/local/run_beamformit.sh``

. ./cmd.sh
. ./path.sh
export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh

if [ -z BEAMFORMIT ]; then
    echo "BEAMFORMIT is not defined. Please run ``tools/install_kaldi.sh``"
    echo "and verify that BeamFormit installed successfully"
    exit 1
fi


# Config:
cmd=run.pl
bmf="1 2 3 4"
arrays="u01 u02 u03 u04 u05 u06"
sdir=$1
odir=$2
expdir=exp/enhan/`echo $sdir | awk -F '/' '{print $NF}'`_`echo $bmf | tr ' ' '_'`

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

mkdir -p $odir
mkdir -p $expdir/log

echo "Will use the following channels: $bmf"
# number of channels
numch=`echo $bmf | tr ' ' '\n' | wc -l`
echo "the number of channels: $numch"

# wavfiles.list can be used as the name of the output files
output_wavfiles=$expdir/wavfiles.list
if [ -f $output_wavfiles ]; then
    rm $output_wavfiles
fi
for array in $arrays; do
    find -L ${sdir} | grep -i ${array} | awk -F "/" '{print $NF}' | sed -e "s/\.CH.\.wav//" | sort | uniq >> $output_wavfiles
done
sort -o $output_wavfiles $output_wavfiles


# this is an input file list of the microphones
# format: 1st_wav 2nd_wav ... nth_wav
input_arrays=$expdir/channels_$numch
for x in `cat $output_wavfiles`; do
  echo -n "$x"
  for ch in $bmf; do
    echo -n " $x.CH$ch.wav"
  done
  echo ""
done > $input_arrays

# split the list for parallel processing
# number of jobs are set by the number of WAV files
nj=`wc -l $expdir/wavfiles.list | awk '{print $1}'`
split_wavfiles=""
for n in `seq $nj`; do
  split_wavfiles="$split_wavfiles $output_wavfiles.$n"
done
utils/split_scp.pl $output_wavfiles $split_wavfiles || exit 1;

echo -e "Beamforming\n"
# making a shell script for each job
for n in `seq $nj`; do
cat << EOF > $expdir/log/beamform.$n.sh
while read line; do
  $BEAMFORMIT/BeamformIt -s \$line -c $input_arrays \
    --config_file `pwd`/conf/beamformit.cfg \
    --source_dir $sdir \
    --result_dir $odir
done < $output_wavfiles.$n
EOF
done

chmod a+x $expdir/log/beamform.*.sh
$cmd JOB=1:$nj $expdir/log/beamform.JOB.log \
  $expdir/log/beamform.JOB.sh

rm $odir/*.{del,del2,info,weat}
echo "`basename $0` Done."
