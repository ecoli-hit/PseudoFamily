#!/bin/bash
ROOT=path/to/root
path_2_data=$ROOT/path/to/data-bin
FAIRSEQ=$ROOT/path/to/fairseq

#'fa' 'bn' 'hi' 
# for src in 'id' 'ms';do
path=/path/to/finetuned_model
CUDA=2,3
lan='en'
src='id'
lang_pairs=$src'-'$lan

cd $path
CUDA_VISIBLE_DEVICES=$CUDA fairseq-generate $path_2_data \
  --path $path/checkpoint_best.pt \
  --task translation_multi_simple_epoch \
  --gen-subset test \
  --source-lang $src \
  --target-lang $lan \
  --sacrebleu --remove-bpe 'sentencepiece'\
  --batch-size 32 \
  --encoder-langtok "src" \
  --decoder-langtok \
  --langs 'af,am,ar,ast,az,ba,be,bg,bn,br,bs,ca,ceb,cs,cy,da,de,el,en,es,et,fa,ff,fi,fr,fy,ga,gd,gl,gu,ha,he,hi,hr,ht,hu,hy,id,ig,ilo,is,it,ja,jv,ka,kk,km,kn,ko,lb,lg,ln,lo,lt,lv,mg,mk,ml,mn,mr,ms,my,ne,nl,no,ns,oc,or,pa,pl,ps,pt,ro,ru,sd,si,sk,sl,so,sq,sr,ss,su,sv,sw,ta,th,tl,tn,tr,uk,ur,uz,vi,wo,xh,yi,yo,zh,zu' \
  --lang-pairs "$lang_pairs" --num-workers 64 > gen_out_$src

cat gen_out_$src | grep -P "^H" |sort -V |cut -f 3- | sh ${FAIRSEQ}/examples/m2m_100/tok.sh $lan > hyp_$src
cat gen_out_$src | grep -P "^T" |sort -V |cut -f 2- | sh ${FAIRSEQ}/examples/m2m_100/tok.sh $lan > ref_$src
cat gen_out_$src | grep -P "^S" |sort -V |cut -f 2- | sed 's/__'$src'__//g' |sh ${FAIRSEQ}/examples/m2m_100/tok.sh $lan > src_$src
sacrebleu -tok 'none' -s 'none' ref_$src < hyp_$src > score_$src
# comet-score -s src_$src -t hyp_$src -r ref_$src  --quiet > comet_$src
# done