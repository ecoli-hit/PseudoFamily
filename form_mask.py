import torch
import json
import argparse
import os
import numpy as np 
# for lan in 

parser = argparse.ArgumentParser()
parser.add_argument("--folder",type=str,required=True,help="Folder of FIM")
parser.add_argument("--src",type=str,required="src language")
parser.add_argument("--tgt",type=str,required="tgt language")
parser.add_argument("--threshold",type=float,required="The shreshold of fisher information mask")
parser.add_argument("--mode",type=float,required="The range of parameter you want to generate a mask: all, fc, de_fc")
# parser.add_argument("--folder",type=str,required=True)

arg=parser.parse_args()

folder = arg.folder
src = arg.src
tgt = arg.tgt
threshold = float(arg.threshold)
mode = arg.mode


def All_parameters():
    path = os.path.join(folder,f"{src}_{tgt}")
    _fisher = "global_fisher.pt"
    _polar = "polar.json"

    fisher = torch.load(os.path.join(path,_fisher))
    polar = json.load(open(os.path.join(path,_polar)))

    mask = {}
    for k,v in fisher.items():
        mask[k] = np.array(v) >= polar[threshold]

    # torch.save(fisher,os.path.join(path,"mask.pt"))
    np.save(os.path.join(path,"mask"),mask)
    
def Fc_parameters():
    path = os.path.join(folder,f"{src}_{tgt}")
    _fisher = "global_fisher.pt"
    _polar = "polar.json"

    fisher = torch.load(os.path.join(path,_fisher))
    polar = json.load(open(os.path.join(path,_polar)))

    fc_fisher = {}
    mask = {}
    for k,v in fisher.items():
        if "fc1.weight" in k or "fc2.weight" in k:
            fc_fisher[k] = np.array(v)
            mask[k] = np.array(v) >= polar[threshold]

    # torch.save(fisher,os.path.join(path,"mask.pt"))
    np.save(os.path.join(path,"fc_mask_3"),mask)
    np.save(os.path.join(path,"fc_fisher"),fc_fisher)
    
def Decoder_fa_parameters():
    path = os.path.join(folder,f"{src}_{tgt}")
    _fisher = "global_fisher.pt"
    _polar = "polar.json"

    fisher = torch.load(os.path.join(path,_fisher))
    polar = json.load(open(os.path.join(path,_polar)))

    fc_fisher = {}
    mask = {}
    for k,v in fisher.items():
        if  "decoder.layers" in k:
            if "fc1.weight" in k or "fc2.weight" in k:
                fc_fisher[k] = np.array(v)
                mask[k] = np.array(v) >= polar[threshold]

    # torch.save(fisher,os.path.join(path,"mask.pt"))
    np.save(os.path.join(path,"de_mask_0.4"),mask)
    # np.save(os.path.join(path,"fc_fisher_1"),fc_fisher)

    
def add_polar():
    path = os.path.join(folder,f"{src}_{tgt}")
    _fisher = "global_fisher.pt"
    _polar = "polar.json"

    fisher = torch.load(os.path.join(path,_fisher))
    polar = json.load(open(os.path.join(path,_polar)))

    fc_fisher = {}
    mask = {}
    D = []
    for k,v in fisher.items():  
        v = torch.tensor(v).flatten()
        D = np.concatenate((D,v))
        # if "fc1.weight" in k or "fc2.weight" in k:
        #     fc_fisher[k] = np.array(v)
        #     mask[k] = np.array(v) >= polar["0.1"]
    # D =
    p = np.percentile(np.array(D),30)
    polar[threshold] = p
    print(polar)
    # import json
    # torch.save(fisher,os.path.join(path,"mask.pt"))
    # np.save(os.path.join(path,"fc_mask_1"),mask)
    # np.save(os.path.join(path,"fc_fisher_1"),fc_fisher)
    json.dump(polar,open(os.path.join(path,"polar_ex.json"),'w'))
    
if __name__=="__main__":
    # form_all_fc()
    if mode == "all":
        All_parameters()
    elif mode == "fc":
        Fc_parameters()
    elif mode == "de_fc":
        Decoder_fa_parameters()