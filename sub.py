#!/usr/bin/env python3
import os
import sys

number = input("atom number to be replaced: ")
num = int(number)-1
from pymatgen import Structure
a = Structure.from_file('POSCAR.super')
a.replace(num,'C')
a.to(filename='POSCAR')
