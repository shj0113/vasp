#!/usr/bin/env python
# coding: utf-8
import numpy as np
import os
import pandas as pd
import shutil
from pymatgen import Structure, Lattice,MPRester
from pymatgen import MPRester
mpr = MPRester('Rw9SXoXqU8sgRx9v')

#dir_=os.getcwd()+'\\Desktop\\1.txt'
dir_='List.txt'
file = pd.read_csv(dir_, sep=',', header=None)

np_file=np.asarray(file)
mp_list=np_file[:,0]


original_dir=os.getcwd()

for mp in mp_list:
    os.mkdir(mp)
    os.chdir(mp)
    struct = mpr.get_structure_by_material_id(mp,True,True) # mono ga2o3
    struct.to(filename='POSCAR')
#    mp1=str(mp)+".vasp"
#    os.rename('POSCAR',mp1)
#    shutil.copy(mp1,original_dir)
    os.chdir(original_dir)
