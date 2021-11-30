. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
nj=1


utils/mkgraph.sh data/lang exp/mono exp/mono/graph_dinh
steps/decode.sh  --skip-scoring true --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
exp/mono/graph_dinh dinh_test exp/mono/decode_dinh
