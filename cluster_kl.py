import numpy as np 
import json
import torch
import matplotlib.pyplot as plt

fc_mask = np.load("/data/mxy/Clustering/LanguageSpecify/rebuttal_measure/KL_v2_nonorm.npy")

lan = [
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

for k in range(len(lan)):
    print("============================")
    sort_dict = {}
    l = lan[k]

    for mask, key in zip(fc_mask[k],lan):
        if key == l :
            continue
        sort_dict[key] = np.abs(round(mask,5)) 
        # sort_dict[key] = mask

    
    sort_dict = sorted(sort_dict.items(),key=lambda d:d[1])
    # sort_dict = sorted(sort_dict.items(), key=lambda d:d[1])
    waitinglist = []
    name = []
    for key,v in sort_dict:
        waitinglist.append(v)
        name.append(key)
    
        
    best = 1
    gap = waitinglist[1] - waitinglist[0]
    for i in range(2,10):
        if waitinglist[i] - waitinglist[i - 1] == gap:
            best = i 
            gap = gap /2
        elif waitinglist[i] - waitinglist[i - 1] < gap:
            best = i 
            gap = waitinglist[i] - waitinglist[i - 1]
        else:
            break
    
    
    
    idx = 0
    coorp = []
    for k,v in sort_dict:
        coorp.append(k)
        idx +=1
        if idx > best:
            break  
    
    print(f"target langauge {l}: auxiliary languages {coorp}")  
    print("============================")
    