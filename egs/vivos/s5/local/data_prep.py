#!/usr/bin/env python

from __future__ import print_function
import os
import re
import sys

if len(sys.argv) != 2:
    print ('Usage: python data_prep.py [vivos_root]')
    sys.exit(1)
vivos_root = sys.argv[1]

# text
with open(vivos_root+"/train/prompts.txt") as fp:
    train_text = fp.readlines()
with open(vivos_root+"/test/prompts.txt") as fp:
    test_text = fp.readlines()

# train set: utt2spk, wavscp
utt2spk = open("data/train/utt2spk","wt")
wavscp = open("data/train/wav.scp","wt")
wavdir = vivos_root + "/train/waves/"
text = open("data/train/text","wt")
for line in train_text:
    toks = line.split()
    if len(toks)> 1:
        toks_name = toks[0].split('_')
        wavfn = wavdir + toks_name[0]+"/"+toks[0]+".wav"
        if os.path.isfile(wavfn):
            utt2spk.writelines([toks[0]," ",toks_name[0],"\n"])
            wavscp.writelines([toks[0]," ",wavfn,"\n"])
            text.writelines([line])
        else:
            print("not found "+wavfn)

utt2spk.close()
wavscp.close()
text.close()

# test set: utt2spk, wavscp
utt2spk = open("data/test/utt2spk","wt")
wavscp = open("data/test/wav.scp","wt")
wavdir = vivos_root + "/test/waves/"
text = open("data/test/text","wt")
for line in test_text:
    toks = line.split()
    if len(toks)> 1:
        toks_name = toks[0].split('_')
        wavfn = wavdir + toks_name[0]+"/"+toks[0]+".wav"
        if os.path.isfile(wavfn):
            utt2spk.writelines([toks[0]," ",toks_name[0],"\n"])
            wavscp.writelines([toks[0]," ",wavfn,"\n"])
            text.writelines([line])
        else:
            print("not found "+wavfn)
utt2spk.close()
wavscp.close()
text.close()
