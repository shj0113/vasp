#!/usr/bin/env python3
import sys
import string
import argparse
from pymatgen.core.structure import Structure, Lattice

parser=argparse.ArgumentParser()

if len(sys.argv)==1:
    filename='CONTCAR'
    print('this lattice is from CONTCAR')
else:
    filename=sys.argv[1]
    #  if not filename.startswith(('POSCAR','CONTCAR')):
        #  print("warning: the filename should be POSCAR.xx or CONTCAR.xx")

structure=Structure.from_file(filename)
#print(structure.lattice)
#print("abc    =  [{0:.3f}, {1:.3f}, {2:.3f}".format(structure.lattice.abc))
print("abc    =  [ {a:.3f}  ,  {b:.3f}  ,  {c:.3f} ]" .format(a=structure.lattice.abc[0],b=structure.lattice.abc[1],c=structure.lattice.abc[2]))
print("angles =  [ {a:.3f}  ,  {b:.3f}  ,  {c:.3f} ]".format(a=structure.lattice.angles[0],b=structure.lattice.angles[1],c=structure.lattice.angles[2]))
print(structure.volume)

