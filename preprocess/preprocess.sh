#!bin/bash
ROOT=./
FAIRSEQ=$ROOT/fairseq
DATABIN=$ROOT/databin
RAW=$ROOT/ted/data
HISTO=$ROOT/m2m_model/checkpoint/edunov/cc60_multilingual/clean_hists
M2M=$ROOT/m2m_mode
SPM=$ROOT/m2m_model/spm.128k.model
MOSS=$ROOT/mosesdecoder

#  'ar' 'de' 'el' 'bg' 'cs' 'es' 'fr' 'zh' 'ko' 'ru' 'tr' 'it' 'ja' 'he' 'pt' 'ro' 'vi' 'nl' 'hu' 'fa' 'pl' 'sr' 'uk' 'hr' 'id' 'th' 'sv' 'sk'
tgt="en"
for src in 'zh';do

# if [ ! -d $RAW"/"$src"-"$tgt/  ];then
#   mkdir -p $RAW"/"$src"-"$tgt/

# cd $RAW"/"$src"-"$tgt/
# puntuaction clean

# mkdir -p $RAW"/"$src"_"$tgt/
# train
$ROOT/preprocess/normalize-punctuation.perl $src  < "train."$src >  $RAW"/"$src"_"$tgt/"training.punc."$src
$ROOT/preprocess/normalize-punctuation.perl $tgt  < "train."$tgt >  $RAW"/"$src"_"$tgt/"training.punc."$tgt
 valid 
$ROOT/preprocess/normalize-punctuation.perl $src  < "dev."$src >    $RAW"/"$src"_"$tgt/"valid.punc."$src
$ROOT/preprocess/normalize-punctuation.perl $tgt  < "dev."$tgt >    $RAW"/"$src"_"$tgt/"valid.punc."$tgt
 test"_"
$ROOT/preprocess/normalize-punctuation.perl $src  < "test."$src  >  $RAW"/"$src"_"$tgt/"test.punc."$src
$ROOT/preprocess/normalize-punctuation.perl $tgt  < "test."$tgt  >  $RAW"/"$src"_"$tgt/"test.punc."$tgt


# #preprocess data
# cd $RAW"/"$src"_"$tgt/
# # remove sentences with more than 50% punctuation
python $ROOT/script/preprocess/remove_too_much_punc.py --srcfile $RAW"/"$src"_"$tgt/"training.punc."$src --tgtfile $RAW"/"$src"_"$tgt/"training.punc."$tgt \
--bitext $src"-"$tgt --src-lang $src --tgt-lang $tgt --type train

python $ROOT/script/preprocess/remove_too_much_punc.py --srcfile $RAW"/"$src"_"$tgt/"valid.punc."$src    --tgtfile $RAW"/"$src"_"$tgt/"valid.punc."$tgt \
--bitext $src"-"$tgt --src-lang $src --tgt-lang $tgt --type valid

python $ROOT/script/preprocess/remove_too_much_punc.py --srcfile $RAW"/"$src"_"$tgt/"test.punc."$src     --tgtfile $RAW"/"$src"_"$tgt/"test.punc."$tgt \
--bitext $src"-"$tgt --src-lang $src --tgt-lang $tgt --type test

# # deduplicate training data
paste $RAW"/"$src"_"$tgt/"train.depunc."$src  $RAW"/"$src"_"$tgt/"train.depunc."$tgt | awk '!x[$0]++' > $RAW"/"$src"_"$tgt/train.dedup
# echo "keeping $(wc -l ./train.dedup) bitext out of $(wc -l ./"train.depunc."$src)"
cut -f1 $RAW"/"$src"_"$tgt//train.dedup > $RAW"/"$src"_"$tgt//train.dedup.$src
cut -f2 $RAW"/"$src"_"$tgt//train.dedup > $RAW"/"$src"_"$tgt//train.dedup.$tgt

# # remove all instances of evaluation data from the training data
python $ROOT/script/preprocess/dedup_data.py --train $RAW"/"$src"_"$tgt/train.dedup. --evalue $RAW"/"$src"_"$tgt/valid.depunc. --srclan $src --tgtlan $tgt  --output $RAW"/"$src"_"$tgt/train.redup.

# # frequency cleaning

