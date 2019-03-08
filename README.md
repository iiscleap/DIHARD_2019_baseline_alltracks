## DIHARD-2019-baseline-alltracks
Download the DIHARD development and evaluation data.

#### Prerequisites

**0.** Python (no version requirements)

**1.** Kaldi (the basepath where kaldi is cloned will be refered as  \<k\> )
```
git clone https://github.com/kaldi-asr/kaldi.git 
cd kaldi
cd tools; make;
cd ../src; ./configure; make
```
 **2.** Webrtc (only for track 2)

https://github.com/wiseman/py-webrtcvad (download from the above page or the following command should work) 
```
pip install webrtcvad
```

**3.** Optional Denoising 

Requires cntk installation. 
(https://github.com/mmmaat/denoising_DIHARD18)


#### Instructions for all tracks:
**1.** Move to a directory to clone this baseline repository (called \<mod\> here after) and execute the following command.
```
git clone https://github.com/iiscleap/DIHARD_2019_baseline_alltracks.git
```

**2.** Copy the file \<mod\>/DIHARD_2019_baseline_alltracks/alltracksrun.sh into \<k\>/kaldi/egs/dihard_2018/v2
```
cp <mod>/DIHARD_2019_baseline_alltracks/alltracksrun.sh <k>/kaldi/egs/dihard_2018/v2
```

**3.** Copy files \<mod\>/DIHARD_2019_baseline_alltracks/make_dihard_2019_dev_eval_alltracks.sh and \<mod\>/DIHARD_2019_baseline_alltracks/make_dihard_2019_dev_eval_alltracks.py into \<k>\/kaldi/egs/dihard_2018/v2/local.
```
cp <mod>/{make_dihard_2019_dev_eval_alltracks.py,make_dihard_2019_dev_eval_alltracks.sh} <k>/kaldi/egs/dihard_2018/v2/local       
```

**4.** Create a directory called exp/xvector_nnet_1a in \<k\>/kaldi/egs/dihard_2018/v2
```
mkdir -p <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
```

**5.** Copy the final.raw, max_chunk_size, min_chunk_size and extract.config files of <mod>/DIHARD_2019_baseline_alltracks into the directory  <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a.

```
cp <mod>/{final.raw, max_chunk_size, min_chunk_size,extract.config} <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
```


#### Track 1 instructions :

**0.** <dev> and <eval> will refer to DIHARD 2019 single channel development and evaluation datasets respectively. 

**1.**  Data preparation of DIHARD 2019 dev and eval for Track 1.
```
cd <k>/kaldi/egs/dihard_2018/v2/
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 1 <path of DIHARD 2019 dev> <mod>/data/dihard_dev_2019_track1
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 1 <path of DIHARD 2019 eval> <mod>/data/dihard_eval_2019_track1
```

**2.** Execute the alltracks.sh file (example for running track 1) .. Requires track number and plda path : 
```
bash alltracksrun.sh --tracknum 1 --plda_path <mod>/plda
```

##### Running the above command generates rttm file for dev and eval in <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev/eval}_2019_track1/plda_scores/rttm
 
The script will also display DER on dev.

#### Track 2 instructions :

**Note**: webrtc expects .wav files but DIHARD 2019 dataset has .flac files. Convert .flac files to .wav files.

Run the /<mod>/flac_to_wav_usingsox.sh (this file uses [sox](http://sox.sourceforge.net/) command for the conversion) as follows : 

```
bash flac_to_wav_usingsox.sh <mod>/dihard_2019_dev.list <dev>/flac <dev>/wav
bash flac_to_wav_usingsox.sh <mod>/dihard_2019_eval.list <eval>/flac <eval>/wav 
```
Execute the run_vad.sh in <mod> to create SAD files for DIHARD 2019 dev and eval single channel datasets. 
```
cd <mod>
bash run_vad.sh <dev>/wav
bash run_vad.sh <eval>/wav  
```
Copy all such .sad files into a folder named sad_webrtc in <dev/eval>
```
mkdir <dev>/sad_webrtc
cp <dev>/wav/*.sad <dev>/sad_webrtc
mkdir <eval>/sad_webrtc
cp <eval>/wav/*.sad <eval>/sad_webrtc
```
Data preparation of DIHARD 2019 dev and eval for Track 2.
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 2 <dev> <mod>/data/dihard_dev_2019_track2
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 2 <eval> <mod>/data/dihard_eval_2019_track2
```
Execute the alltracks.sh file as shown below (with track 2 option and plda path) :  
```
bash alltracksrun.sh --tracknum 2 --plda_path <mod>/plda
```

##### Running the above command generates rttm file for dev and eval in <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev/eval}_2019_track2/plda_scores/rttm
 and displays the dev DER.
  
-------------------------------------------------

**Note :** Filewise performance metrics of DER, Jaccard Error Rate(JER), Mutual Information (MI) ... computed using the scoring script in [dscore]((https://github.com/nryant/dscore "https://github.com/nryant/dscore")

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

