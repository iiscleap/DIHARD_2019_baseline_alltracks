## DIHARD-2019-baseline-alltracks

Diarization system used in all the tracks is [_JHU's Kaldi_](https://github.com/kaldi-asr/kaldi/tree/master/egs/dihard_2018/v2) x-vector based implementation, which is closely based on the JHU's DIHARD 2018 submission, as explained in the paper ['_Diarization is Hard: Some Experiences and Lessons Learned for the JHU Team in the Inaugural DIHARD Challenge_'](http://www.danielpovey.com/files/2018_interspeech_dihard.pdf).


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
Knowledge in Kaldi will be beneficial. Links below might be of some help

- [Kaldi tutorial](http://kaldi-asr.org/doc/tutorial.html "http://kaldi-asr.org/doc/tutorial.html")
- [Kaldi for Dummies tutorial](http://kaldi-asr.org/doc/kaldi_for_dummies.html "http://kaldi-asr.org/doc/kaldi_for_dummies.html")

 **2.** Webrtc (only for track 2)

https://github.com/wiseman/py-webrtcvad (download from the above page or the following command should work) 
```
pip install webrtcvad
```

**3.** Optional Denoising 

Requires cntk installation. 
(https://github.com/mmmaat/denoising_DIHARD18)


#### Instructions for all tracks:
**1.** Move to a directory to clone this baseline repository (called \<mod\> here after) and execute the following commands.
```
git clone https://github.com/iiscleap/DIHARD_2019_baseline_alltracks.git
```

```
cd <mod>/DIHARD_2019_baseline_alltracks
cp alltracksrun.sh <k>/kaldi/egs/dihard_2018/v2
cp run_beamform.sh <k>/kaldi/egs/dihard_2018/v2
cp {make_dihard_2019_dev_eval_alltracks.py,make_dihard_2019_dev_eval_alltracks.sh} <k>/kaldi/egs/dihard_2018/v2/local     
mkdir -p <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
cp {final.raw,max_chunk_size,min_chunk_size,extract.config} <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a
cp md_eval.pl <k>/kaldi/egs/dihard_2018/v2
```

**Note.** \<dev\> and \<eval\> will refer to DIHARD 2019 single channel development and evaluation datasets respectively. Similarly  \<dev_multi\> and \<eval_multi\> will refer to DIHARD 2019 multi channel development and evaluation datasets respectively.


#### Track 1 instructions :

**1.**  Data preparation of DIHARD 2019 dev and eval for Track 1.
```
cd <k>/kaldi/egs/dihard_2018/v2/
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 1 <dev> data/dihard_dev_2019_track1
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 1 <eval> data/dihard_eval_2019_track1
```

**2.** Execute the alltracksrun.sh file (example for running track 1) .. Requires track number and plda path of plda_track1 file: 
```
bash alltracksrun.sh --tracknum 1 --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track1
```

##### Running the above command generates rttm file for dev and eval in \<k\>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev/eval}_2019_track1/plda_scores/rttm
 The script will also display DER on dev.

##### Baseline results for DIHARD_DEV_2019 Track1 is in \<mod\>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track1.txt

#### Track 2 instructions :

**Note**: webrtc expects .wav files but DIHARD 2019 dataset has .flac files. Convert .flac files to .wav files.

**1.** Run the \<mod\>/DIHARD_2019_baseline_alltracks/flac_to_wav_usingsox.sh (this file uses [sox](http://sox.sourceforge.net/) command for the conversion) as follows : 

```
cd <mod>/DIHARD_2019_baseline_alltracks
bash flac_to_wav_usingsox.sh dihard_2019_dev.list <dev>/flac <dev>/wav
bash flac_to_wav_usingsox.sh dihard_2019_eval.list <eval>/flac <eval>/wav 
```
**2.** Execute the run_vad.sh in \<mod\>/DIHARD_2019_baseline_alltracks to create SAD files for DIHARD 2019 dev and eval single channel datasets. 
```
cd <mod>/DIHARD_2019_baseline_alltracks
bash run_vad.sh <dev>/wav
bash run_vad.sh <eval>/wav  
```
**3.** Copy all such .sad files into a folder named sad_webrtc in <dev|eval>
```
mkdir <dev>/sad_webrtc
cp <dev>/wav/*.sad <dev>/sad_webrtc
mkdir <eval>/sad_webrtc
cp <eval>/wav/*.sad <eval>/sad_webrtc
```
**4.** Data preparation of DIHARD 2019 dev and eval for Track 2.
```
cd <k>/kaldi/egs/dihard_2018/v2/
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 2 <dev> data/dihard_dev_2019_track2
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 2 <eval> dihard_eval_2019_track2
```
**5.** Execute the alltracksrun.sh file as shown below (requires track number option and plda path of plda_track2 file ) :  
```
bash alltracksrun.sh --tracknum 2 --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track2
```

##### Running the above command generates rttm file for dev and eval in \<k\>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev|eval}_2019_track2/plda_scores/rttm
The script will also display DER on dev.

##### Baseline results for DIHARD_DEV_2019 Track2 is in \<mod\>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track2.txt
  
  
#### (Optional) Track 2 with denoising instructions :

##### Dependencies : 
* [CNTK](https://docs.microsoft.com/en-us/cognitive-toolkit/setup-linux-python?tabs=cntkpy26):
  python version
* [webrtcvad](https://github.com/wiseman/py-webrtcvad)
* [Numpy](https://github.com/numpy/numpy)
* [Scipy](https://github.com/scipy/scipy)
* [Librosa](https://github.com/librosa/librosa)

Denoising which is a preprocessing step to be done for the webrtc vad step is explained in papers below.\
Sun, Lei, et al. "Speaker Diarization with Enhancing Speech for the
First DIHARD Challenge." Proc. Interspeech 2018 (2018):
2793-2797.[PDF](http://home.ustc.edu.cn/~sunlei17/pdf/lei_IS2018.pdf)

Gao, Tian, et al. "Densely connected progressive learning for
lstm-based speech enhancement." 2018 IEEE International Conference on
Acoustics, Speech and Signal Processing
(ICASSP). IEEE, 2018. [PDF](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8461861)

Sun, Lei, et al. "Multiple-target deep learning for LSTM-RNN based
speech enhancement." 2017 Hands-free Speech Communications and
Microphone Arrays (HSCMA). IEEE,
2017.[PDF](http://home.ustc.edu.cn/~sunlei17/pdf/MULTIPLE-TARGET.pdf)


**1.** Clone the repository [mmmaat/denoising_DIHARD18](https://github.com/mmmaat/denoising_DIHARD18), into a directory referred as <den> hereon.
```
cd <den>
git clone https://github.com/mmmaat/denoising_DIHARD18.git
```
**2.** Follow the steps in  [mmmaat/denoising_DIHARD18](https://github.com/mmmaat/denoising_DIHARD18) to obtain webrtc SAD, post denoising, in a directory referred as <sad_webrtc_den_dev> and <sad_webrtc_den_eval> . 
```
mv <sad_webrtc_den_dev> <dev>/den_sad_webrtc_dev
mv <sad_webrtc_den_eval> <eval>/den_sad_webrtc_eval
```
**3.** Data preparation of DIHARD 2019 dev and eval for Track 2 using denoising.
```
cd <k>/kaldi/egs/dihard_2018/v2/
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 2_den <dev> data/dihard_dev_2019_track2_den
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 2_den <eval> dihard_eval_2019_track2_den
```
**4.** Execute the alltracksrun.sh file as shown below (requires track number option and plda path of plda_track2 file ) :  
```
bash alltracksrun.sh --tracknum 2_den --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track2
```


##### Running the above command generates rttm file for dev and eval in \<k\>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev|eval}_2019_track2_den/plda_scores/rttm
The script will also display DER on dev.

##### Baseline results for DIHARD_DEV_2019 Track2 is in \<mod\>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track2_den.txt
-------------------------------------------------

#### Common instructions for Track 3 and 4:
Multichannel data for track 3 and 4 can be downloaded from [Chime 5 speech corpus](https://licensing.sheffield.ac.uk/i/data/chime5.html). Let <original_ch5> be the path where chime5 speech corpus will be unzipped.

##### Beamforming instructions:
Kaldi's Beamforming tool will be used for this task. Instructions follow.

**1.**  Install Beamforming using the following command.
```
cd <k>
./kaldi/tools/extras/install_beamformit.sh
```
**2.** Execute the following commands to append paths related to Beamforming in path.sh
```
cd <k>/kaldi
echo "BEAMFORMIT=\$KALDI_ROOT/tools/BeamformIt" >> path.sh
echo "export PATH=\$PATH:\$BEAMFORMIT" >> path.sh
```
**3.** Run the run_beamform.sh file as shown
```
cd <k>/kaldi/egs/dihard_2018/v2
./run_beamform.sh <original_ch5>/CHiME5/ <dev_multi> <eval_multi>
```

---------------------------------------------------
#### Track 3 instructions :
**1.** Data preparation of DIHARD 2019 dev and eval for Track 1.
```
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 3 <dev_multi> data/dihard_dev_2019_track3
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 3 <eval_multi> data/dihard_eval_2019_track3
```

**2.** Execute the alltracksrun.sh file as shown below (requires track number option and plda path of plda_track3 file ) :  
```
bash alltracksrun.sh --tracknum 3 --plda_path <mod>/DIHARD_2019_baseline_alltracks/plda_track3
```
##### Running the above command generates rttm file for multichannel dev and eval in <k>/kaldi/egs/dihard_2018/v2/exp/xvector_nnet_1a/xvectors_dihard_{dev|eval}_2019_track3/plda_scores/rttm

The script will also display DER on dev.

##### Baseline results for DIHARD_DEV_2019 Track3 is in <mod>/DIHARD_2019_baseline_alltracks/performance_metrics_dev_track3.txt
----------------------------------------------------------


#### Track 4 instructions :

**1.** Execute the run_vad.sh in \<mod\>/DIHARD_2019_baseline_alltracks to create SAD files for DIHARD 2019 dev and eval multi channel datasets. 
```
cd <mod>/DIHARD_2019_baseline_alltracks
bash run_vad.sh <dev_multi>/wav
bash run_vad.sh <eval_multi>/wav  
```

**2.** Copy all such .sad files into a folder named sad_webrtc in <dev_multi|eval_multi>
```
mkdir <dev_multi>/sad_webrtc
cp <dev_multi>/wav/*.sad <dev_multi>/sad_webrtc
mkdir <eval_multi>/sad_webrtc
cp <eval_multi>/wav/*.sad <eval_multi>/sad_webrtc
```

**3.** Data preparation of DIHARD 2019 dev and eval for Track 4.
```
cd <k>/kaldi/egs/dihard_2018/v2/
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval dev --tracknum 4 <dev_multi> data/dihard_dev_2019_track4
local/make_dihard_2019_dev_eval_alltracks.sh --devoreval eval --tracknum 4 <eval_multi> dihard_eval_2019_track4
```
-------------------------------------------
**Note :** Filewise performance metrics of DER, Jaccard Error Rate(JER), Mutual Information (MI) ... computed using the scoring script in [dscore](https://github.com/nryant/dscore "https://github.com/nryant/dscore")

**Note :** The readme of this repository uses DIHARD 2019 dataset as an example, but the scripts here will work on any dataset, provided the dataset structure is maintained as shown above and the dataset's list files are present in <mod>.
All you need is the that the dataset directory path passed to the data preparation files expects the contents within the directory to be structured as the example shown below
```
<path of dataset passed>
|-- flac/wav
|   |-- DH_0001.flac/DH_0001.wav
|   |-- DH_0002.flac/DH_0002.wav
|   |-- DH_0003.flac/DH_0003.wav
|-- sad
|   |-- DH_0001.lab
|   |-- DH_0002.lab
|   |-- DH_0003.lab
|-- rttm
|   |-- DH_0001.rttm
|   |-- DH_0002.rttm
|   |-- DH_0003.rttm
```
