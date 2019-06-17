Implementation of diarization baseline for the [Second DIHARD Speech Diarization Challenge (DIHARD II)](https://coml.lscp.ens.fr/dihard/index.html). The baseline is based on the system used by [JHU](https://www.clsp.jhu.edu/) in their submission to [DIHARD I](https://coml.lscp.ens.fr/dihard/2018/index.html), with the exception that it omits the [Variational-Bayes](https://speech.fit.vutbr.cz/software/vb-diarization-eigenvoice-and-hmm-priors) refinement step:

- Sell, Gregory, et al. (2018). "Diarization is Hard: Some experiences and lessons learned for the JHU team in the Inaugural DIHARD Challenge." Proceedings of INTERSPEECH 2018. 2808-2812. ([paper](http://www.danielpovey.com/files/2018_interspeech_dihard.pdf))

The x-vector extractor and PLDA parameters were trained on [VoxCeleb I and II](http://www.robots.ox.ac.uk/~vgg/data/voxceleb/) using data augmentation (additive noise and reverberation), while the whitening transformation was learned from the DIHARD II development set. 

For further details about the training pipeline, please consult the companion paper to the challenge.



## Prerequisites

The following packages are required to run the baseline.

- [Python](https://www.python.org/) >= 2.7
- [Kaldi](https://github.com/kaldi-asr/kaldi)
- [dscore](https://github.com/nryant/dscore)
- the [denoising_DIHARD18](https://github.com/staplesinLA/denoising_DIHARD18) speech denoising and SAD tools (**OPTIONAL**)
- [CNTK](https://github.com/microsoft/CNTK) (**OPTIONAL**)

The **OPTIONAL** components are only required to run the track 2 and track 4 recipes.


Additionally, you will need to obtain the relevant data releases from [LDC](https://www.ldc.upenn.edu/) and [University of Sheffield](http://spandh.dcs.shef.ac.uk/):

- DIHARD II development set (**LDC2019E31**)

- DIHARD II evaluation set (**LDC2019E32**)

- CHiME-5 training, development, and evaluation sets

For instructions on obtaining these sets, please consult the [DIHARD II website](https://coml.lscp.ens.fr/dihard/).

## Installation

To install the baseline and all its prerequisites, clone the repo:

```bash
git clone https://github.com/iiscleap/DIHARD_2019_baseline_alltracks.git
```

And run the the installation scripts in the ``tools/`` directory:

```bash
cd DIHARD_2019_baseline_alltracks/tools
./install_kaldi.sh
./install_dscore.sh
./install_den.sh
```

If you do not intend to run the track 2 or track 4 recipes, you may omit the call to ``install_den.sh``.

Please check the output of these scripts to ensure that installation has succeeded. If succesful, you should see ``Successfully installed {Kaldi,dscore,denoising/VAD software}.`` printed at the end. If installation of a component fails, please consult the output of the relevant installation script for additional details.
    
    

## Running the baseline

We include full recipes for reproducing the baseline results for all four DIHARD II tracks:

- **Track 1**  —  Diarization from single channel audio using reference SAD.
- **Track 2**  —  Diarization from single channel audio using system SAD.
- **Track 3**  —  Diarization from multichannel audio using reference SAD.
- **Track 4**  —  Diarization from multichannel audio using system SAD.

These recipes are located under the ``recipes/`` directory, which has the following structure:

- ``track1/``  --  recipe for track 1
- ``track2/``  --  recipe for track 2 with SAD performed from original source audio
- ``track2_den/``  --  recipe for track 2 with SAD performed from denoised audio
- ``track3/``  --  recipe for track 3
- ``track4/``  --  recipe for track 4 with SAD performed from original source audio
- ``track4_den/``  --  recipe for track 4 with SAD performed from denoised audio

Each recipe directory contains three files:

- ``run.sh``  —  BASH script that executes recipe
- ``metrics_dev_expected.stdout``  —  expected output to STDOUT of the scoring tool on the output of the recipe for the DIHARD II DEV set
- ``metrics_dev_expected.stderr``  --  expected output to STDERR of the scoring tool on the output of the recipe for the DIHARD II DEV set

To run a recipe, switch to the corresponding directory, edit the paths at the top of ``run.sh`` to point to the locations of the DIHARD II DEV and EVAL releases on your system, and then execute ``run.sh``. When finished, there will be four additions to the directory:

- ``rttm_dev/``   —  RTTM files output by the baseline for the DIHARD II DEV set
- ``rttm_eval/`` —  RTTM files output by the baseline for the DIHARD II EVAL set 
- ``metrics_dev.stdout``  —  output to STDOUT of the scoring tool for the RTTM files contained in ``rttm_dev/``
- ``metrics_dev.stderr``  --  output to STDERR of the scoring tool for the RTTM files contained in ``rttm_eval/``



### Example: Track 1

To replicate the results for track 1, switch to the ``recipes/track1/`` directory

```bash
cd recipes/track1
```

and open the ``run.sh`` script file in a text editor. The first section of this script defines paths to the official DIHARD II DEV and EVAL releases and should look something like the following:

```bash
#####################################
#### Set following paths  ###########
#####################################
# Path to root of DIHARD II dev release (LDC2019E31).
DIHARD_DEV_DIR=/scratch/nryant/dihard2/deliveries/LDC2019E31_Second_DIHARD_Challenge_Development_Data/

# Path to root of DIHARD II eval release (LDC2019E32)   
DIHARD_EVAL_DIR=/scratch/nryant/dihard2/deliveries/LDC2019E32_Second_DIHARD_Challenge_Evaluation_Data_SCRUBBED/
```

Change the variables ``DIHARD_DEV_DIR`` and ``DIHARD_EVAL_DIR`` so that they point to the roots of the DIHARD II DEV and EVAL releases on your filesystem. Save your changes, exit the editor, and run

```bash
./run.sh
```

This will run the baseline, printing status updates to STDOUT with the first few lines of output resembling:

```
Preparing data directory for DEV set...
fix_data_dir.sh: kept all 28235 utterances.
fix_data_dir.sh: old files are kept in data/dihard_dev_2019_track1/.backup
Preparing data directory for EVAL set....
fix_data_dir.sh: kept all 28963 utterances.
fix_data_dir.sh: old files are kept in data/dihard_eval_2019_track1/.backup
Diarizing...
Running baseline for Track 1...
Extracting MFCCs....
steps/make_mfcc.sh --cmd run.pl --max-jobs-run 20 --nj 40 --write-utt2num-frames true --mfcc-config conf/mfcc.conf data/dihard_dev_2019_track1 exp/make_mfcc/dihard_dev_2019_track1 /scratch/nryant/dihard2/baseline/DIHARD_2019_baseline_alltracks/tools/kaldi/egs/dihard_2018/v2/mfcc
utils/validate_data_dir.sh: Successfully validated data-directory data/dihard_dev_2019_track1
steps/make_mfcc.sh [info]: segments file exists: using that.
It seems not all of the feature files were successfully processed (28089 != 28235);
consider using utils/fix_data_dir.sh data/dihard_dev_2019_track1
Succeeded creating MFCC features for dihard_dev_2019_track1
fix_data_dir.sh: kept 28089 utterances out of 28235
fix_data_dir.sh: old files are kept in data/dihard_dev_2019_track1/.backup
steps/make_mfcc.sh --cmd run.pl --max-jobs-run 20 --nj 40 --write-utt2num-frames true --mfcc-config conf/mfcc.conf data/dihard_eval_2019_track1 exp/make_mfcc/dihard_eval_2019_track1 /scratch/nryant/dihard2/baseline/DIHARD_2019_baseline_alltracks/tools/kaldi/egs/dihard_2018/v2/mfcc
utils/validate_data_dir.sh: Successfully validated data-directory data/dihard_eval_2019_track1
steps/make_mfcc.sh [info]: segments file exists: using that.
It seems not all of the feature files were successfully processed (28808 != 28963);
consider using utils/fix_data_dir.sh data/dihard_eval_2019_track1
Succeeded creating MFCC features for dihard_eval_2019_track1
fix_data_dir.sh: kept 28808 utterances out of 28963
fix_data_dir.sh: old files are kept in data/dihard_eval_2019_track1/.backup
MFCC extraction finished. See /scratch/nryant/dihard2/baseline/DIHARD_2019_baseline_alltracks/tools/kaldi/egs/dihard_2018/v2/exp/make_mfcc for logs.
```

If any stage fails, the script will immediately exit with status 1.

After 20-40 minutes (depending on your hardware), the script will finish with the final lines of output resembling:

```
Performing agglomerative hierarchical clustering (AHC) using threshold -0.3 for DEV...
diarization/cluster.sh --cmd run.pl --mem 4G --nj 40 --threshold -0.3 --rttm-channel 1 exp/xvector_nnet_1a/xvectors_dihard_dev_2019_track1/plda_scores exp/xvector_nnet_1a/xvectors_dihard_dev_2019_track1/plda_scores
diarization/cluster.sh: clustering scores
diarization/cluster.sh: combining labels
diarization/cluster.sh: computing RTTM
Clustering finished for DEV. See exp/xvector_nnet_1a/xvectors_dihard_dev_2019_track1/plda_scores/log for logs.
Performing agglomerative hierarchical clustering (AHC) using threshold -0.3 for EVAL...
diarization/cluster.sh --cmd run.pl --mem 4G --nj 40 --threshold -0.3 --rttm-channel 1 exp/xvector_nnet_1a/xvectors_dihard_eval_2019_track1/plda_scores exp/xvector_nnet_1a/xvectors_dihard_eval_2019_track1/plda_scores
diarization/cluster.sh: clustering scores
diarization/cluster.sh: combining labels
diarization/cluster.sh: computing RTTM
Clustering finished for EVAL. See exp/xvector_nnet_1a/xvectors_dihard_eval_2019_track1/plda_scores/log for logs.
Extracting RTTM files...
Scoring DEV set RTTM...
```

This produces RTTM for both the DEV and EVAL sets in ``rttm_dev/`` and ``rttm_eval/`` respectively. Additionally, output of the offical scoring tool for the RTTM files in ``rttm_dev/`` will be produced and located in ``metrics_dev.{stdout,stderr}``, which may be compared against the expected values in ``metrics_dev_expected.{stdout,stderr}``.


## Expected results

Expected DER and JER for the baseline system on the DIHARD II development and evaluation sets are presented in Tables 1 and 2.

**Table 1: Expected baseline performance on DIHARD II development set. The *Enhancement* column indicates whether or not speech enhancement (denoising) was applied prior to SAD.** 

| Track   | Enhancement | DER   | JER   |
| ------- | ----------- | ----- | ----- |
| Track 1 | No          | 23.70 | 56.20 |
| Track 2 | No          | 46.33 | 69.26 |
| Track 2 | Yes         | 38.26 | 62.59 |
| Track 3 | No          | 59.73 | 68.00 |
| Track 4 | No          | 87.55 | 88.08 |
| Track 4 | Yes         | 82.49 | 83.60 |

**Table 2: Expected baseline performance on DIHARD II evaluation set. The *Enhancement* column indicates whether or not speech enhancement (denoising) was applied prior to SAD.** 

| Track   | Enhancement | DER   | JER   |
| ------- | ----------- | ----- | ----- |
| Track 1 | No          | 25.99 | 59.51 |
| Track 2 | No          | 50.12 | 72.10 |
| Track 2 | Yes         | 40.86 | 66.60 |
| Track 3 | No          | 50.85 | 65.91 |
| Track 4 | No          | 83.41 | 85.12 |
| Track 4 | Yes         | 77.34 | 80.42 |

## Reproducibility
The above results were produced using the provided recipes with their default settings running on a single machine with the following specs:

- 2 x Intel E5-2680 v4
- 6 x Nvidia GXT 1080
- 384 GB RAM
- Ubuntu 18.04 LTS
-  g++ 7.4.0
- libstdc++.so.6.0.25
- CUDA 10.0

Running the recipes on a grid or with a different number of splits (controlled by  ``NJOBS``) may result in different results due to the use of dithering during MFCC feature extraction. Changing the value of ``TRUNCATE_MINUTES`` in ``run_denoising.sh`` may also result in different results due to slight changes in the output of SAD.