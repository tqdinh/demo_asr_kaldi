. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
nj=1

utils/mkgraph.sh data/lang exp/tri3 exp/tri3/graph_dinh
steps/decode.sh  --skip-scoring true --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
exp/tri3/graph_dinh dinh_test exp/tri3/decode_dinh
