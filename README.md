# Clustering Pseudo Language Family in Multilingual Translation Models with Fisher Information Matrix

Code for paper "Clustering Pseudo Language Family in Multilingual Translation Models with Fisher Information Matrix"

Paper: https://openreview.net/forum?id=8CQ0DUuSAK

Authors: [Xinyu Ma](https://ecoli-hit.github.io/), [Xuebo Liu](https://sunbowliu.github.io/), [Min Zhang](https://zhangminsuda.github.io/)

Institute of Computing and Intelligence, Harbin Institute of Technology, Shenzhen, China

## Citation
If you find this repo helpful, please cite: 
```
@inproceedings{ma-etal-2023-clustering,
    title = "Clustering Pseudo Language Family in Multilingual Translation Models with Fisher Information Matrix",
    author = "Ma, Xinyu  and
      Liu, Xuebo  and
      Zhang, Min",
    editor = "Bouamor, Houda  and
      Pino, Juan  and
      Bali, Kalika",
    booktitle = "Proceedings of the 2023 Conference on Empirical Methods in Natural Language Processing",
    month = dec,
    year = "2023",
    address = "Singapore",
    publisher = "Association for Computational Linguistics",
    url = "https://aclanthology.org/2023.emnlp-main.851",
    doi = "10.18653/v1/2023.emnlp-main.851",
    pages = "13794--13804",
    abstract = "In multilingual translation research, the comprehension and utilization of language families are of paramount importance. Nevertheless, clustering languages based solely on their ancestral families can yield suboptimal results due to variations in the datasets employed during the model{'}s training phase. To mitigate this challenge, we introduce an innovative method that leverages the fisher information matrix (FIM) to cluster language families, anchored on the multilingual translation model{'}s characteristics. We hypothesize that language pairs with similar effects on model parameters exhibit a considerable degree of linguistic congruence and should thus be grouped cohesively. This concept has led us to define pseudo language families. We provide an in-depth discussion regarding the inception and application of these pseudo language families. Empirical evaluations reveal that employing these pseudo language families enhances performance over conventional language families in adapting a multilingual translation model to unfamiliar language pairs. The proposed methodology may also be extended to scenarios requiring language similarity measurements. The source code and associated scripts can be accessed at https://github.com/ecoli-hit/PseudoFamily.",
}
```

## Overview

In multilingual translation research, the comprehension and utilization of language families are of paramount importance. Nevertheless, clustering languages based solely on their ancestral families can yield suboptimal results due to variations in the datasets employed during the model's training phase. To mitigate this challenge, we introduce an innovative method that leverages the fisher information matrix (FIM) to cluster language families, anchored on the multilingual translation model's characteristics. We hypothesize that language pairs with similar effects on model parameters exhibit a considerable degree of linguistic congruence and should thus be grouped cohesively. This concept has led us to define pseudo language families. We provide an in-depth discussion regarding the inception and application of these pseudo language families. Empirical evaluations reveal that employing these pseudo language families enhances performance over conventional language families in adapting a multilingual translation model to unfamiliar language pairs. The proposed methodology may also be extended to scenarios requiring language similarity measurements.

### Result on TED Dataset
The auxiliary languages we selected with the three methods for these target language pairs.

<p align="center">
  <img src="https://github.com/ecoli-hit/PseudoFamily/assets/74221501/4dc48487-4f29-4ebf-9bb8-9a6f2cf12bf7" />
</p>

The main improvement our methodology achieves.

<p align="center">
  <img src="https://github.com/ecoli-hit/PseudoFamily/assets/74221501/43a0c0e5-1e50-4143-b546-12c6e6520572" />
</p>

## Installation
This implementation is based on fairseq=0.12.2

+ python>=3.8.0
+ torch>=2.0
```
git clone https://github.com/ecoli-hit/PseudoFamily.git
cd PseudoFamily
git clone https://github.com/moses-smt/mosesdecoder
cd fairseq
pip install --editable .
```
## Dataset
You can download the dataset in [here](https://github.com/neulab/word-embeddings-for-nmt), and follow the description to read the data. We selected 17 languages to English to conduct a shared language pool for selecting auxiliary languages. The languages and corresponding families we used in our experiments are shown below.

<p align="center">
  <img src="https://github.com/ecoli-hit/PseudoFamily/assets/74221501/47d08161-bfa2-416a-8906-c24bdbc8e3be" width="500px">
</p>


## Model
We use m2m100_418M to conduct our experiments, you can download the model [here](https://github.com/facebookresearch/fairseq/tree/main/examples/m2m_100).

## Training the Language Representations
1. Preprocess the data run.
    - `sh ./preproess/preprocess.sh`
2. Train with one epoch and estimate the fisher information matrix of the model parameter.
    - `sh ./train/train.sh`
3. Form the fisher information mask.
    - `sh ./form_mask.sh`

## Select the Auxiliary Languages
To effectively leverage the results derived from the FIM and judiciously select auxiliary languages for multilingual training of a specific target language pair, we devised three distinct strategies for calculating the similarity or distance between language pairs.

- `py ./cluster_kl.py` - select with KL divergence
- `py ./cluster_mse.py` - select with Mean Square Error
- `py ./cluster_overlap.py` - select with Overlapping method with the generated masks

## Train and Generation
Training with the selected auxiliary language pairs `sh ./train/train.sh`, generate and evaluate with `sh ./train/generate.sh`. The main result is shown above.
