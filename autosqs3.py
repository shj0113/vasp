#!/usr/bin/env python
from pymatgen.analysis.structure_analyzer import get_max_bond_lengths, Element
from pymatgen.core.structure import Structure, Lattice
from pymatgen.ext.matproj import MPRester
import os
from os import path
import re
import time
from subprocess import PIPE, Popen

"""
POSCAR 구조 파일을 읽어 supercell로 만들고 supercell 원자 개수로 진행
AxByCz 구조에서 A, B, C 중의 두 원자에 각각 한 개 원자 랜덤 배열
ex) Ax-αA'αBy-βB'βCz

A = A
B = B
replace_A = A'
replace_B = B'
"""

#number of perfect match attempts
try_match = 10
waiting_perfect_match = 2   #second

#atom being replaced
A = "Ba"
B = "Ti"
supercell = [3,3,3]
number_of_atoms = "135"
atom_distance = "4.8"

#atom to be replaced
replace_A = "Ca"
replace_B = "Zr"
#replace_A_dir = ""


#ratio
x = []   #replace_A ratio
y = []   #replace_B ratio

#number of atoms
num_A = [26,25,24]
num_reA = [1,2,3]

num_B = [26,26,26]
num_reB = [1,1,1]

for numA,numreA in zip(num_A, num_reA):
    sumA = numA + numreA
    ratio_A = numreA/sumA
    x.append(str(ratio_A))

for numB,numreB in zip(num_B, num_reB):
    sumB = numB + numreB
    ratio_B = numreB/sumB
    y.append(str(ratio_B))


original_dir = os.getcwd()

#POSCAR check
#Omit if POSCAR exists
if not path.isfile("POSCAR"):
    number = input("material id : ")
    with MPRester("Rw9SXoXqU8sgRx9v") as mpr:
        struct = mpr.get_structure_by_material_id(number)


#Create directories by ratio
#Create rndstr.in in each directory
if os.path.isfile("POSCAR.original") == False:
    os.system("cp POSCAR POSCAR.original")
    s = Structure.from_file("POSCAR")
    s.make_supercell(supercell)
    s.to(filename="POSCAR")
    structure = Structure.from_file("POSCAR")
else:
   structure = Structure.from_file("POSCAR")

#distance between cations
#atom_bond_lengths = get_max_bond_lengths(structure)
#atom_lengths = atom_bond_lengths[Element(atom), Element(atom)]


#atom lattice information
a = structure.lattice.abc[0]
b = structure.lattice.abc[1]
c = structure.lattice.abc[2]


angle_a = structure.lattice.angles[0]
angle_b = structure.lattice.angles[1]
angle_c = structure.lattice.angles[2]

#Substitute atom(M1) lattice information
#os.chdir(replace_dir)
#replace_A_structure = structure.from_file("CONTCAR")
#replace_A_a = replace_A_structure.lattice.abc[0]
#replace_A_b = replace_A_structure.lattice.abc[1]
#replace_A_c = replace_A_structure.lattice.abc[2]
#distance between cations in replace_A
#replace_bond_lengths = get_max_bond_lengths(replace_A_structure)
#replace_lengths = replace_bond_lengths[Element(replace_A), Element(replace_A)]
#os.chdir(original_dir)

#gradient_a = float(replace_A_a) - float(a)
#gradient_b = float(replace_A_b) - float(b)
#gradient_c = float(replace_A_c) - float(c)
#gradient_lengths = (float(replace_lengths) - float(atom_lengths))

complete = list()
not_complete = list()

