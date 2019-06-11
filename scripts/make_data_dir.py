#!/usr/bin/env python3
"""TODO."""
from __future__ import print_function
from __future__ import unicode_literals
import argparse
from collections import defaultdict, namedtuple
import glob
import itertools
import os
import sys


Segment = namedtuple('Segment', ['id', 'onset', 'offset', 'label'])
Turn = namedtuple(
    'Turn', ['type', 'fid', 'channel', 'onset', 'dur', 'ortho', 'speaker_type',
             'speaker_id', 'score', 'slt'])

def read_label_file(fn):
    """Load segments from label file ``fn``."""
    utt = get_utt(fn)
    with open(fn, 'rb') as f:
        segs = []
        for n, line in enumerate(f):
            onset, offset, label = line.decode('utf-8').strip().split()
            segment_id = '{}_{}'.format(
                utt, str(n).zfill(4))
            segs.append(Segment(segment_id, onset, offset, label))
    return segs


def load_rttm(fn):
    """Load turns from RTTM file."""
    with open(fn, 'rb') as f:
        turns = []
        for line in f:
            fields = line.decode('utf-8').strip().split()
            turns.append(Turn(*fields))
    return turns


def write_rttm(fn, turns):
    """Write turns to RTTM file."""
    with open(fn, 'wb') as f:
        turns = sorted(
            turns, key=lambda x: (x.fid, float(x.onset), float(x.dur)))
        for turn in turns:
            line = ' '.join(turn)
            f.write(line.encode('utf-8'))
            f.write(b'\n')


def write_wav_scpf(fn, utts, audio_dir, audio_ext='.flac'):
    """Write script file containing WAV data for speech segments.

    Parameters
    ----------
    fn : str
        Path to output script file.

    utts : list of str
        List of unique identifiers.

    audio_dir : str
        Path to directory containing audio files.

    audio_ext : str, optional
        Audio file extension.
        (Default: '.flac')
    """
    with open(fn, 'wb') as f:
        for utt in sorted(utts):
            if audio_ext == '.flac':
                wav_str = ('{} sox -t flac {}/{}.flac -t wav -r 16k '
                           '-b 16 --channels 1 - |\n'.format(utt, audio_dir, utt))
            elif audio_ext == '.wav':
                wav_str = ('{} sox -t wav {}/{}.wav -t wav -r 16k '
                           '-b 16 --channels 1 - |\n'.format(utt, audio_dir, utt))
            f.write(wav_str.encode('utf-8'))


def write_utt2spk(fn, utt_to_segs):
    """Write ``utt2spk`` file."""
    with open(fn, 'wb') as f:
        for utt in sorted(utt_to_segs):
            segs = sorted(
                utt_to_segs[utt], key=lambda x: x.id)
            for seg in segs:
                line = '{} {}\n'.format(seg.id, utt)
                f.write(line.encode('utf-8'))


def write_segments_file(fn, utt_to_segs):
    """Write ``segments`` file."""
    with open(fn, 'wb') as f:
        for utt in sorted(utt_to_segs):
            segs = sorted(
                utt_to_segs[utt], key=lambda x:	x.id)
            for seg in segs:
                line = '{} {} {} {}\n'.format(
                    seg.id, utt, seg.onset, seg.offset)
                f.write(line.encode('utf-8'))


def get_utt(fn):
    """Get utt corresponding to filename."""
    return os.path.splitext(os.path.basename(fn))[0]


def write_rec2num_spk(fn, utt_to_turns):
    """Write ``rec2num_spk``."""
    utt_to_speakers = defaultdict(set)
    for utt, turns in utt_to_turns.items():
        for turn in turns:
            utt_to_speakers[utt].add(turn.speaker_id)
    with open(fn, 'wb') as f:
        for utt in sorted(utt_to_speakers):
            n_speakers = len(utt_to_speakers[utt])
            line = '{} {}\n'.format(utt, n_speakers)
            f.write(line.encode('utf-8'))


