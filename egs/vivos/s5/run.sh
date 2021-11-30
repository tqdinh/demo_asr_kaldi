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

# download data (if necessary)
if [ $stage -le 0 ]; then
    wget $data_url || exit 1;
    mkdir $vivos_root
    tar -xvzf vivos.tar.gz -C waves_vivos || exit 1;
fi

# data prep
if [ $stage -le 1 ]; then
    mkdir -p data/{train,test} exp

    if [ ! -f $vivos_root/README ]; then
        echo Cannot find VIVOS root! $vivos_root Exiting...
        exit 1
    fi
    python local/data_prep.py $vivos_root  

    utils/fix_data_dir.sh data/train
    utils/fix_data_dir.sh data/test
fi

# MFCC feature extraction
if [ $stage -le 2 ]; then
    mfccdir='mfcc'
    for x in test train; do
        steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" \
            data/$x exp/make_mfcc/$x $mfccdir
        steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
        utils/fix_data_dir.sh data/$x
    done
fi

# lang prep
if [ $stage -le 3 ]; then
    rm -rf data/local/{dict,,lm}
    mkdir -p data/local/{dict,lang,lm}

    python3 local/lang_prep.py $vivos_root 
    echo '<UNK> SIL' >> data/local/dict/lexicon.txt
    echo 'SIL' > data/local/dict/silence_phones.txt
    echo 'SIL' > data/local/dict/optional_silence.txt
    echo -n > data/local/dict/extra_questions.txt

    utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
    ngram-count -text data/local/lm/all_text.txt -order 2 -lm data/local/lm/bigram.arpa
    arpa2fst data/local/lm/bigram.arpa | fstprint | \
        grep -v '4\|:' | \
        utils/remove_oovs.pl data/lang/oov.txt | utils/eps2disambig.pl | utils/s2eps.pl | \
        /Users/truongdinh/Documents/school_master_project/kaldi/tools/openfst-1.7.2/bin/fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | \
        fstarcsort > data/lang/G.fst
fi


# train monophone system 
if [ $stage -le 4 ]; then
    steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono
    
fi

if [ $stage -le 5 ]; then
    utils/mkgraph.sh data/lang exp/mono exp/mono/graph
    steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
        exp/mono/graph data/test exp/mono/decode
fi


# align mono
if [ $stage -le 6 ]; then
    steps/align_si.sh --nj $nj --cmd "$train_cmd" \
        data/train data/lang exp/mono exp/mono_ali
fi

if [ $stage -le 7 ]; then
    for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
fi
