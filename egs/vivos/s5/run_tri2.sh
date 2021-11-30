. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

stage=1
nj=20

steps/train_lda_mllt.sh --cmd "$train_cmd" \
1800 9000 data/train data/lang exp/tri1_ali exp/tri2
utils/mkgraph.sh data/lang exp/tri2 exp/tri2/graph
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
exp/tri2/graph data/test exp/tri2/decode

# steps/align_si.sh --nj $nj --cmd "$train_cmd" \
#         data/train data/lang exp/tri2 exp/tri2_ali