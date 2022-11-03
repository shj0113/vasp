#!/usr/bin/env python3
import sys
import string
from pymatgen.core.structure import Structure
#from pymatgen.core.lattice import Lattice
from pymatgen.io.vasp.inputs import Incar
from pymatgen.io.vasp.sets import MPRelaxSet, VaspInputSet

#assert len(sys.argv)==1, "input POSCAR is required"

if len(sys.argv)==1:
    filename='POSCAR'
else:
    filename=sys.argv[1]

#if not os.path.isfile("POSCAR.orig"):
   # copyfile(filename, "POSCAR.orig")


structure=Structure.from_file(filename) #This is reading file
#Modify this two lines.
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NPAR=4, ISMEAR=0,ISIF=2, LCHARG='False') #This is parameters for incar

#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NCORE=2, ISMEAR=0, ISIF=2, LCHARG='False', GGA='B0', PARAM1='0.1833333333', PARAM2='0.2200000000', LUSE_VDW='.TRUE.', AGGAC='0.0000', LASPH='.TRUE.') #This is parameters for water on graphene with vdW force


#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NCORE=2, ISMEAR=0, ISIF=3, LCHARG='False', GGA='B0', PARAM1='0.1833333333', PARAM2='0.2200000000', LUSE_VDW='.TRUE.', AGGAC='0.0000', LASPH='.TRUE.') #This is parameters for water on graphene with vdW force
#params=dict(ENCUT=500, NSW=0, EDIFFG=-0.02, EDIFF=1E-5,IBRION = -1, ISYM=2, NPAR=4, ISMEAR=0,ISIF=2,SIGMA = 0.1,ICHARG = 0, LCHARG='True', ALGO='Normal') #This is parameters for dos calculation of graphene
params=dict(PREC='Normal',ALGO='Normal',ISTART = 1, LREAL ='Auto', ENCUT=520, LCHARG='False',NPAR=4, ISIF=2, ISMEAR=0, SIGMA=0.05, NELM=100, NELMIN=6, EDIFF=1E-05,  NSW=800, IBRION=2, EDIFFG=-0.01,LUSE_VDW='True') #only relaxation


kparams=dict(reciprocal_density=100) #This is density of k-points. 100 is enough usually.
#kparams=dict(reciprocal_density=400) #This is density of k-points. 100 is enough usually.

# you don't have to modify below this.
mpset = MPRelaxSet(structure)
#userset = MPRelaxSet(structure,user_incar_settings=params,user_kpoints_settings=kparams)
userset = MPRelaxSet(structure,user_incar_settings=params,user_kpoints_settings=kparams,user_potcar_functional="PBE_54")


#userset = MPRelaxSet(structure,user_incar_settings=kparams)
#from pymatgen.io.vasp.inputs import Kpoints
#k = Kpoints(kpts=(4,4,1))
#def gamma_automatic(kpts=(4, 4, 1), shift=(0, 0, 0)): 
#print(userset.incar)
#userset.write_input('.',include_cif=True)
userset.write_input('.')
import os
#os.system('awk \'NR==4{$3="1"}1\' KPOINTS > KPOINTS~')
#os.system('mv KPOINTS~ KPOINTS')
#os.system('awk \'NR==3{$0="Monkhorst-Pack"}1\' KPOINTS  > KPOINTS~')
#os.system('mv KPOINTS~ KPOINTS')

#os.system('awk \'NR==1{$0="K-Mesh Generated with KP-Resolved Value (Low=0.08~0.05, Medium=0.04~0.03, Fine=0.02~0.01): 0.050"}1\' KPOINTS > KPOINTS~')
#os.system('awk \'NR==4{$0="24 24 1"}1\' KPOINTS > KPOINTS~')
#os.system('mv KPOINTS~ KPOINTS')

os.system('cp ~/vasp/graphite/optb88/vdw_kernel.bindat .')  # copy vdw_kernal
