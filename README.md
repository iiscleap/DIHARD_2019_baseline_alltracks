## DIHARD-2019-baseline-alltracks

#### Prerequisites
**1.** Kaldi
**2.** webrtc

#### Mandatory instructions for all tracks:
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

**7.** Dataset directory path passed to the data preparation files expects the contents within the directory to be structured as the example shown below

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
**8.** <dev> and <eval> will be shothands for the paths of DIHARD 2019 single channel development and evaluation datasets respectively, which has the structure complying to the one shown above. 

**Note :** The readme of this repository uses DIHARD 2019 dataset as an example, but the scripts here will work on any dataset, provided the dataset structure is maintained as shown above and the dataset's list files are present in <mod>.

**Note :** Filewise performance metrics of DER, Jaccard Error Rate(JER), Mutual Information (MI) ... computed using the scoring script in [dscore]((https://github.com/nryant/dscore "https://github.com/nryant/dscore")
#### Track 1 instructions :


**1.**  Data preparation of DIHARD 2019 dev and eval for Track 1.
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 1 <path of DIHARD 2019 dev> <mod>/data/dihard_dev_2019_track1
```
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 1 <path of DIHARD 2019 eval> <mod>/data/dihard_eval_2019_track1
```

**2.** Execute the alltracks.sh file as shown below : 
```
bash alltracksrun.sh --tracknum 1 --plda_path <mod>/plda
```

#### Track 2 instructions :

##### Speech Activity Detection (SAD) for this track is computed using the [webrtc](https://github.com/wiseman/py-webrtcvad) tool. 

**Note**: webrtc expects .wav files but DIHARD 2019 dataset has .flac files. Convert .flac files to .wav files.

Run the flac_to_wav_usingsox.sh (this file uses [sox](http://sox.sourceforge.net/) command for the conversion) as follows : 
Let <dev_wav> and <eval_wav> be the desired paths where the corresponding wav files should get created for DIHARD 2019 .dev and .eval flac files, respectively.

```
bash flac_to_wav_usingsox.sh <mod>/dihard_2019_dev.list <dev>/flac <dev_wav>
bash flac_to_wav_usingsox.sh <mod>/dihard_2019_eval.list <eval>/flac <eval_wav> 
```

We are generating SAD for this track using [mmmaat/denoising_DIHARD18](https://github.com/mmmaat/denoising_DIHARD18) which first denoise the audio files using cntk model and then use [webrtcvad](https://github.com/wiseman/py-webrtcvad). Install it using the command below.
```
pip install webrtcvad
```

Execute the run_vad.sh in <mod> to create SAD files for DIHARD 2019 dev and eval single channel datasets. 
```
bash run_vad.sh <dev_wav> 
```
The above command will create a .sad file for each .wav file in <dev_wav>. Copy all such .sad files into a folder named sad_webrtc in <dev>
```
mkdir <dev>/sad_webrtc
cp <dev_wav>/*.sad <dev>/sad_webrtc
```





Data preparation of DIHARD 2019 dev and eval for Track 2.
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 2 <dev> <mod>/data/dihard_dev_2019_track2
```
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 2 <eval> <mod>/data/dihard_eval_2019_track2
```

Execute the alltracks.sh file as shown below :  
```
bash alltracksrun.sh --tracknum 2 --plda_path <mod>/plda
```


