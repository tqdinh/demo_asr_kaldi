#!/usr/bin/env python3

from __future__ import print_function
import os
import re
import sys
from epitran.backoff import Backoff

if len(sys.argv) != 2:
    print ('Usage: python data_prep.py [vivos_root]')
    sys.exit(1)
vivos_root = sys.argv[1]

# text
with open(vivos_root+"/train/prompts.txt", encoding="utf8") as fp:
    train_text = fp.readlines()
with open(vivos_root+"/test/prompts.txt", encoding="utf8") as fp:
    test_text = fp.readlines()


all_text = train_text + test_text

texts = ""

lm_f = open(os.path.join('data', 'local', 'lm', 'all_text.txt'), 'w', encoding="utf8")

for line in all_text:
    toks = line.split()
    if len(toks)>1:
        texts += " " + " ".join(toks[1:])
        lm_f.write(" ".join(toks[1:]) + "\n")

lm_f.close()

words = sorted(set(texts.split()))
epi = Backoff(['vie-Latn','eng-Latn'])

# lexicon
all_phones = []
with open(os.path.join('data', 'local', 'dict', 'lexicon.txt'), 'w', encoding="utf8") as lexicon_f:
    for word in words:
        if word.isalpha():
            phones = epi.trans_list(word)
            all_phones += phones
            lexicon_f.writelines([word," "," ".join(phones),"\n"])

all_phones = sorted(set(all_phones))
with open(os.path.join('data', 'local', 'dict', 'nonsilence_phones.txt'), 'w', encoding="utf8") as nonsilence_phones_f:
    nonsilence_phones_f.writelines("\n".join(all_phones) + "\n")

