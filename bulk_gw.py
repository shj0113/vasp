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


structure=Structure.from_file(filename) #This is reading file


#Modify this two lines.
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NPAR=4, ISMEAR=0, LCHARG='False') #This is parameters for incar
#params=dict(ADDGRID='True',ALGO='Normal',ICHARG=0,ISTART=1, LREAL='False', ENCUT=400, PREC='Normal',LWAVE='True',LCHARG='True',ISPIN=1,LVTOT='True',ISIF=3,ISMEAR=0,SIGMA=0.05,NELM=60,NELMIN=6,EDIFF=1E-08,NSW=200,IBRION=2,EDIFFG=-2E-02)
params={
	"ISTART":1,
	"ALGO":"Normal",
	"ISPIN":2,
	"ICHARG":0,
	"LREAL":"False",
	"ENCUT":520,
	"PREC":"Accurate",
	"LWAVE":"True",
	"LCHARG":"True",
	"ADDGRID":"True",
	"LVTOT":"True",
	"LASPH":"True",
	"ISIF":3,
	"ISMEAR":0,
	"SIGMA":0.05,
	"NELM":60,
	"NELMIN":6,
	"EDIFF":1E-08,
	"EDIFFG":-1E-02,
	"NSW":400,
	"IBRION":2,
	"LDAUPRINT":0,
	"LDAU":"True",
	"LDAUL":{"Sn": 2,"In":2,"Ga":2,"Zn":2,"Ni":2,"Cu":2,"O": -1},
	"LDAUU":{"Sn": 3,"In":3,"Ga":3,"Zn":3,"Ni":3,"Cu":8,"O": 0},
	"LDAUJ":{"Sn": 0,"In":0,"Ga":0,"Zn":0,"Ni":0,"Cu":0,"O": 0},
	"LMAXMIX":4,
	"LDAUTYPE": 2,
	}


#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NPAR=4, ISMEAR=0, LCHARG='False',LWAVE='True') #This is parameters for incar
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NCORE=1, ISMEAR=0, LCHARG='False') #This is parameters for incar
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, KPAR=4, NCORE=3, LREAL='.FALSE.', ISIF=7, ENCUT=300,ISMEAR=1,SIGMA=0.2)  #for instance Mo relaxation
kparams=dict(reciprocal_density=100) #This is density of k-points. 100 is enough usually.
#kparams=dict(reciprocal_density=2000) #This is density of k-points. 100 is enough usually.

# you don't have to modify below this.

mpset = MPRelaxSet(structure)
userset = MPRelaxSet(structure,user_incar_settings=params,user_kpoints_settings=kparams,user_potcar_functional="PBE_54")
#print(userset.incar)
#userset.write_input('.',include_cif=True)
userset.write_input('.')
