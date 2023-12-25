#!/bin/bash
#SBATCH -o job.%j.out
#SBATCH -J generate
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --gres=gpu:2

# source ~/.bashrc
tgt='en'
# for src in 'be';do
for src in 'fa' 'hi' 'bn' 'id' 'ms' 'ko' 'bg' 'sr' 'hr' 'uk' 'sk' 'be' 'kk' 'tr' 'de' 'sv' 'ja';do
# for src in 'uk';do

lang_pairs=$src'-'$tgt
ROOT=./
path_2_data=$ROOT/data-bin
lang_list=$ROOT/m2m_model/language_pairs.txt
# pretrained_model=$ROOT/m2m_model/1.2B_last_checkpoint.pt
pretrained_model=$ROOT/m2m_model/418M_last_checkpoint.pt

OUTPUT=./FIM/$lang_pairs
mkdir -p $OUTPUT
cp $0 $OUTPUT

CUDA_VISIBLE_DEVICES=0,1 fairseq-train $path_2_data --finetune-from-model $pretrained_model --save-dir $OUTPUT --task translation_multi_simple_epoch --encoder-normalize-before \
--langs 'af,am,ar,ast,az,ba,be,bg,bn,br,bs,ca,ceb,cs,cy,da,de,el,en,es,et,fa,ff,fi,fr,fy,ga,gd,gl,gu,ha,he,hi,hr,ht,hu,hy,id,ig,ilo,is,it,ja,jv,ka,kk,km,kn,ko,lb,lg,ln,lo,lt,lv,mg,mk,ml,mn,mr,ms,my,ne,nl,no,ns,oc,or,pa,pl,ps,pt,ro,ru,sd,si,sk,sl,so,sq,sr,ss,su,sv,sw,ta,th,tl,tn,tr,uk,ur,uz,vi,wo,xh,yi,yo,zh,zu' \
--lang-pairs $src-$tgt --max-tokens 4800 --decoder-normalize-before --sampling-method temperature --sampling-temperature 1.5 \
--encoder-langtok src --decoder-langtok --criterion label_smoothed_cross_entropy --label-smoothing 0.2 --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
--lr-scheduler inverse_sqrt --lr 3e-05 --warmup-updates 2500 --max-update 400000 --dropout 0.3 --attention-dropout 0.1 --weight-decay 0.0 --update-freq 2  \
--no-epoch-checkpoints --seed 222 --log-format simple --log-interval 2 --patience 10 --arch transformer_wmt_en_de_big \
--encoder-layers 12 --decoder-layers 12 --encoder-layerdrop 0.05 --decoder-layerdrop 0.05 --share-decoder-input-output-embed --share-all-embeddings --ddp-backend no_c10d \
--dumpfisher true --dumpfisherfile $OUTPUT --generate_mask true  | tee $OUTPUT/train.log
done