#!/usr/bin/env python3

import os

# specify params
domain = "Si"
dopant = "Li"
    
total_num = 100 

for i in range(1,2): 
    component_name = domain + str(total_num-i) + "_" + dopant + str(i)
    os.chdir(component_name)
    for j in range(1,2): 
        structure_name = "amor" + str(j)
        os.chdir(structure_name)
        os.mkdir("2_quench")
        os.chdir("1_melt")
        os.system('cp CONTCAR ../2_quench')
        os.chdir("..")
        os.chdir("2_quench")
        os.system('mv CONTCAR POSCAR')
        os.system('bulk_quench.py') 
        os.system('pbs_amor.pl')
#        os.system('qsub pbs')
        os.chdir("..")
        os.chdir("..")
    os.chdir("..")
