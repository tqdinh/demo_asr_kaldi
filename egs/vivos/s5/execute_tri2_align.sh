. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
model="tri2_ali"
nj=1
mfccdir=mfcc_$model
graph_output=exp/$model/graph_demo
data_to_decode=voice
decode_result=exp/$model/decode_demo
mfcc_log=exp/make_mfcc_demo


rf -rf mfccdir
rm -rf mfcc_log
rm -rf decode_result
rm -rf graph_output

steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" $data_to_decode $mfcc_log $mfccdir
steps/compute_cmvn_stats.sh $data_to_decode $mfcc_log $mfccdir
utils/fix_data_dir.sh $data_to_decode


utils/mkgraph.sh data/lang exp/$model $graph_output
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
$graph_output $data_to_decode $decode_result
