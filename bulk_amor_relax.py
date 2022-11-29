#!/usr/bin/env python3
import sys
import string
from pymatgen.core.structure import Structure
#from pymatgen.core.lattice import Lattice
from pymatgen.io.vasp.inputs import Incar
from pymatgen.io.vasp.sets import MPRelaxSet, VaspInputSet

structure=Structure.from_file('POSCAR') #This is reading file

params=dict(
    NPAR=4,
    EDIFFG=-0.01,
    ISMEAR=0,
    ISIF=7,
    ISYM=0,
    EDIFF=1E-5,
    LASPH='True',
    LREAL='Auto',
    LWAVE='FALSE',
    LCHARG='FALSE',
    IBRION=2,
    NELM=300,
    NSW=400,
    ALGO='Normal')

kparams=dict(reciprocal_density=100) #This is density of k-points. 100 is enough usually.

# you don't have to modify below this.
mpset = MPRelaxSet(structure)
#userset = MPRelaxSet(structure,user_incar_settings=params)
userset = MPRelaxSet(structure,user_incar_settings=params,user_kpoints_settings=kparams,user_potcar_functional="PBE_54")
#print(userset.incar)
#userset.write_input('.',include_cif=True)
userset.write_input('.')
