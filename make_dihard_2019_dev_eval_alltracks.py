#!/usr/bin/env python3

# This script is called by local/make_dihard_2019_dev_eval_alltracks.sh, and it creates the
# necessary files for DIHARD 2018 development directory.

import sys, os

def prepare_dihard_2019_dev_track1(src_dir, data_dir):
    print('prepare_dihard_2019_dev_track1 CALLED')
    wavscp_fi = open(data_dir + "/wav.scp" , 'w')
    utt2spk_fi = open(data_dir + "/utt2spk" , 'w')
    segments_fi = open(data_dir + "/segments" , 'w')
    rttm_fi = open(data_dir + "/rttm" , 'w')
    reco2num_spk_fi = open(data_dir + "/reco2num_spk" , 'w')

    towalk = os.path.join(src_dir)

    for root, dirs, files in os.walk(towalk):
        #print ("here")
        flacpath = os.path.join(root,'flac') 
        rttmpath = os.path.join(root,'rttm')
        sadpath = os.path.join(root,'sad')




        for sadroot, _ , labs in os.walk(sadpath):



            for filename in labs: 
                if filename.endswith(".lab"):
                #if filename.endswith(".sad"):
                    utt = os.path.basename(filename).split(".")[0]
                    
                    lines = open(os.path.join(sadroot,filename), 'r').readlines()
                    segment_id = 0
                    for line in lines:
                        start, end, speech = line.split()
                        #start, end = line.split()
                        segment_id_str = "{}_{}".format(utt, str(segment_id).zfill(4))
                        segments_str = "{} {} {} {}\n".format(segment_id_str, utt, start, end)
                        utt2spk_str = "{} {}\n".format(segment_id_str, utt)
                        segments_fi.write(segments_str)
                        utt2spk_fi.write(utt2spk_str)
                        segment_id += 1

                    wav_str = "{} sox -t flac {}/{}.flac -t wav -r 16k "\
                           "-b 16 --channels 1 - |\n".format(utt, flacpath, utt) 

                    #wav_str = "{} sox -c 1 -t wavpcm -s {}/{}.wav -r 16000 -t wavpcm - |\n".format(utt, src_dir, utt)
                    wavscp_fi.write(wav_str)

                    with open("{}/{}.rttm".format(rttmpath, utt), 'r') as fh:
                        rttm_str = fh.read()
                    rttm_fi.write(rttm_str)
                    with open("{}/{}.rttm".format(rttmpath, utt), 'r') as fh:
                        rttm_list = fh.readlines()
                    spk_list = map(lambda x: (x.split())[7], rttm_list) 
                    num_spk = len(set(spk_list))
                    reco2num_spk_fi.write("{} {}\n".format(utt, num_spk))




    wavscp_fi.close()
    utt2spk_fi.close()
    segments_fi.close()
    rttm_fi.close()
    reco2num_spk_fi.close()
    return 0


def prepare_dihard_2019_eval_track1(src_dir, data_dir):
    print('prepare_dihard_2019_eval_track1 CALLED')

    wavscp_fi = open(data_dir + "/wav.scp" , 'w')
    utt2spk_fi = open(data_dir + "/utt2spk" , 'w')
    segments_fi = open(data_dir + "/segments" , 'w')


    towalk = os.path.join(src_dir)

    for root, dirs, files in os.walk(towalk):
        flacpath = os.path.join(root,'flac') 
        rttmpath = os.path.join(root,'rttm')
        sadpath = os.path.join(root,'sad')




        for sadroot, _ , labs in os.walk(sadpath):



            for filename in labs: 
                if filename.endswith(".lab"):
                #if filename.endswith(".sad"):
                    utt = os.path.basename(filename).split(".")[0]
                    
                    lines = open(os.path.join(sadroot,filename), 'r').readlines()
                    segment_id = 0
                    for line in lines:
                        start, end, speech = line.split()
                        #start, end = line.split()
                        segment_id_str = "{}_{}".format(utt, str(segment_id).zfill(4))
                        segments_str = "{} {} {} {}\n".format(segment_id_str, utt, start, end)
                        utt2spk_str = "{} {}\n".format(segment_id_str, utt)
                        segments_fi.write(segments_str)
                        utt2spk_fi.write(utt2spk_str)
                        segment_id += 1

                    wav_str = "{} sox -t flac {}/{}.flac -t wav -r 16k "\
                           "-b 16 --channels 1 - |\n".format(utt, flacpath, utt) 

                    #wav_str = "{} sox -c 1 -t wavpcm -s {}/{}.wav -r 16000 -t wavpcm - |\n".format(utt, src_dir, utt)
                    wavscp_fi.write(wav_str)






    wavscp_fi.close()
    utt2spk_fi.close()
    segments_fi.close()

    return 0



