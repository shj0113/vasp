#!/usr/bin/env python3
import os
import sys

number = input("a value for ax,ay axis : ")

from pymatgen import Structure
a = Structure.from_file('POSCAR')
matrix = [number,number,1]
a.make_supercell(matrix)
a.to(filename='POSCAR.super')
