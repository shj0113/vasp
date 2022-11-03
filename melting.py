#!/usr/bin/env python3
import random
import numpy as np
import math
import os

# specify params
domain = "Si"
dopant = "Li"
    
total_num = 100 # 총 원자 개수
doping_num = None # 도펀트 수는 generating_amor()에서 정의할 예정
mindist = 2 # 원자간 최소거리
volume = [12.69, 12.69, 12.69] # unitcell 크기 -> [a, b, c]

# point 생성하는 함수
def genpt():
    x = random.uniform(mindist/2, volume[0]-mindist/2) # periodic boundary condition 때문에 mindist/2 추가
    y = random.uniform(mindist/2, volume[1]-mindist/2)
    z = random.uniform(mindist/2, volume[2]-mindist/2)
    newp = np.array([x, y, z])
    return newp

# point간 거리 계산하는 함수
def distance(p1,p2):
    squared_dist = np.sum((p1-p2)**2, axis=0)
    dist = np.sqrt(squared_dist)
    return dist

def generating_amor(doping_number):
    
    # specify params
    global doping_num
    doping_num = doping_number
    
    sample = []
    while len(sample) < total_num:
        newp = genpt()
        for p in sample:
            if distance(newp,p) < mindist: # 최소거리조건 만족 못하는 경우 else 실행 X -> 그 point sample에 추가 X
                break
        else:
            sample.append(newp)

    f = open("POSCAR", 'w')

    f.write(domain + str(total_num-doping_num) + " " + dopant + str(doping_num) + "\n")
    f.write("1.0")
    f.write("\n       " + "%-20s %-20s %-20s" % (str(volume[0]), "0.0000000000", "0.0000000000"))
    f.write("\n       " + "%-20s %-20s %-20s" % ("0.0000000000", str(volume[1]), "0.0000000000"))
    f.write("\n       " + "%-20s %-20s %-20s" % ("0.0000000000", "0.0000000000", str(volume[2])))
    f.write("\n   " + domain + "   " + dopant)
    f.write("\n   " + str(total_num-doping_num) + "   " + str(doping_num))
    f.write("\nCartesian")
    for i in range(len(sample)):
        f.write("\n     " + "%-20s %-20s %-20s" % (sample[i][0], sample[i][1], sample[i][2]))

    f.close()

for i in range(1,11): # 도핑 농도 설정
    component_name = domain + str(total_num-i) + "_" + dopant + str(i)
    os.mkdir(component_name)
    os.chdir(component_name)
    for j in range(1,6): # amor 폴더 생성 
        structure_name = "amor" + str(j)
        os.mkdir(structure_name)
        os.chdir(structure_name)
        os.mkdir("1_melt")
        os.chdir("1_melt")
        generating_amor(i)
        os.system('bulk_melt.py')
        os.system('pbs_amor.pl')
        os.system('qsub pbs')
        os.chdir("..")
        os.chdir("..")
    os.chdir("..")