def prepare_data_dir(data_dir, sad_dir, audio_dir, rttm_dir=None,
                     audio_ext='.flac', sad_ext='.lab', rttm_ext='.rttm'):
    """Prepare data directory.

    This function will create the following files in ``data_dir``:

    - wav.scp  --  script mapping audio to WAV data suitable for feature
      extraction
    - utt2spk  --  mapping from audio files to segment ids
    - segments  --  listing of **ALL** speech segments in source recordings
      according to segmentations from label files under ``sad_dir``
    - rttm  --  combined RTTM file created from contents of RTTM files under
      ``rttm_dir``; not written if ``rttm_dir`` is None
    - reco2num_spk  --  mapping from audio files to number of reference
      speakers present; not written if ``rttm_dir`` is None

    Parameters
    ----------
    data_dir : str
        Path to output directory.

    sad_dir : str
        Path to directory containing SAD label files. Assumes all files have
        extension ``.lab``.

    audio_dir : str
        Path to directory containing audio files.

    rttm_dir : str, optional
        Path to directory containing RTTM files.
        (Default: None)

    audio_ext : str, optional
        Audio file extension. Must be one of {'.wav', '.flac'}.
        (Default: '.flac')

    sad_ext : str, optional
        SAD file extension.
        (Default: '.lab')

    rttm_ext : str, optional
        RTTM file extension.
        (Default: '.rttm')
    """
    # Load speech segments from label files and write WAV data script file,
    # utt2spk, and combined segments files.
    utt_to_segs = {}
    for filename in glob.glob(os.path.join(sad_dir, '*' + sad_ext)):
        segs = read_label_file(filename)
        utt_to_segs[get_utt(filename)] = segs
    write_wav_scpf(
        os.path.join(data_dir, 'wav.scp'),
        utt_to_segs.keys(), audio_dir, audio_ext)
    write_utt2spk(
        os.path.join(data_dir, 'utt2spk'), utt_to_segs)
    write_segments_file(
        os.path.join(data_dir, 'segments'), utt_to_segs)

    # If reference RTTMs are present, write the combined RTTM
    # and reference num speakers files.
    if rttm_dir is not None:
        utt_to_turns = {}
        for filename in glob.glob(os.path.join(rttm_dir, '*' + rttm_ext)):
            turns = load_rttm(filename)
            utt_to_turns[get_utt(filename)] = turns
        combined_turns = list(itertools.chain.from_iterable(
            utt_to_turns.values()))
        write_rttm(
            os.path.join(data_dir, 'rttm'), combined_turns)
        write_rec2num_spk(
            os.path.join(data_dir, 'reco2num_spk'), utt_to_turns)


def main():
    """Main."""
    parser = argparse.ArgumentParser(
        description='Prepare data directory for KALDI experiments.',
        add_help=True)
    parser.add_argument(
        'data_dir', nargs=None, help='output data directory')
    parser.add_argument(
        'audio_dir', nargs=None, help='source audio directory')
    parser.add_argument(
        'sad_dir', nargs=None, help='source SAD directory')
    parser.add_argument(
        '--rttm_dir', nargs=None, default=None, metavar='STR',
        help='source RTTM directory')
    parser.add_argument(
        '--audio_ext', nargs=None, default='.flac', metavar='STR',
        choices=['.flac', '.wav'],
        help='audio file extension (default: %(default)s)')
    parser.add_argument(
        '--sad_ext', nargs=None, default='.lab', metavar='STR',
        help='SAD file extension (default: %(default)s)')
    parser.add_argument(
        '--rttm_ext', nargs=None, default='.rttm', metavar='STR',
        help='RTTM file extension (default: %(default)s)')
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    args = parser.parse_args()

    if not os.path.exists(args.data_dir):
        os.makedirs(args.data_dir)

    prepare_data_dir(
        args.data_dir, args.sad_dir, args.audio_dir, args.rttm_dir,
        args.audio_ext, args.sad_ext, args.rttm_ext)



if __name__ == '__main__':
    main()
