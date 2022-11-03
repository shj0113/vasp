#!/usr/bin/env python
from pymatgen import Structure, Lattice,MPRester
from pymatgen import MPRester
import os
import sys

number = input("mateiral id number, mp-xxxx : ")
#number = 'mp-' + number

from pymatgen import Structure

mpr = MPRester('Rw9SXoXqU8sgRx9v')
with MPRester() as mpr:
 struct = mpr.get_structure_by_material_id(number,True,True) # mono ga2o3

struct.to(filename="POSCAR")
