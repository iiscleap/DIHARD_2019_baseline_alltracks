## DIHARD-2019-baseline-alltracks

Diarization system used in all the tracks is [_JHU's Kaldi_](https://github.com/kaldi-asr/kaldi/tree/master/egs/dihard_2018/v2) x-vector based implementation, which is closely based on the JHU's DIHARD 2018 submission, as explained in the paper ['_Diarization is Hard: Some Experiences and Lessons Learned for the JHU Team in the Inaugural DIHARD Challenge_'](http://www.danielpovey.com/files/2018_interspeech_dihard.pdf).


#### Prerequisites

**0.** DIHARD II development and evaluation releases
- Acquire the  [DIHARD II](https://coml.lscp.ens.fr/dihard/index.html)
  development and evaluation releases.
- Throughout the remainder of this document, the path to the development
  release will be referred to by **\<dev\>** and the path to the evaluation
  release will be referred to by **\<eval\>**.


**2.** Python

- all parts except denoising work with Python 2 or Python 3
- the optional denoising component relies on CNTK, which currently does not support Python 3.7


**2.** Kaldi 

- Install Kaldi

      git clone https://github.com/kaldi-asr/kaldi.git 
      cd kaldi
      cd tools; make; make openblas
      cd ../src
      ./configure --openblas-root=../tools/OpenBLAS/install
      make depend
      make

- Throughout the remainder of this document, the basepath of the directory
  where kaldi was cloned will be referred as  **\<k\>**
- Knowledge in Kaldi will be beneficial. If you are new to Kaldi, the links
  below might be of some help

  - [Kaldi tutorial](http://kaldi-asr.org/doc/tutorial.html "http://kaldi-asr.org/doc/tutorial.html")
  - [Kaldi for Dummies tutorial](http://kaldi-asr.org/doc/kaldi_for_dummies.html "http://kaldi-asr.org/doc/kaldi_for_dummies.html")


**3.** Voice activity detection (only for track 2)

For tracks where the reference speech segmentation is not provided we use the voice activity detection (VAD) module of [WebRTC](https://webrtc.org/) as implemented in [py-webrtcvad](https://github.com/wiseman/py-webrtcvad). For convenience, we use the wrapper script ``main_get_vad.py`` that is distributed as part of the [denoising_DIHARD18](https://github.com/staplesinLA/denoising_DIHARD18) repo. To install its dependencies:

    pip install numpy scipy librosa webrtcvad joblib    


**4.** Optional denoising 

For speech denoising we use the densely connected progressive learning LSTM-based model of [Lei et al. (2018)](http://home.ustc.edu.cn/~sunlei17/pdf/lei_IS2018.pdf), which is also contained in the ``denoising_DIHARD18`` repo cloned in the preceding step. The denoising model is implemented in [CNTK](https://github.com/Microsoft/CNTK), so requires a working CNTK installation as well as the Python [Wurlitzer](https://github.com/minrk/wurlitzer) package. To install these dependencies:

     sudo apt-get install openmpi-bin
     pip install cntk-gpu
     pip install wurlitzer

**NOTE** that as of March 2019, CNTK does not yet support Python 3.7, so you will need to use Python 3.6 or earlier for denoising.


#### Instructions for all tracks:
**1.** Move to a directory (hereafter referred to as **\<mod\>**) and clone
this baseline repository:

    git clone https://github.com/iiscleap/DIHARD_2019_baseline_alltracks.git

then execute the following commands:

    cd <mod>/DIHARD_2019_baseline_alltracks
    git lfs clone https://github.com/staplesinLA/denoising_DIHARD18.git
    cd denoising_DIHARD18
    git checkout 50c4cc6
    cd ..
    cp alltracksrun.sh <k>/kaldi/egs/dihard_2018/v2
    cp {make_dihard_2019_dev_eval_alltracks.py,make_dihard_2019_dev_eval_alltracks.sh} <k>/kaldi/egs/dihard_2018/v2/local     
    mkdir -p <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
    cp {final.raw,max_chunk_size,min_chunk_size,extract.config} <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
    cp md_eval.pl <k>/kaldi/egs/dihard_2018/v2


#### Track 1 instructions :

**1.**  Prepare single channel data from development and evaluation releases
for track 1:

    cd <k>/kaldi/egs/dihard_2018/v2/
    local/make_dihard_2019_dev_eval_alltracks.sh \
        --devoreval dev --tracknum 1 \
       <dev>/data/single_channel data/dihard_dev_2019_track1
    local/make_dihard_2019_dev_eval_alltracks.sh \
        --devoreval eval --tracknum 1 \
        <eval>/data/single_channel data/dihard_eval_2019_track1


**2.** Execute the ``alltracksrun.sh`` script with the following arguments:

    bash alltracksrun.sh \
        --tracknum 1 --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track1


This will create RTTM files for the development and evaluation sets in

    <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev/eval}_2019_track1/plda_scores/rttm.

The script will also display DER on the development set.

**3.** Baseline results  on the development set for track 1 are found in

     <mod>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track1.txt

This file contains filewise and overall metrics as compute using [dscore](https://github.com/nryant/dscore)



#### Track 2 instructions :

**1.** Convert the FLAC files from the LDC releases to WAV in order to run VAD.
Run the ``flac_to_wav_usingsox.sh`` script as follows:

    cd <mod>/DIHARD_2019_baseline_alltracks
    bash flac_to_wav_usingsox.sh dihard_2019_dev.list \
        <dev>/data/single_channel/flac <dev>/data/single_channel/wav
    bash flac_to_wav_usingsox.sh dihard_2019_eval.list \
        <eval>/data/single_channel/flac <eval>/data/single_channel/wav 

**NOTE** that this script depends on [SoX](http://sox.sourceforge.net/).

**2.** Perform VAD using the WAV files generated in the above step. Execute
the ``run_vad.sh`` script:

    cd <mod>/DIHARD_2019_baseline_alltracks
    bash run_vad.sh \
        <dev>/data/single_channel/wav \
        <dev>/data/single_channel/sad_webrtc
    bash run_vad.sh \
        <eval>/data/single_channel/wav \
        <eval>/data/single_channel/sad_webrtc

For each wav file in the development/evaluation set, there will now be a label
file (ending in the extension ``.lab``) under ``sad_webrtc/``.

**3.** Prepare single channel data from development and evaluation releases
for track 2:

    cd <k>/kaldi/egs/dihard_2018/v2/
    local/make_dihard_2019_dev_eval_alltracks.sh \
        --devoreval dev --tracknum 2 \
        <dev>/data/single_channel data/dihard_dev_2019_track2
    local/make_dihard_2019_dev_eval_alltracks.sh \
        --devoreval eval --tracknum 2 \
        <eval>/data/single_channel data/dihard_eval_2019_track2

**4.** Execute the ``alltracks.sh`` script with the following arguments:

    bash alltracksrun.sh --tracknum 2 --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track2

This will create RTTM files for the development and evaluation sets in

    <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev|eval}_2019_track2/plda_scores/rttm

The script will also display DER on the development set.

**5.** Baseline results on the development set for track 2 are found in:

    <mod>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track2.txt

This file contains filewise and overall metrics as computed using
[dscore](https://github.com/nryant/dscore)
  


#### Track 2 with denoised audio instructions:

**1.** Make sure you have installed the speech denoising prequisites (see the
initial section of this document).


**2.** Convert the FLAC files from the LDC releases to WAV as described in
step 1 of the Track 2 instructions. 

**NOTE:** If you previously performed the FLAC to WAV conversion for track 2,
you may omit this step.


**3.** Perform denoising

Denoise the WAV files generated in the above ste. Execute the
``run_denoising.sh`` script:

    cd <mod>/DIHARD_2019_baseline_alltracks
    bash run_denoising.sh \
        <dev>/data/single_channel/wav \
        <dev>/data/single_channel/wav_den
    bash run_denoising.sh \
        <eval>/data/single_channel/wav \
        <eval>/data/single_channel/wav_den

This will produce a denoised version of each wav file in the ``wav_den``
directory.

**NOTE:** Because the denoising mode is computationally expensive, by default
the ``run_denoising.sh`` script will attempt to use a GPU. If you wish to 
perform decoding using the CPU, edit the value of ``USE_GPU`` as described
in the comments. 


**4.** Perform VAD using the denoised WAV files generated in the above step.
Execute the ``run_vad.sh`` script:

    cd <mod>/DIHARD_2019_baseline_alltracks
    bash run_vad.sh \
        <dev>/data/single_channel/wav_den \
        <dev>/data/single_channel/den_sad_webrtc_dev
    bash run_vad.sh \
        <eval>/data/single_channel/wav \
        <eval>/data/single_channel/den_sad_webrtc_eval

For each wav file in the development/evaluation set, there will now be a label
file (ending in the extension ``.lab``) under ``den_sad_webrtc_dev`` and
``den_sad_webrtc_eval``.


**5.** Prepare the denoised single channel data from the development and
evaluation releases for track 2:

    cd <k>/kaldi/egs/dihard_2018/v2/
    local/make_dihard_2019_dev_eval_alltracks.sh \
        --devoreval dev --tracknum 2_den \
        <dev>/data/single_channel data/dihard_dev_2019_track2_den
    local/make_dihard_2019_dev_eval_alltracks.sh \
        --devoreval eval --tracknum 2_den \
        <eval>/data/single_channel dihard_eval_2019_track2_den


**6.** Execute the ``alltracks.sh`` script with the following arguments:

    bash alltracksrun.sh --tracknum 2_den --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track2

This will create RTTM files for the development and evaluation sets in

    <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev|eval}_2019_track2_den/plda_scores/rttm

The script will also display DER on the development set.

**7.** Baseline results on the development set for track 2 are found in:

    <mod>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track2_den.txt

This file contains filewise and overall metrics as compute using [dscore](https://github.com/nryant/dscore)


#### Using these scripts with your own data.

**Note :** The readme of this repository uses DIHARD 2019 dataset as an example, but the scripts here will work on any dataset, provided the dataset structure is maintained as shown above and the dataset's list files are present in <mod>.
All you need is the that the dataset directory path passed to the data preparation files expects the contents within the directory to be structured as the example shown below
```
<path of dataset passed>
|-- flac
|   |-- DH_0001.flac
|   |-- DH_0002.flac
|   |-- DH_0003.flac
|-- sad
|   |-- DH_0001.lab
|   |-- DH_0002.lab
|   |-- DH_0003.lab
|-- rttm
|   |-- DH_0001.rttm
|   |-- DH_0002.rttm
|   |-- DH_0003.rttm
```
