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
params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, NPAR=4, ISMEAR=0, LCHARG='False') #This is parameters for incar
#params=dict(NSW=200, EDIFFG=-0.01, EDIFF=1E-5, KPAR=4, NCORE=3, LREAL='.FALSE.', ISIF=7, ENCUT=300,ISMEAR=1,SIGMA=0.2)  #for instance Mo relaxation
kparams=dict(reciprocal_density=100) #This is density of k-points. 100 is enough usually.


# you don't have to modify below this.
mpset = MPRelaxSet(structure)
userset = MPRelaxSet(structure,user_incar_settings=params)
#print(userset.incar)
#userset.write_input('.',include_cif=True)
userset.write_input('.')
