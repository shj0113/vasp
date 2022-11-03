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
AxByCz 구조에서 A, B, C 중의 한 원자에 두 개 원자 랜덤 배열
ex)Ax-α-βA'αA''βByCz

atom = A
M1 = A'
M2 = A''
num_M1에 A의 원자 갯수
num_reM1에 A'의 원자 갯수
num_reM2에 A''의 원자 갯수
"""

#number of perfect match attempts
try_match = 10
waiting_perfect_match = 2  #second

#atom being replaced
atom = "Ce"
supercell = [1,1,1]
number_of_atoms = "96"
atom_distance = "4.8"



#atom to be replaced
M1 = ["Ni"]
M2 = ["Cr"]
#M1_dir = "MnO2"


#ratio
x = []  #M1 ratio
y = []  #M2 ratio

#number of atoms
num_M1 = [23]
num_reM1 = [6]
num_reM2 = [3]
#num_B = []
#num_reB = []

for numM1,numreM1,numreM2 in zip(num_M1, num_reM1, num_reM2):
	sumA = numM1 + numreM1 + numreM2
	ratio_A = numreM1/sumA
	ratio_B = numreM2/sumA
	x.append(str(ratio_A))
	y.append(str(ratio_B))

#for numB,numreB in zip(num_B, num_reB):
#	sumB = numB + numreB
#	ratio_A = numreB/sumB
#	y.append(str(ratio_B))

original_dir = os.getcwd()

#POSCAR check
#Omit if POSCAR exists
if not path.isfile("POSCAR"):
    number = input("material id : ")
    with MPRester("Rw9SXoXqU8sgRx9v") as mpr:
        struct = mpr.get_structure_by_material_id(number, True, True) #conventional cell
        #struct = mpr.get_structure_by_material_id(number)
    struct.to(filename="POSCAR")

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

##Substitute atom(M1) lattice information
#os.chdir(M1_dir)
#M1_structure = Structure.from_file("CONTCAR")
#M1_a = M1_structure.lattice.abc[0]
#M1_b = M1_structure.lattice.abc[1]
#M1_c = M1_structure.lattice.abc[2]
##distance between cations in M1
#M1_bond_lengths = get_max_bond_lengths(M1_structure)
#M1_lengths = M1_bond_lengths[Element(M1), Element(M1)]
#os.chdir(original_dir)

#gradient_a = float(M1_a) - float(a)
#gradient_b = float(M1_b) - float(b)
#gradient_c = float(M1_c) - float(c)
#gradient_lengths = (float(M1_lengths) - float(atom_lengths))

complete = list()
not_complete = list()

#If there is no y value
if not 'M2' in locals():
    y=[]
    for any_y in range(len(x)):
        y.append("0")
else:
    pass
    

for j,k in zip(x,y):
    #re_a = gradient_a*float(j) + float(a)
    #re_b = gradient_b*float(j) + float(b)
    #re_c = gradient_c*float(j) + float(c)
    #re_lengths = gradient_lengths*float(j) + float(atom_lengths)
    #l = 1-float(j)
    #m = 1-float(k)
    #round_l = str(int(round(l,2)*100))
    #round_m = str(int(round(m,2)*100))
    round_j = str(int(round(float(j),2)*100))
    round_k = str(int(round(float(k),2)*100))
    jk = float(j)+float(k)
    i = 1-jk
    round_i = str(int(round(i,2)*100))

    if i < 0:
        print("x+y > 1")
        print("x : {}".format(j))
        print("y : {}".format(k))
        os.exit()

    i = str(i)
    for m1 in M1:
        for m2 in M2:
            num = 7
            if 'm2' in locals():
                dir_name = atom+m1+m2+"O"+"_"+round_i+"_"+round_j+"_"+round_k+"_200"
            else:
                dir_name = atom+m1+"O"+"_"+round_i+"_"+round_j+"_200"
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
                        if 'm2' in locals():
                            data_replace = data.replace(str(atom), str(atom)+"="+str(i)+","+str(m1)+"="+str(j)+","+str(m2)+"="+str(k))
                        else:
                            data_replace = data.replace(str(atom), str(atom)+"="+str(i)+","+str(m1)+"="+str(j))
                        os.chdir(dir_name)
                        os.chdir("relax")
                        with open("rndstr.in", 'a') as f_rnd:
                            f_rnd.write(data_replace)
                        os.chdir(original_dir)
                except:
                    break
            os.chdir(dir_name)
            os.chdir("relax")
    
#run sqs with rndstr.in
            check_num = 1
            pat = re.compile("Objective_function= Perfect_match")

            while check_num <= try_match:
#        try_name = "try"+str(check_num)
#       os.mkdir(try_name)
#        os.chdir(try_name)
#        os.system("cp ../rndstr.in .")
                check_num += 1
                os.system("corrdump -l=rndstr.in -ro -noe -nop -clus -2="+atom_distance+" > corrdump.log 2>&1; getclus >/dev/null 2>&1")
                os.system("mcsqs -n="+number_of_atoms+" > mcsqs.log 2>&1 & >/dev/null 2>&1")
#        os.chdir(dir_name)

                time.sleep(waiting_perfect_match)

            
#only data that is perfect_match will create a POSCAR
    #    if path.isfile("bestcorr.out"):
    #        with open("bestcorr.out", 'r') as f3:
    #            perfect = f3.read()
    #            find = pat.findall(perfect)

    #            if bool(find) == True:
    #                complete.append(dir_name)
    #                os.system("sqs2poscar bestsqs.out")
    #                break
    #            else:
            if path.isfile("bestcorr.out"):
                complete.append(dir_name)
                os.system("sqs2poscar bestsqs.out")
                popen = os.popen("pidof mcsqs").read()
                os.system("kill -9 "+popen)
            else:
                popen = os.popen("pidof mcsqs").read()
                os.system("kill -9 "+popen)
                not_complete.append(dir_name)

                                    

    #    else:
    #        pass

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
                        with open("POSCAR" ,'rt') as file_:
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
