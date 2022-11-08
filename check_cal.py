#!/usr/bin/env python3

import os
import re

def grep(string, directory):
    with open(outcar, 'r') as f:
        for word in f:
            if re.search(string, word):
                return word

def vasp_p(directory):
    with open(outcar, 'r') as f:
        contents = f.read()
        if 'General timing and accounting informations for this job:' in contents:
            return True
        else:
            return False

for root,dirs,files in os.walk(os.getcwd()):
    if not dirs:
        outcar = os.path.join(root, 'OUTCAR')
        if os.path.exists(outcar):
            if vasp_p(root):
                total_time = grep('CPU', root).strip()
                total_time = float(total_time[30:])
                print(root, " : calculation is completed. total time is {0:1.0f} min.".format(total_time / 60))
            else:
                print("!!!! ERROR !!!! : OUTCAR is exists. But, This calculation is not successfully completed.", root)
        else: 
            print("!!!! ERROR !!!! : There is no OUTCAR in this directory", root)
