. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
nj=1

utils/mkgraph.sh data/lang exp/tri2 exp/tri2/graph
steps/decode.sh  --skip-scoring true --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
exp/tri2/graph data/test exp/tri2/decode

./local/score.sh data/test exp/tri2/graph exp/tri2/decode