#!/usr/bin/env python3
import sys
import string
from pymatgen.core.structure import Structure
#from pymatgen.core.lattice import Lattice
from pymatgen.io.vasp.inputs import Incar, Kpoints
from pymatgen.io.vasp.sets import MPRelaxSet, VaspInputSet

structure=Structure.from_file('POSCAR') #This is reading file

params=dict(
    ALGO='Normal',
    EDIFF=1e-05,
    EDIFFG=-0.01,
    ENCUT=500,
    IBRION=2,
    ISIF=3,
    ISMEAR=0,
    ISPIN = 1,
    ISYM=0,
    LASPH='FALSE',
    LCHARG='FALSE',
    LREAL='Auto',
    LWAVE='FALSE',
    NELM=300,
    NPAR=4,
    NSW=400,
    SIGMA = 0.05)

kparams=dict(reciprocal_density=100) #This is density of k-points. 100 is enough usually.

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
