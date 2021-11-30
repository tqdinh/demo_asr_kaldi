. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

nj=1
mfccdir='mfcc_dinh'

steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" \
dinh_test exp/make_mfcc_dinh $mfccdir
steps/compute_cmvn_stats.sh dinh_test exp/make_mfcc_dinh $mfccdir
utils/fix_data_dir.sh dinh_test