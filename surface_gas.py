#!/usr/bin/env python
from pymatgen import Structure, Lattice,MPRester
#from pymatgen.io.ase import AseAtomAdaptor
from pymatgen.symmetry.analyzer import SpacegroupAnalyzer
from pymatgen.core.surface import Slab, SlabGenerator


mpr = MPRester('Rw9SXoXqU8sgRx9v')
struct = Structure.from_file("POSCAR.bulk")

min_slab=12
#struct = AseAtomAdaptor.get_structure(structure)
sga = SpacegroupAnalyzer(struct, symprec=0.1)
struct_stdrd = sga.get_conventional_standard_structure()
slab_gen = SlabGenerator(initial_structure=struct_stdrd, miller_index=[1,0,0], min_slab_size=min_slab, min_vacuum_size=20, primitive=False, max_normal_search=1)
a = slab_gen.get_slab()
c = a.get_sorted_structure()
#c.to(filename="POSCAR.non-ortho")
d = c.get_orthogonal_c_slab()
#print(d)
d.to(filename="POSCAR.ortho")



#structure = Structure.from_file("CONTCAR")
#structure = mpr.get_structure_by_material_id("mp-7048",conventional_unit_cell=True) # MONO al2o3
#structure = mpr.get_structure_by_material_id("mp-886",conventional_unit_cell=True) # MONO ga2o3
#structure = mpr.get_structure_by_material_id("mp-1143",conventional_unit_cell=True) # CORUN al2o3
#structure = mpr.get_structure_by_material_id("mp-1243",conventional_unit_cell=True) # CORUN ga2o3
#    slab = slab_dict[(1,0,0)]

#sgen = SlabGenerator(structure, [0,0,1] ,15 ,20,primitive=False,max_normal_search=1) # CORUN
#sgen = SlabGenerator(structure, [1,0,0] ,15 ,20,primitive=False,max_normal_search=1,center_slab=True) # CORUN
#sgen = SlabGenerator(structure, [0,1,0] ,15 ,20,primitive=False,max_normal_search=1) # MONO
#a = sgen.get_slab()
#c = a.get_sorted_structure()
#print(c)
#c.to(filename="POSCAR.non-ortho")
#d = c.get_orthogonal_c_slab()
#print(d)
#d.to(filename="POSCAR.ortho")


