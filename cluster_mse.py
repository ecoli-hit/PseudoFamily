import numpy as np 
import json
import torch
import matplotlib.pyplot as plt

fc_mask = np.load("/data/mxy/Clustering/LanguageSpecify/rebuttal_measure/ED_v2.npy")


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

start = [
            3,
            3,
            3,
            2,
            2,
            
            
            2,
            2,
            2,
            2,
            
            2,
            2,
            
            3,
            3,
            
            1,1,1,1
        ]

# start = [
#             1,
#             1,
#             1,
#             1,
#             1,
        
        
#             1,
#             1,
#             1,
#             1,
    
#             1,
#             1,
        
#             1,
#             1,
            
#             1,1,1,1
#         ]
# waitinglist = {}


for k in range(len(lan)):
    print("============================")
    sort_dict = {}
    l = lan[k]

    for mask, key in zip(fc_mask[k],lan):
        if key == l :
            continue
        # sort_dict[key] = np.abs(round(mask,5)) 
        sort_dict[key] = mask

    
    sort_dict = sorted(sort_dict.items(),key=lambda d:d[1])
    # sort_dict = sorted(sort_dict.items(), key=lambda d:d[1])
    waitinglist = []
    name = []
    for key,v in sort_dict:
        waitinglist.append(v)
        name.append(key)
    # print(name)
    # print(waitinglist)

    # best = start[k]
    # best_var = 0
    # mean = np.mean(waitinglist[:best] )
    # best_var = np.sum((np.array(waitinglist[:best] ) - mean)**2)/(best  )
        
    # for i in range(start[k],16):
    #     mean = mean = np.mean(waitinglist[:i]   )
    #     var = (np.sum((np.array(waitinglist[:i] ) - mean)**2)/(i))
    #     if var <= best_var:
    #         best = i 
    #         best_var = var
    # gap = 1 - waitinglist[0]
    # print(gap)
    # for i in range(1,10):
    #     if waitinglist[i-1] - waitinglist[i] == gap:
    #         best = i 
    #         gap = gap /2
    #         print(gap)
    #     elif waitinglist[i-1] - waitinglist[i] < gap:
    #         best = i 
    #         gap = waitinglist[i-1] - waitinglist[i]
    #         print(gap)
    #     else:
    #         break
        
    best = 1
    gap = waitinglist[1] - waitinglist[0]
    print(gap)
    for i in range(2,10):
        if waitinglist[i] - waitinglist[i - 1] == gap:
            best = i 
            gap = gap /2
            print(gap)
        elif waitinglist[i] - waitinglist[i - 1] < gap:
            best = i 
            gap = waitinglist[i] - waitinglist[i - 1]
            print(gap)
        else:
            break
    
    
    
    idx = 0
    coorp = []
    for k,v in sort_dict:
        coorp.append(k)
        idx +=1
        if idx > best:
            break  
    
    print(f"{l}: {coorp}")  
    print(name)
    print(waitinglist)
    print("============================")
    