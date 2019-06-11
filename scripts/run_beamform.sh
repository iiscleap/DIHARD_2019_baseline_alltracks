#!/bin/bash
. ./cmd.sh
. ./path.sh

audio_dir=$1
output_dir=$2
if [ -d $output_dir ]; then
    mkdir -p $output_dir
fi
local/run_beamformit.sh \
    --cmd "$train_cmd" ${audio_dir} ${output_dir} ${mictype}
