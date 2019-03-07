## DIHARD-2019-baseline-alltracks

#### Prerequisites
**1.** Kaldi\

#### Common instructions across tracks:
**1.** Select a directory to clone this repository (called <mod> here after) and execute the following command.
```
git clone https://github.com/iiscleap/DIHARD_2019_baseline_alltracks.git
```
**2.** Traverse to the directory of choice (called \<k\> here after) and clone the Kaldi repository using the following command.
```
git clone https://github.com/kaldi-asr/kaldi.git 
```
**3.** Copy the file \<mod\>/DIHARD_2019_baseline_alltracks/alltracksrun.sh into \<k\>/kaldi/egs/dihard_2018/v2
```
cp <mod>/DIHARD_2019_baseline_alltracks/alltracksrun.sh <k>/kaldi/egs/dihard_2018/v2
```

**4.** Copy files <mod>/DIHARD_2019_baseline_alltracks/make_dihard_2019_dev_eval_alltracks.sh and <mod>/DIHARD_2019_baseline_alltracks/make_dihard_2019_dev_eval_alltracks.py into <k>/kaldi/local.
```
cp <mod>/{make_dihard_2019_dev_eval_alltracks.py,make_dihard_2019_dev_eval_alltracks.sh} <k>/kaldi/local       
```

**5.** Create a directory called exp/xvector_nnet_1a in <k>/kaldi/egs/dihard_2018/v2
```
mkdir -p <k>/kaldi/exp/xvector_nnet_1a
```

**6.** Copy the final.raw, max_chunk_size, min_chunk_size and extract.config files of <mod>/DIHARD_2019_baseline_alltracks into the directory  <k>/kaldi/exp/xvector_nnet_1a.

```
cp <mod>/{final.raw, max_chunk_size, min_chunk_size,extract.config} <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
```
#### Track 1 instructions :


**1.**  Data preparation of DIHARD 2019 dev and eval for Track 1.
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 1 <path of DIHARD 2019 dev> <mod>/data/dihard_dev_2019_track1
```
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 1 <path of DIHARD 2019 eval> <mod>/data/dihard_eval_2019_track1
```

**2.** 
```
bash alltracksrun.sh --tracknum 1 --dihard_dev_2019_path <mod>/data/dihard_dev_2019_track1 --dihard_eval_2019_path <mod>/data/dihard_eval_2019_track1 --nnet_dir <k>/kaldi/exp/xvector_nnet_1a
```

#### Track 2 instructions :
We are generating SAD for this track using [mmmaat/denoising_DIHARD18](https://github.com/mmmaat/denoising_DIHARD18) which first denoise the audio files using cntk model and then use [webrtcvad](https://github.com/wiseman/py-webrtcvad).
**1.** Clone the required directory using following command
```
git clone https://github.com/mmmaat/denoising_DIHARD18.git
```
**2.** Follow the instructions in [mmmaat/denoising_DIHARD18](https://github.com/mmmaat/denoising_DIHARD18) repository to generate denoised files and to use webrtc to obtain SAD.
**3.** Generated SAD files should be kept inside  <path of DIHARD 2019 dev|eval>/sad_webrtc for DIHARD dataset generation
**4.**  Data preparation of DIHARD 2019 dev and eval for Track 2.
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 2 <path of DIHARD 2019 dev> <mod>/data/dihard_dev_2019_track2
```
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 2 <path of DIHARD 2019 eval> <mod>/data/dihard_eval_2019_track2
```

**5.** 
```
bash alltracksrun.sh --tracknum 2 --dihard_dev_2019_path <mod>/data/dihard_dev_2019_track2 --dihard_eval_2019_path <mod>/data/dihard_eval_2019_track2 --nnet_dir <k>/kaldi/exp/xvector_nnet_1a
```