python $FAIRSEQ/examples/m2m_100/process_data/clean_histogram.py --src $src --tgt $tgt \
--src-file $RAW"/"$src"_"$tgt/train.redup.$src --tgt-file $RAW"/"$src"_"$tgt/train.redup.$tgt \
--src-output-file $RAW"/"$src"_"$tgt/train.freq.$src --tgt-output-file $RAW"/"$src"_"$tgt/train.freq.$tgt --histograms $HISTO

python $FAIRSEQ/examples/m2m_100/process_data/clean_histogram.py --src $src --tgt $tgt \
--src-file $RAW"/"$src"_"$tgt/valid.depunc.$src --tgt-file $RAW"/"$src"_"$tgt/valid.depunc.$tgt \
--src-output-file $RAW"/"$src"_"$tgt/valid.freq.$src --tgt-output-file $RAW"/"$src"_"$tgt/valid.freq.$tgt --histograms $HISTO

python $FAIRSEQ/examples/m2m_100/process_data/clean_histogram.py --src $src --tgt $tgt \
--src-file $RAW"/"$src"_"$tgt/test.depunc.$src --tgt-file $RAW"/"$src"_"$tgt/test.depunc.$tgt \
--src-output-file $RAW"/"$src"_"$tgt/test.freq.$src --tgt-output-file $RAW"/"$src"_"$tgt/test.freq.$tgt --histograms $HISTO

# # apply SPM

python $FAIRSEQ/scripts/spm_encode.py \
    --model $SPM \
    --output_format=piece \
    --inputs=$RAW"/"$src"_"$tgt/train.freq.$src \
    --outputs=$RAW"/"$src"_"$tgt/train.spm.$src

python $FAIRSEQ/scripts/spm_encode.py \
    --model $SPM \
    --output_format=piece \
    --inputs=$RAW"/"$src"_"$tgt/train.freq.$tgt \
    --outputs=$RAW"/"$src"_"$tgt/train.spm.$tgt

python $FAIRSEQ/scripts/spm_encode.py \
    --model $SPM \
    --output_format=piece \
    --inputs=$RAW"/"$src"_"$tgt/valid.freq.$src \
    --outputs=$RAW"/"$src"_"$tgt/valid.spm.$src

python $FAIRSEQ/scripts/spm_encode.py \
    --model $SPM \
    --output_format=piece \
    --inputs=$RAW"/"$src"_"$tgt/valid.freq.$tgt \
    --outputs=$RAW"/"$src"_"$tgt/valid.spm.$tgt

python $FAIRSEQ/scripts/spm_encode.py \
    --model $SPM \
    --output_format=piece \
    --inputs=$RAW"/"$src"_"$tgt/test.freq.$src \
    --outputs=$RAW"/"$src"_"$tgt/test.spm.$src

python $FAIRSEQ/scripts/spm_encode.py \
    --model $SPM \
    --output_format=piece \
    --inputs=$RAW"/"$src"_"$tgt/test.freq.$tgt \
    --outputs=$RAW"/"$src"_"$tgt/test.spm.$tgt

mkdir -p $RAW"/"$src"_"$tgt/cleanout
# # length ratio cleaning
perl $MOSS/scripts/training/clean-corpus-n.perl --ratio 3 $RAW"/"$src"_"$tgt/train.spm $src $tgt $RAW"/"$src"_"$tgt/cleanout/train.spm 1 250
perl $MOSS/scripts/training/clean-corpus-n.perl --ratio 3 $RAW"/"$src"_"$tgt/valid.spm $src $tgt $RAW"/"$src"_"$tgt/cleanout/valid.spm 1 250
perl $MOSS/scripts/training/clean-corpus-n.perl --ratio 3 $RAW"/"$src"_"$tgt/test.spm $src $tgt  $RAW"/"$src"_"$tgt/cleanout/test.spm 1 250

# binarize data
if [ ! -d $DATABIN  ];then
  mkdir -p $DATABIN

CUDA_VISIBLE_DEVICES=2,3 fairseq-preprocess --source-lang $src --target-lang $tgt \
    --trainpref $RAW"/"$src"_"$tgt/cleanout/train.spm \
    --validpref $RAW"/"$src"_"$tgt/cleanout/valid.spm \
    --testpref  $RAW"/"$src"_"$tgt/cleanout/test.spm \
    --destdir $DATABIN/$src"_"$tgt \
    --workers 20 \
    --srcdict $M2M/model_dict.128k.txt --tgtdict $M2M/model_dict.128k.txt 

done