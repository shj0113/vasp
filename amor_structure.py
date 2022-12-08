#!/usr/bin/env python3
import random
import numpy as np
import math
import os

# specify params
domain = "Si"
dopant = "Li"
total_num = 100 # 총 원자 개수
mindist = 2 # 원자간 최소거리

domain_mass = 28.086
domain_density = 2.281304557
dopant_mass = 6.941
dopant_density = 0.572837884

class Generator:
    
    def __init__(self, doping_num):
        self.doping_num = doping_num
        self.domain_num = total_num - self.doping_num
        
    # volume을 만들어주는 함수
    def volume(self):
        domain_volume = (domain_mass * self.domain_num * (10**24))/(6.022E+23*domain_density)
        dopant_volume = (dopant_mass * self.doping_num * (10**24))/(6.022E+23*dopant_density)
        total_volume = domain_volume + dopant_volume
        a = total_volume**(1/3)
        return [a, a, a]
    
    # point 생성하는 함수
    def genpt(self):
        volume = Generator(self.doping_num).volume()
        x = random.uniform(mindist/2, volume[0]-mindist/2) # periodic boundary condition 때문에 mindist/2 추가
        y = random.uniform(mindist/2, volume[1]-mindist/2)
        z = random.uniform(mindist/2, volume[2]-mindist/2)
        newp = np.array([x, y, z])
        return newp
    
    # point간 거리 계산하는 함수
    def distance(self, p1, p2):
        squared_dist = np.sum((p1-p2)**2, axis=0)
        dist = np.sqrt(squared_dist)
        return dist


def generating_amor(doping_number):
    
    # 기본 골격 생성
    structure = Generator(doping_number)
    volume = structure.volume()
    
    # 원자 위치 생성
    sample = []
    while len(sample) < total_num: # total_num = 100개의 포인트가 다 만들어질 때까지 실행
        newp = structure.genpt()
        for p in sample:
            if structure.distance(newp,p) < mindist: # 최소거리조건 만족 못하는 경우 else 실행 X -> 그 point sample에 추가 X
                break
        else:
            sample.append(newp)
    
    # POSCAR 파일 쓰기
    f = open("POSCAR", 'w')

    f.write(domain + str(total_num-structure.doping_num) + " " + dopant + str(structure.doping_num) + "\n")
    f.write("1.0")
    f.write("\n       " + "%-20s %-20s %-20s" % (str(volume[0]), "0.0000000000", "0.0000000000"))
    f.write("\n       " + "%-20s %-20s %-20s" % ("0.0000000000", str(volume[1]), "0.0000000000"))
    f.write("\n       " + "%-20s %-20s %-20s" % ("0.0000000000", "0.0000000000", str(volume[2])))
    f.write("\n   " + domain + "   " + dopant)
    f.write("\n   " + str(total_num-structure.doping_num) + "   " + str(structure.doping_num))
    f.write("\nCartesian")
    for i in range(len(sample)):
        f.write("\n     " + "%-20s %-20s %-20s" % (sample[i][0], sample[i][1], sample[i][2]))

    f.close()

# 실제 계산 돌리는 코드
for i in range(1,2): # 도핑 농도 설정
    component_name = domain + str(total_num-i) + "_" + dopant + str(i)
    os.mkdir(component_name)
    os.chdir(component_name)
    for j in range(1,6): # amor 폴더 생성 
        structure_name = "amor" + str(j)
        os.mkdir(structure_name)
        os.chdir(structure_name)
        os.mkdir("1_relax")
        os.chdir("1_relax")
        generating_amor(i)
        os.system('bulk_amor_relax.py')
#        os.system('pbs.pl')
#         os.system('qsub pbs')
        os.chdir("..")
        os.chdir("..")
    os.chdir("..")
