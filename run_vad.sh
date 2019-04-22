	
#!/bin/bash


output_dir=$1



python main_get_vad.py --wav_dir $output_dir --mode 3 --hoplength 30 || exit 1

exit 0
