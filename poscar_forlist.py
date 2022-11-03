#!/usr/bin/env python
# coding: utf-8
import numpy as np
import os 
import pandas as pd
from pymatgen import Structure, Lattice,MPRester
from pymatgen import MPRester
mpr = MPRester('Rw9SXoXqU8sgRx9v')

#dir_=os.getcwd()+'\\Desktop\\1.txt'
dir_='List.txt'
file = pd.read_csv(dir_, sep=',', header=None)

np_file=np.asarray(file)
mp_list=np_file[:,0]



mp_for_list=np_file[:,1]
for mp in mp_for_list:
	print(mp)

