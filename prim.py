#!/usr/bin/env python3

from pymatgen.symmetry.analyzer import PointGroupAnalyzer, SpacegroupAnalyzer
from pymatgen.symmetry.bandstructure import HighSymmKpath
from pymatgen.core.structure import Structure, Lattice
from pymatgen.io.vasp.inputs import Kpoints

import sys
import string
import argparse


#!/usr/bin/env python3

parser=argparse.ArgumentParser()

if len(sys.argv)==1:
    filename='POSCAR'
    print('this lattice is from POSCAR')
else:
    filename=sys.argv[1]
    #if not filename.startswith(('POSCAR','CONTCAR')):
       #print("warning: the filename should be POSCAR.xx or CONTCAR.xx")

structure=Structure.from_file(filename)
#sga=SpacegroupAnalyzer(structure)
#prim_cell=sga.get_primitive_standard_structure()
#prim_cell.to(fmt='POSCAR',filename='POSCAR.prim1')

a=HighSymmKpath(structure)
prim_cell=a.prim
prim_cell.to(fmt='POSCAR',filename='POSCAR.prim')
conv_cell=a.conventional
conv_cell.to(fmt='POSCAR',filename='POSCAR.conv')
kpts=Kpoints.automatic_linemode(10,a)
kpts.write_file('KPOINTS.prim')
#print(a.get_kpoints())
