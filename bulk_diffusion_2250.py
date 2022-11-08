#!/usr/bin/env python3
import sys
import string
from pymatgen.core.structure import Structure
#from pymatgen.core.lattice import Lattice
from pymatgen.io.vasp.inputs import Incar, Kpoints
from pymatgen.io.vasp.sets import MPRelaxSet, VaspInputSet

#assert len(sys.argv)==1, "input POSCAR is required"

if len(sys.argv)==1:
    filename='POSCAR'
else:
    filename=sys.argv[1]


structure=Structure.from_file(filename) #This is reading file


#Modify this two lines.
#params=dict(NPAR=4,LASPH='True',EDIFF=0.001,LREAL='False')
params= dict(
    ISTAR=1,
    ISPIN=1,
    LREAL="Auto",
    LWAVE="TRUE",
    LCHARG="TRUE",
    ADDGRID="TRUE",
    ISIF=2,
    NCORE=4,
    ISMEAR=0,
    NELM=200,
    SIGMA=0.05,
    EDIFF=1E-08,
    IBRION=0,
    NSW=1000,
    EDIFFG=-1E-02,
    POTIM=3,
    SMASS=0,
    TEBEG=2250,
    TEEND=2250,
    MDALGO=2,
    NWRITE=0)
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NPAR=4, ISMEAR=0, LCHARG='False') #This is parameters for incar
#params=dict(ALGO = 'Fast',NSW=800, EDIFFG=-0.01, EDIFF=1E-8, NPAR=4, ISMEAR=0,LASPH='True',ISPIN=2,LWAVE=True) #This is parameters for incar
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NPAR=4, ISMEAR=0, LCHARG='False',LWAVE='True') #This is parameters for incar
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NCORE=1, ISMEAR=0, LCHARG='False') #This is parameters for incar
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, KPAR=4, NCORE=3, LREAL='.FALSE.', ISIF=7, ENCUT=300,ISMEAR=1,SIGMA=0.2)  #for instance Mo relaxation
kparams=dict(reciprocal_density=50) #This is density of k-points. 100 is enough usually.
#kparams=dict(reciprocal_density=2000) #This is density of k-points. 100 is enough usually.

# you don't have to modify below this.
mpset = MPRelaxSet(structure)
#userset = MPRelaxSet(structure,user_incar_settings=params)
userset = MPRelaxSet(structure,user_incar_settings=params,user_kpoints_settings=kparams,user_potcar_functional="PBE_54")
#print(userset.incar)
#userset.write_input('.',include_cif=True)
userset.write_input('.')

kpoints = Kpoints.from_file("KPOINTS")
kpoint = kpoints.gamma_automatic(kpts=(1,1,1), shift=(0,0,0))
kpoint.write_file("KPOINTS")
Incar.from_dict(params).write_file("INCAR")
