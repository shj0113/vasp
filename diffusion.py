#!/usr/bin/env python3

import os

# specify params
domain = "Si"
dopant = "Li"
    
total_num = 100 # 총 원자 개수

init_temp = 1500
temp_range = 250
cwd = os.getcwd()

for i in range(1,11): # 도핑 농도 설정
    component_name = domain + str(total_num-i) + "_" + dopant + str(i)
    os.chdir(os.path.join(cwd, component_name))
    for j in range(1,6): # amor 폴더
        structure_name = "amor" + str(j)
        os.chdir(structure_name)
        os.mkdir("3_diffusion")
        os.chdir("2_quench")
        os.system('cp CONTCAR ../3_diffusion/')
        os.chdir("..")
        os.chdir("3_diffusion")
        for k in range(0,5): # 온도별 폴더
            temp_name = str(init_temp + (temp_range*k))
            os.mkdir(temp_name)
            os.system('cp CONTCAR ' + temp_name)
            os.chdir(temp_name)
            os.system('mv CONTCAR POSCAR')
            os.system('bulk_diffusion_' + str(init_temp + (temp_range*k)) + '.py')
            os.system('pbs_amor.pl')
#             os.system('qsub pbs')
            os.chdir("..")
        os.chdir("..")
        os.chdir("..")
