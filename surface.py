#!/usr/bin/env python
from pymatgen import Structure, Lattice,MPRester
from pymatgen.core.surface import Slab, SlabGenerator


mpr = MPRester('Rw9SXoXqU8sgRx9v')
structure = Structure.from_file("POSCAR.bulk")
#structure = Structure.from_file("CONTCAR")
#structure = mpr.get_structure_by_material_id("mp-7048",conventional_unit_cell=True) # MONO al2o3
#structure = mpr.get_structure_by_material_id("mp-886",conventional_unit_cell=True) # MONO ga2o3
#structure = mpr.get_structure_by_material_id("mp-1143",conventional_unit_cell=True) # CORUN al2o3
#structure = mpr.get_structure_by_material_id("mp-1243",conventional_unit_cell=True) # CORUN ga2o3
#    slab = slab_dict[(1,0,0)]

#sgen = SlabGenerator(structure, [-2,0,1] ,1, 0,primitive=False,max_normal_search=1) # CORUN
#sgen = SlabGenerator(structure, [1,1,1] ,12 ,20,primitive=False,max_normal_search=1) # CORUN
#SlabGenerator(initial_structure, miller_index, min_slab_size, min_vacuum_size, lll_reduce=False, center_slab=False, in_unit_planes=False, primitive=True, max_normal_search=None, reorient_lattice=True)[source]
sgen = SlabGenerator(structure, [0,1,0] ,1 ,1,primitive=False,max_normal_search=1) # MONO
a = sgen.get_slab()
print(a.is_polar(),a.is_symmetric())
c = a.get_sorted_structure()
#print(c)
#c.to(filename="POSCAR.non-ortho")
d = c.get_orthogonal_c_slab()
#print(d)
d.to(filename="POSCAR.ortho")