def prepare_dihard_2019_dev_track2(src_dir, data_dir):
    print('prepare_dihard_2019_dev_track2 CALLED')

    #print('heree')
    wavscp_fi = open(data_dir + "/wav.scp" , 'w')
    utt2spk_fi = open(data_dir + "/utt2spk" , 'w')
    segments_fi = open(data_dir + "/segments" , 'w')
    rttm_fi = open(data_dir + "/rttm" , 'w')
    reco2num_spk_fi = open(data_dir + "/reco2num_spk" , 'w')

    towalk = os.path.join(src_dir)

    for root, dirs, files in os.walk(towalk):
        flacpath = os.path.join(root,'flac') 
        rttmpath = os.path.join(root,'rttm')
        sadpath = os.path.join(root,'sad')
        sad_webrtcpath = os.path.join(root,'sad_webrtc')



        for sadroot, _ , labs in os.walk(sad_webrtcpath):


            for filename in labs: 
                if filename.endswith(".sad"):
                    utt = os.path.basename(filename).split(".")[0]
                    
                    lines = open(os.path.join(sadroot,filename), 'r').readlines()
                    segment_id = 0
                    for line in lines:
                        #start, end, speech = line.split()
                        start, end = line.split()
                        segment_id_str = "{}_{}".format(utt, str(segment_id).zfill(4))
                        segments_str = "{} {} {} {}\n".format(segment_id_str, utt, start, end)
                        utt2spk_str = "{} {}\n".format(segment_id_str, utt)
                        segments_fi.write(segments_str)
                        utt2spk_fi.write(utt2spk_str)
                        segment_id += 1
 

                    #wav_str = "{} sox -c 1 -t wavpcm -s {}/{}.wav -r 16000 -t wavpcm - |\n".format(utt, flacpath, utt)

                    wav_str = "{} sox -t flac {}/{}.flac -t wav -r 16k "\
                           "-b 16 --channels 1 - |\n".format(utt, flacpath, utt) 

                    wavscp_fi.write(wav_str)

                    with open("{}/{}.rttm".format(rttmpath, utt), 'r') as fh:
                        rttm_str = fh.read()
                    rttm_fi.write(rttm_str)
                    with open("{}/{}.rttm".format(rttmpath, utt), 'r') as fh:
                        rttm_list = fh.readlines()
                    spk_list = map(lambda x: (x.split())[7], rttm_list) 
                    num_spk = len(set(spk_list))
                    reco2num_spk_fi.write("{} {}\n".format(utt, num_spk))




    wavscp_fi.close()
    utt2spk_fi.close()
    segments_fi.close()
    rttm_fi.close()
    reco2num_spk_fi.close()
    return 0




def prepare_dihard_2019_eval_track2(src_dir, data_dir):
    print('prepare_dihard_2019_eval_track2 CALLED')

    #print('heree')
    wavscp_fi = open(data_dir + "/wav.scp" , 'w')
    utt2spk_fi = open(data_dir + "/utt2spk" , 'w')
    segments_fi = open(data_dir + "/segments" , 'w')


    towalk = os.path.join(src_dir)

    for root, dirs, files in os.walk(towalk):
        flacpath = os.path.join(root,'flac') 
        rttmpath = os.path.join(root,'rttm')
        sadpath = os.path.join(root,'sad')
        sad_webrtcpath = os.path.join(root,'sad_webrtc')




        for sadroot, _ , labs in os.walk(sad_webrtcpath):

            for filename in labs: 
                if filename.endswith(".sad"):
                    utt = os.path.basename(filename).split(".")[0]
                    
                    lines = open(os.path.join(sadroot,filename), 'r').readlines()
                    segment_id = 0
                    for line in lines:
                        start, end = line.split()
                        segment_id_str = "{}_{}".format(utt, str(segment_id).zfill(4))
                        segments_str = "{} {} {} {}\n".format(segment_id_str, utt, start, end)
                        utt2spk_str = "{} {}\n".format(segment_id_str, utt)
                        segments_fi.write(segments_str)
                        utt2spk_fi.write(utt2spk_str)
                        segment_id += 1


                    #wav_str = "{} sox -c 1 -t wavpcm -s {}/{}.wav -r 16000 -t wavpcm - |\n".format(utt, flacpath, utt)
                    wav_str = "{} sox -t flac {}/{}.flac -t wav -r 16k "\
                           "-b 16 --channels 1 - |\n".format(utt, flacpath, utt) 

                    wavscp_fi.write(wav_str)






    wavscp_fi.close()
    utt2spk_fi.close()
    segments_fi.close()

    return 0

def main():
    src_dir = sys.argv[1]
    data_dir = sys.argv[2]
    track = sys.argv[3]
    devoreval = sys.argv[4]

    # print ('HEREE ',src_dir)

    # print(data_dir)

    # print( track)

    # print( devoreval == 'dev')
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)



    if int(track) == 1:
        #print('In track1')
        if devoreval == 'dev':
            prepare_dihard_2019_dev_track1(src_dir, data_dir)
        elif devoreval == 'eval':
            prepare_dihard_2019_eval_track1(src_dir, data_dir)

    elif int(track) == 2:
        #print('In track2')
        if devoreval == 'dev':
            prepare_dihard_2019_dev_track2(src_dir, data_dir)
        elif devoreval == 'eval':
            prepare_dihard_2019_eval_track2(src_dir, data_dir)       

    return 0

if __name__=="__main__":
    main()
