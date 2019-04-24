# Begin configuration section.
nj=10 
decode_nj=20

# End configuration section

. ./utils/parse_options.sh

. ./cmd.sh
. ./path.sh

chime5_corpus=$1
audio_dir=${chime5_corpus}/audio

# Beamforming using reference arrays
# enhanced WAV directory
enhandir=${chime5_corpus}/outputs
outputdirdev=$2
outputdireval=$3

for dset in train dev eval; do
    for mictype in u01 u02 u03 u04 u05 u06; do
      local/run_beamformit.sh --cmd "$train_cmd" \
                  ${audio_dir}/${dset} \
                  ${enhandir}/${dset}_beamformit_${mictype} \
                  ${mictype}
    done
done


#Copying beamformed files to the output directory
for mictype in u01 u02 u03 u04 u05 u06; do
	directrain=`echo "${enhandir}/train_beamformit_${mictype}"`
	listtrain=`find $directrain -type f -name "*.wav"`

	direcdev=`echo "${enhandir}/dev_beamformit_${mictype}"`
	listdev=`find $direcdev -type f -name "*.wav"`

	direceval=`echo "${enhandir}/eval_beamformit_${mictype}"`
	listeval=`find $direceval -type f -name "*.wav"`

	mkdir -p "${outputdirdev}/wav"
	mkdir -p "${outputdireval}/wav"

	for i in listtrain; do
		mv i ${outputdirdev}/wav

	for j in listdev; do
		mv j ${outputdirdev}/wav

	for k in listeval; do
		mv k ${outputdireval}/wav



rmdir $enhandir