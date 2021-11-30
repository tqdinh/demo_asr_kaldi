#!/usr/bin/env bash
. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

stage=1
nj=6
data=/Users/truongdinh/Documents/school_master_project/kaldi/egs/vivos/s5/data
vivos_root=/Users/truongdinh/Documents/school_master_project/kaldi/egs/vivos/s5/waves_vivos/vivos
data_url=https://ailab.hcmus.edu.vn/assets/vivos.tar.gz

train_vivos=train
test_vivos=test

# train monophone system 
if [ $stage -le 4 ]; then
    steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/test data/lang exp/mono
    
fi

if [ $stage -le 5 ]; then
    utils/mkgraph.sh data/lang exp/mono exp/mono/graph
    steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
        exp/mono/graph data/test exp/mono/decode
fi


# align mono
if [ $stage -le 6 ]; then
    steps/align_si.sh --nj $nj --cmd "$train_cmd" \
        data/train data/lang exp/mono exp/mono_ali
fi

if [ $stage -le 7 ]; then
    for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
fi
