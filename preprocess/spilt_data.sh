#!bin/bash

tgt='en'
path=./ted/data
for src in 'fa' 'hi' 'bn' 'id' 'ms' 'ko' 'bg' 'sr' 'hr' 'uk' 'sk' 'be' 'kk' 'tr' 'de' 'sv' 'ja';do
mkdir -p $path/$src'_'$tgt/half

# train
data_prefix=$path/$src'_'$tgt/train
out_folder=$path/$src'_'$tgt/half
# mkdir -p $out_folder
python /data/mxy/Clustering/LanguageSpecify/script/preprocess/train_dev_split.py $src $tgt $data_prefix $out_folder 0.5

mv $out_folder'/valid.'$src $out_folder'/train.'$src 
mv $out_folder'/valid.'$tgt $out_folder'/train.'$tgt

# test
data_prefix=$path/$src'_'$tgt/test
out_folder=$path/$src'_'$tgt/half
# mkdir -p $out_folder
python /data/mxy/Clustering/LanguageSpecify/script/preprocess/train_dev_split.py $src $tgt $data_prefix $out_folder 0.5

mv $out_folder'/valid.'$src $out_folder'/test.'$src 
mv $out_folder'/valid.'$tgt $out_folder'/test.'$tgt

# valid
data_prefix=$path/$src'_'$tgt/dev
out_folder=$path/$src'_'$tgt/half
# mkdir -p $out_folder
python /data/mxy/Clustering/LanguageSpecify/script/preprocess/train_dev_split.py $src $tgt $data_prefix $out_folder 0.5

done