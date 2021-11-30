. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
nj=1
mfccdir='mfcc_demo'
graph_output="exp/mono/graph_demo"
data_to_decode="voice"
decode_result="exp/mono/decode_demo"
mfcc_log="exp/make_mfcc_dinh"

steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" $data_to_decode $mfcc_log $mfccdir
steps/compute_cmvn_stats.sh $data_to_decode $mfcc_log $mfccdir
utils/fix_data_dir.sh $data_to_decode


utils/mkgraph.sh data/lang exp/mono $graph_output
steps/decode.sh  --skip-scoring true --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
$graph_output $data_to_decode $decode_result
