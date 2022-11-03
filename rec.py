from pymatgen import Structure

a = Structure.from_file('POSCAR')
matrix = [[2,0,0],[0,2,0],[0,0,2]]
a.make_supercell(matrix)
a.to(filename='POSCAR.rec')
