import sys, os

def prepare_dihard_2019_dev(src_dir, data_dir, tracknum):

    print('Preparing dev dataset for track {}'.format(tracknum))

    wavscp_fi = open(data_dir + "/wav.scp" , 'w')
    utt2spk_fi = open(data_dir + "/utt2spk" , 'w')
    segments_fi = open(data_dir + "/segments" , 'w')
    rttm_fi = open(data_dir + "/rttm" , 'w')
    reco2num_spk_fi = open(data_dir + "/reco2num_spk" , 'w')

    towalk = os.path.join(src_dir)

    for root, dirs, files in os.walk(towalk):
        if int(track) == 3:
            flacpath = os.path.join(root,'wav') 
        else:
            flacpath = os.path.join(root,'flac') 

        rttmpath = os.path.join(root,'rttm')

        if int(track) == 1 or int(track) == 3:
            sadpath = os.path.join(root,'sad')
        elif int(track) == 2:
            sadpath = os.path.join(root,'sad_webrtc')
        elif track == "2_den":
            sadpath = os.path.join(root,'den_sad_webrtc_dev')

        for sadroot, _ , labs in os.walk(sadpath):

            for filename in labs: 
                if int(track) == 1 or int(track) == 3:
                    endswithtext=".lab"
                elif int(track) == 2 or track=="2_den":
                    endswithtext=".sad"

                if filename.endswith(endswithtext):
                #if filename.endswith(".sad"):
                    utt = os.path.basename(filename).split(".")[0]
                    
                    lines = open(os.path.join(sadroot,filename), 'r').readlines()
                    segment_id = 0
                    for line in lines:

                        if int(track) == 1 or int(track) == 3:
                            start, end, speech = line.split()
                        elif int(track) == 2 or track=="2_den":
                            start, end = line.split()

                        segment_id_str = "{}_{}".format(utt, str(segment_id).zfill(4))
                        segments_str = "{} {} {} {}\n".format(segment_id_str, utt, start, end)
                        utt2spk_str = "{} {}\n".format(segment_id_str, utt)
                        segments_fi.write(segments_str)
                        utt2spk_fi.write(utt2spk_str)
                        segment_id += 1

                    if int(track) == 3:
                        wav_str = "{} sox -c 1 -t wavpcm -s {}/{}.wav -r 16000 -t wavpcm - |\n".format(utt, flacpath, utt)

                    else:
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


def prepare_dihard_2019_eval(src_dir, data_dir, tracknum):

    print('Preparing eval dataset for track {}'.format(tracknum))

    wavscp_fi = open(data_dir + "/wav.scp" , 'w')
    utt2spk_fi = open(data_dir + "/utt2spk" , 'w')
    segments_fi = open(data_dir + "/segments" , 'w')


    towalk = os.path.join(src_dir)

    for root, dirs, files in os.walk(towalk):

        if int(track) == 3:
            flacpath = os.path.join(root,'wav') 
        else:
            flacpath = os.path.join(root,'flac') 

        rttmpath = os.path.join(root,'rttm')

        if int(track) == 1 or int(track) == 3:
            sadpath = os.path.join(root,'sad')
        elif int(track) == 2:
            sadpath = os.path.join(root,'sad_webrtc')
        elif track == "2_den":
            sadpath = os.path.join(root,'den_sad_webrtc_eval')

        for sadroot, _ , labs in os.walk(sadpath):

            for filename in labs: 
                if int(track) == 1 or int(track) == 3:
                    endswithtext=".lab"
                elif int(track) == 2 or track=="2_den":
                    endswithtext=".sad"


                if filename.endswith(endswithtext):
                #if filename.endswith(".sad"):
                    utt = os.path.basename(filename).split(".")[0]
                    
                    lines = open(os.path.join(sadroot,filename), 'r').readlines()
                    segment_id = 0
                    for line in lines:


                        if int(track) == 1 or int(track) == 3:
                            start, end, speech = line.split()
                        elif int(track) == 2 or track=="2_den":
                            start, end = line.split()

                        segment_id_str = "{}_{}".format(utt, str(segment_id).zfill(4))
                        segments_str = "{} {} {} {}\n".format(segment_id_str, utt, start, end)
                        utt2spk_str = "{} {}\n".format(segment_id_str, utt)
                        segments_fi.write(segments_str)
                        utt2spk_fi.write(utt2spk_str)
                        segment_id += 1

                    if int(track) == 3:
                        wav_str = "{} sox -c 1 -t wavpcm -s {}/{}.wav -r 16000 -t wavpcm - |\n".format(utt, flacpath, utt)

                    else:            
                        wav_str = "{} sox -t flac {}/{}.flac -t wav -r 16k "\
                               "-b 16 --channels 1 - |\n".format(utt, flacpath, utt) 

                    wavscp_fi.write(wav_str)

    wavscp_fi.close()
    utt2spk_fi.close()
    segments_fi.close()

    return 0



#################################

def main():
    src_dir = sys.argv[1]
    data_dir = sys.argv[2]
    track = sys.argv[3]
    devoreval = sys.argv[4]

    if not os.path.exists(data_dir):
        os.makedirs(data_dir)

    if devoreval == "dev":
        prepare_dihard_2019_dev(src_dir, data_dir,track)

    elif devoreval == "eval":
        prepare_dihard_2019_eval(src_dir, data_dir,track)     

    return 0




if __name__ == "__main__":
    main()
