train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"
data=/Users/truongdinh/Documents/school_master_project/kaldi/egs/vivos/s5/data
vivos_root=/Users/truongdinh/Documents/school_master_project/kaldi/egs/vivos/s5/waves_vivos/vivos
data_url=https://ailab.hcmus.edu.vn/assets/vivos.tar.gz

steps/align_si.sh       
steps/align_si.sh --nj 24 --cmd "$train_cmd" data/train data/lang exp/tri1 exp/tri1_ali 