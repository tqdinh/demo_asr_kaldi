. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

stage=1
nj=20

steps/train_sat.sh 1800 9000 data/train data/lang exp/tri2_ali exp/tri3