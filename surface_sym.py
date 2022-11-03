#!/usr/bin/env python
from pymatgen import Structure, Lattice
from pymatgen.core.surface import Slab, SlabGenerator,generate_all_slabs

structure = Structure.from_file("CONTCAR")
#sgen = SlabGenerator(structure, [-2,0,1] ,1 ,0,primitive=False,max_normal_search=1)
#sgen = SlabGenerator(structure, [1,0,1] ,12 ,20,primitive=False,max_normal_search=1)
#slabs = generate_all_slabs(structure,1,12,20,primitive=False,max_normal_search=1,symmetrize=True)
slabs = generate_all_slabs(structure,1,12,20,primitive=False,max_normal_search=1)
slab_dict = {slab.miller_index:slab for slab in slabs}

a = slab_dict[(1, 1, 1)]


#sgen = SlabGenerator(structure, [0,0,1] ,12 ,20,primitive=False)
#a = sgen.get_slab()
print(a.is_polar(),a.is_symmetric())
c = a.get_sorted_structure()
#c.to(filename="POSCAR.non-ortho")
d = c.get_orthogonal_c_slab()
d.to(filename="POSCAR.ortho")

