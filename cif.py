#!/usr/bin/env python3
import sys
import string
import argparse
from pymatgen import Structure, Lattice
from pymatgen.io.cif import CifWriter

parser=argparse.ArgumentParser()

if len(sys.argv)==1:
    filename='CONTCAR'
    print('this lattice is from CONTCAR')
else:
	filename=sys.argv[1]
	if not filename.startswith(('POSCAR','CONTCAR')):
		print("warning: the filename should be POSCAR.xx or CONTCAR.xx")

structure=Structure.from_file(filename)
nfn=filename+'.cif'
a=CifWriter(structure,symprec=0.01)
a.write_file(nfn)
#structure.to(filename=nfn,fmt='cif')
