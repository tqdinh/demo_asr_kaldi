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

steps/train_deltas.sh  --cmd "$train_cmd" \
2000 10000 data/train data/lang exp/mono_ali exp/tri1 

utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
        exp/tri1/graph data/test exp/tri1/decode