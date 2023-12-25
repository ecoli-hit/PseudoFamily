folder=/data/mxy/Clustering/LanguageSpecify/ted_fisher_v2
tgt=en
# src=('sr' 'id' 'he' 'cs')
src=('fa' 'hi' 'bn' 'id' 'ms' 'ko' 'bg' 'sr' 'hr' 'uk' 'sk' 'be' 'kk' 'tr' 'de' 'sv' 'ja')
# src=('ar' 'de' 'el' 'bg' 'cs' 'es' 'fr' 'zh' 'ko' 'ru' 'tr' 'it' 'ja' 'he' 'pt' 'ro' 'vi' 'nl' 'hu' 'fa' 'pl' 'sr' 'uk' 'hr' 'id' 'th' 'sv' 'sk')
# for src in 'ar' 'de' 'el' 'bg' 'cs' 'es' 'fr' 'zh' 'ko' 'ru' 'tr' 'it' 'ja' 'he' 'pt' 'ro' 'vi' 'nl' 'hu' 'fa' 'pl' 'sr' 'uk' 'hr' 'id' 'th' 'sv' 'sk';do
# echo $src
# python script/analy2/form_mask.py --folder $folder --src $src --tgt $tgt
# done
for i in `seq 0 3`;do
# echo $i
echo ${src[`expr $i \* 4 + 0`]}
python script/analy2/form_mask.py --folder $folder --src ${src[`expr $i \* 4 + 0`]} --tgt $tgt  --threshold 0.4&

echo ${src[`expr $i \* 4 + 1`]}
python script/analy2/form_mask.py --folder $folder --src ${src[`expr $i \* 4 + 1`]} --tgt $tgt  --threshold 0.4&

echo ${src[`expr $i \* 4 + 2`]}
python script/analy2/form_mask.py --folder $folder --src ${src[`expr $i \* 4 + 2`]} --tgt $tgt  --threshold 0.4&

echo ${src[`expr $i \* 4 + 3`]}
python script/analy2/form_mask.py --folder $folder --src ${src[`expr $i \* 4 + 3`]} --tgt $tgt  --threshold 0.4&

wait
done

python script/analy2/form_mask.py --folder $folder --src ja --tgt $tgt &

# python script/analy2/form_mask.py --folder ./output/ --src zh --tgt en