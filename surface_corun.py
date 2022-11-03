#!/usr/bin/env python
from pymatgen import Structure, Lattice,MPRester
from pymatgen.core.surface import Slab, SlabGenerator, generate_all_slabs
from pymatgen.symmetry.analyzer import SpacegroupAnalyzer


mpr = MPRester('Rw9SXoXqU8sgRx9v')
#struct = Structure.from_file("POSCAR.bulk")
#structure = mpr.get_structure_by_material_id("mp-7048",conventional_unit_cell=True) # MONO al2o3
#structure = mpr.get_structure_by_material_id("mp-886",conventional_unit_cell=True) # MONO ga2o3
#structure = mpr.get_structure_by_material_id("mp-1143",conventional_unit_cell=True) # CORUN al2o3
#structure = mpr.get_structure_by_material_id("mp-1243",conventional_unit_cell=True) # CORUN ga2o3
#    slab = slab_dict[(1,0,0)]
#sgen = SlabGenerator(structure, [1,0,0] ,15 ,20,primitive=False,max_normal_search=1)

#with MPRester() as mpr:
# struct = mpr.get_structure_by_material_id("mp-886") # mono ga2o3
# struct = mpr.get_structure_by_material_id("mp-7048") # mono al2o3
#struct = mpr.get_structure_by_material_id("mp-1143") # corun al2o3
struct = mpr.get_structure_by_material_id("mp-1243") # corun ga2o3

struct = SpacegroupAnalyzer(struct).get_conventional_standard_structure() # get conventional cell from primitive cell
#b = struct.get_sorted_structure()
# b.to(filename="POSCAR.bulk")
slabs = generate_all_slabs(struct, 1, 17.0, 20.0, primitive=False,max_normal_search=1)
#slabs = generate_all_slabs(struct, 1, 15.0, 20.0, primitive=False,max_normal_search=1,center_slab=True)
slab_dict = {slab.miller_index:slab for slab in slabs}

 # ni_slab_111 = slab_dict[(1, 1, 1)]
c = slab_dict[(1, 1, 0)]
d = c.get_orthogonal_c_slab()
d.to(filename="POSCAR.all")
