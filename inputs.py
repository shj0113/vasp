#!/usr/bin/env python3
import sys
import string
from pymatgen import Structure, Lattice
from pymatgen.io.vasp.inputs import Incar
from pymatgen.io.vasp.sets import MPRelaxSet, VaspInputSet, MPStaticSet

#assert len(sys.argv)==1, "input POSCAR is required"

if len(sys.argv)==1:
    filename='POSCAR'
else:
    filename=sys.argv[1]

if not filename.startswith(('POSCAR','CONTCAR')):
    print("warning: the filename should be POSCAR.xx or CONTCAR.xx")

structure=Structure.from_file(filename)

params=dict(NSW=0, ENCUT=400, EDIFFG=-0.01, EDIFF=1E-6, NPAR=4, SIGMA=0.1, NEDOS=3000)
#params=dict(NSW=0, EDIFFG=-0.01, EDIFF=1E-5, KPAR=4, NCORE=3, LREAL='.FALSE.', ISIF=2, ENCUT=300,ISMEAR=1,SIGMA=0.2)  #for instance Mo relaxation
mpset = MPStaticSet(structure)
userset = MPStaticSet(structure,user_incar_settings=params)
#print(userset.incar)
#userset.write_input('.',include_cif=True)
userset.write_input('.')
