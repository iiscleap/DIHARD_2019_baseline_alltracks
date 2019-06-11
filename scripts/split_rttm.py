#!/usr/bin/env python
"""Split RTTM into multiple files."""
from __future__ import print_function
from __future__ import unicode_literals
import argparse
from collections import namedtuple
import itertools
import os
import sys

PY2 = sys.version_info[0] == 2

if PY2:
    FileExistsError = OSError
else:
    from builtins import FileExistsError


Turn = namedtuple('Turn', ['type', 'fid', 'channel', 'onset', 'dur', 'ortho', 'speaker_type',
                           'speaker_id', 'score', 'slt'])

def make_dir(dirpath):
    """Create directory if it does not already exist."""
    try:
        os.makedirs(dirpath)
    except FileExistsError:
        pass


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


def groupby(iterable, keyfunc):
    """Wrapper around ``itertools.groupby`` which sorts data first."""
    iterable = sorted(iterable, key=keyfunc)
    for key, group in itertools.groupby(iterable, keyfunc):
        yield key, list(group)


def main():
    """Main."""
    parser = argparse.ArgumentParser(
        description='Split RTTM file into multiple RTTM files.', add_help=True)
    parser.add_argument(
        'src_rttm_fn', metavar='rttm', help='RTTM file to split')
    parser.add_argument(
        'output_dir', help='output directory for new RTTM files')
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    args = parser.parse_args()
    make_dir(args.output_dir)
    turns = load_rttm(args.src_rttm_fn)
    for fid, file_turns in groupby(
            turns, lambda x: x.fid):
        dest_rttm_fn = os.path.join(args.output_dir, fid + '.rttm')
        write_rttm(dest_rttm_fn, file_turns)


if __name__ == '__main__':
    main()
