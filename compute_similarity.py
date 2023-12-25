import numpy as np 
import seaborn as sns
import os
import torch
import matplotlib.pyplot as plt
import tqdm
import logging
import sys
import argparse

parse = argparse.ArgumentParser()
parse.add_argument("--folder",type=str,required=True,help="The folder contain the FIM")
parse.add_argument("--prefix",type=str,required=True,help="The prefix of the FIM file")
parse.add_argument("--outfolder",type=str,required=True,help="The output folder of the overlap similarity matrix")
parse.add_argument("--outprefix",type=str,required=True,help="The output prefix of the overlap similarity matrix file")
parse.add_argument("--mode",type=str,required=True,help="The output prefix of the overlap similarity matrix file")

args = parse.parse_args()
mode = args.mode
th = float(sys.argv[1])
tgt = 'en'
src= [
            'bg',
            'sr',
            'hr',
            'uk',
            'sk',
            # 'mk',
            # 'sl',
            # 'bs',
            
            'be',
            'fa',
            'hi',
            # 'mr',
            'bn',
            
            'id',
            'ms',
            
            'kk',
            'tr',
            
            'de',
            'sv',
            'ja',
            'ko'
        ]
# # src=['ar','de']
folder = args.folder ## folder with the FIM
_fisher = "fc_fisher.npy"
_mask = f"{args.prefix}.npy" # generated FIM 

fisher = {}
mask = {}
# load 
bar1 = tqdm.tqdm(range(len(src)))
for s in src:
    fisher[s] = np.load(os.path.join(
        folder, f"{s}_{tgt}", _fisher), allow_pickle=True).item()
    mask[s] = np.load(os.path.join(folder,f"{s}_{tgt}", _mask),allow_pickle=True).item()
    bar1.update(1)
del bar1

def overlap(i,j):
    total = 0
    overlap = 0
    for k,v in i.items() :
        overlap += ((i[k] * j[k])==True).sum()
        total += ((i[k])==True).sum()
    return overlap/total

def KL(f1, f2):
    # p1 main
    dis1 = 0
    dis2 = 0
    for k, v in fisher[f1].items():
        c1 = np.array(fisher[f1][k])
        c2 = np.array(fisher[f2][k])
        dis1 += np.sum((c2) * (np.log(c2 + 1e-16) - np.log(c1 + 1e-16)) )
        dis2 += np.sum((c1) * (np.log(c1 + 1e-16) - np.log(c2 + 1e-16)) )
        
        # dis1 += np.sum((np.exp(c1) * (c1 - c2) * (mask[f1][k] | mask[f2][k])))
        # dis2 += np.sum((np.exp(c2) * (c2 - c1) * (mask[f1][k] | mask[f2][k])))
    return dis1, dis2

def ED(f1, f2):
    dis1 = 0
    dis2 = 0
    num1 = 0
    num2 = 0
    for k, v in fisher[f1].items():
        c1 = np.array(fisher[f1][k])
        c2 = np.array(fisher[f2][k])
        distance = (c1 - c2)**2
        dis1 += np.sum(distance)
        num1 += c1.size

    return dis1, dis1



if __name__ == "__main__":
    
    out = np.zeros([len(src),len(src)])
    if mode == "Overlap":
        _src = len(src)
        cal = _src**2 - _src
        bar1 = tqdm.tqdm(range(cal))
        for idx,i in enumerate(src):
            for jdx,j in enumerate(src):
                if i==j:
                    continue
                out[idx,jdx] = (overlap(mask[i],mask[j]))
                bar1.update(1)
    elif mode == "KL":
        bar2 = tqdm.tqdm(range((len(src)**2 + len(src)//2)))
        logging.info('info beging computing')


        for index1, p1 in enumerate(src):
            for index2, p2 in enumerate(src):
                if p1 == p2:
                    bar2.update(1)
                    continue
                
                out[index1, index2], out[index2, index1] = KL(p1, p2)
                bar2.update(1)
    elif mode == "MSE":
        bar2 = tqdm.tqdm(range((len(src)**2 + len(src)//2)))
        logging.info('info beging computing')


        for index1, p1 in enumerate(src):
            for index2, p2 in enumerate(src):
                if p1 == p2:
                    bar2.update(1)
                    continue
                
                out[index1, index2], out[index2, index1] = ED(p1, p2)
                bar2.update(1)
    
    
    np.save(f"{args.outfolder}/{args.outprefix}",out)
    # out = np.load("/data/mxy/Clustering/measure/fc_overlap_7.npy")
    mask = np.zeros_like(out, dtype=bool)  
    for i in range(len(src)):
        mask[i,i] = True

    fig ,ax= plt.subplots(figsize=[40,40])         
    sns.heatmap(data=out,annot=True,mask=mask,cmap="Blues",cbar=False)
    ax.set_xticklabels(src)
    ax.set_yticklabels(src) 
    plt.savefig(f"{args.outfolder}/{args.outprefix}.png",dpi=300)