for j,k in zip(x,y):
    #re_a = gradient_a*float(j) + float(a)
    #re_b = gradient_b*float(j) + float(b)
    #re_c = gradient_c*float(j) + float(c)
    #re_lengths = gradient_lengths*float(j) + float(atom_lengths)
    num = 7
    l = 1-float(j)
    m = 1-float(k)
    round_l = str(int(round(l,2)*100))
    round_m = str(int(round(m,2)*100))
    round_j = str(int(round(float(j),2)*100))
    round_k = str(int(round(float(k),2)*100))


    dir_name = A+replace_A+B+replace_B+"O"+"_"+round_l+"_"+round_j+"_"+round_m+"_"+round_k+"_300"

    print("now {}".format(dir_name))
    if not path.isdir(dir_name):
        os.mkdir(dir_name)
    os.chdir(dir_name)
    if not path.isdir("relax"):
        os.mkdir("relax")
    os.chdir("relax")
    #struct = str(re_a)+" "+str(re_b)+" "+str(re_c)+" "+str(angle_a)+" "+str(angle_b)+" "+str(angle_c)
    struct = str(a)+" "+str(b)+" "+str(c)+" "+str(angle_a)+" "+str(angle_b)+" "+str(angle_c)
    


    with open("rndstr.in", 'w') as f0:
        f0.write(struct)
    with open("rndstr.in", 'a') as f1:
        f1.write("\n1 0 0\n0 1 0\n0 0 1\n")

    os.chdir(original_dir)
    while True:
        try:
            num += 1
            with open("POSCAR", 'r') as f2:
                data = f2.readlines()[num]
                data_replace1 = data.replace(str(A), str(A)+"="+str(l)+","+str(replace_A)+"="+str(j))
                data_replace2 = data_replace1.replace(str(B), str(B)+"="+str(m)+","+str(replace_B)+"="+str(k))
                os.chdir(dir_name)
                os.chdir("relax")
                with open("rndstr.in", 'a') as f_rnd:
                    f_rnd.write(data_replace2)
                os.chdir(original_dir)
        except:
            break
    os.chdir(dir_name)
    os.chdir("relax")

#run sqs with rndstr.in
    check_num = 1
    pat = re.compile("Objective_function= Perfect_match")
    
    while check_num <= try_match:
        check_num += 1
        #os.system("corrdump -l=rndstr.in -ro -noe -nop -clus -2="+str(re_lengths)+" > corrdump.log 2>&1; getclus >/dev/null 2>&1")
        os.system("corrdump -l=rndstr.in -ro -noe -nop -clus -2="+"4.1"+" > corrdump.log 2>&1; getclus >/dev/null 2>&1")
        os.system("mcsqs -n="+number_of_atoms+" > mcsqs.log 2>&1 & >/dev/null 2>&1")
		
        time.sleep(waiting_perfect_match)
#only data that is perfect_match will create a POSCAR
        if path.isfile("bestcorr.out"):
            with open("bestcorr.out", 'r') as f3:
                perfect = f3.read()
                find = pat.findall(perfect)

    if path.isfile("bestcorr.out"):
        complete.append(dir_name)
        os.system("sqs2poscar bestsqs.out")
        popen = os.popen("pidof mcsqs").read()
        os.system("kill -9 "+popen)
    
    else:
        popen = os.popen("pidof mcsqs").read()
        os.system("kill -9 "+popen)
           

    pop_pat = re.compile("[0-9]+[.][0-9]+[-][0-9]+[.][0-9]+")

#calculate POSCAR
    if path.isfile("bestsqs.out-POSCAR"):
        os.system("mv bestsqs.out-POSCAR POSCAR")
#If ValueError occurs in POSCAR, fix it
        while True:
            if os.system('bulk_gamma.py >/dev/null 2>&1') != 0:
                popen = Popen('bulk_gamma.py', stderr=PIPE)
                stderr = popen.communicate()
                pop = pop_pat.findall(str(stderr))
                pop_split = pop[0].split("-")
                with open("POSCAR", 'rt') as file_:
                    file_read = file_.read()
                with open("POSCAR", 'wt') as file_1:
                    file_read = file_read.replace(pop[0], pop_split[0]+" -"+pop_split[1])
                    file_1.write(file_read)
            else:
                os.system('bulk_gamma.py')
                break
        os.system("pbs_gamma.pl")
        os.system("qsub pbs")
    else:
        not_complete.append(dir_name)
        print(dir_name+" not exist bestsqs.out-POSCAR")
    os.chdir(original_dir)

if complete != list():
    print("Complete ratio list\n{}".format(complete))
if not_complete != list():
    print("Not complete ratio list\n{}".format(not_complete))
else:
    print("all complete")
print("Done")
