#!/usr/bin/env bash
. ./path.sh
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

stage=1
nj=6
data=/Users/truongdinh/Documents/school_master_project/kaldi/egs/vivos/s5/data
vivos_root=/Users/truongdinh/Documents/school_master_project/kaldi/egs/vivos/s5/waves_vivos/vivos
data_url=https://ailab.hcmus.edu.vn/assets/vivos.tar.gz

train_vivos=train
test_vivos=test



# MFCC feature extraction
if [ $stage -le 1 ]; then
    mfccdir='mfcc'
    for x in test train; do
        steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" \
            data/$x exp/make_mfcc/$x $mfccdir
        steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
        utils/fix_data_dir.sh data/$x
    done
fi

# lang prep
if [ $stage -le 2 ]; then
    rm -rf data/local/{dict,,lm}
    mkdir -p data/local/{dict,lang,lm}

    python3 local/lang_prep.py $vivos_root 
    echo '<UNK> SIL' >> data/local/dict/lexicon.txt
    echo 'SIL' > data/local/dict/silence_phones.txt
    echo 'SIL' > data/local/dict/optional_silence.txt
    echo -n > data/local/dict/extra_questions.txt

    utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
    /Users/truongdinh/Documents/school_master_project/kaldi/tools/srilm/lm/bin/macosx/ngram-count -text data/local/lm/all_text.txt -order 2 -lm data/local/lm/bigram.arpa
    /Users/truongdinh/Documents/school_master_project/kaldi/src/lmbin/arpa2fst data/local/lm/bigram.arpa | /Users/truongdinh/Documents/school_master_project/kaldi/tools/openfst-1.7.2/bin/fstprint | \
        grep -v '4\|:' | \
        utils/remove_oovs.pl data/lang/oov.txt | utils/eps2disambig.pl | utils/s2eps.pl | \
        /Users/truongdinh/Documents/school_master_project/kaldi/tools/openfst-1.7.2/bin/fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | \
        /Users/truongdinh/Documents/school_master_project/kaldi/tools/openfst-1.7.2/bin/fstarcsort > data/lang/G.fst
fi





# train tri1 (first triphone pass) and decode

# train tri1 (first triphone pass) and decode
if [ $stage -le 3 ]; then
    steps/train_deltas.sh --cmd "$train_cmd" \
        1800 9000 data/train data/lang exp/mono_ali exp/tri1
    utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
    steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
        exp/tri1/graph data/test exp/tri1/decode
fi

# align tri1 
if [ $stage -le 4 ]; then
    steps/align_si.sh --nj $nj --cmd "$train_cmd" \
        data/train data/lang exp/tri1 exp/tri1_ali
fi

if [ $stage -le 5 ]; then
    for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
fi

