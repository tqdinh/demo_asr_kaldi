. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
nj=1

utils/mkgraph.sh data/lang exp/tri3 exp/tri3/graph
steps/decode.sh  --skip-scoring true --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
exp/tri3/graph data/test exp/tri3/decode

./local/score.sh data/test exp/tri3/graph exp/tri3/decode