#!/usr/bin/env python
from pymatgen.core.surface import Slab, SlabGenerator
from pymatgen import Structure, Lattice, MPRester, Molecule
from pymatgen.core.surface import generate_all_slabs
from pymatgen.analysis.adsorption import *
from pymatgen.symmetry.analyzer import SpacegroupAnalyzer
from matplotlib import pyplot as plt
from atomate.vasp.config import VASP_CMD, DB_FILE

from fireworks import LaunchPad
lpad = LaunchPad.auto_load()

from atomate.vasp.workflows.base.adsorption import get_wf_slab

#mpr = MPRester('Rw9SXoXqU8sgRx9v')
with MPRester() as mpr:
# struct = mpr.get_structure_by_material_id("mp-886") # mono ga2o3
# struct = mpr.get_structure_by_material_id("mp-7048") # mono al2o3
# struct = mpr.get_structure_by_material_id("mp-1143") # corun al2o3
 struct = mpr.get_structure_by_material_id("mp-1243") # corun ga2o3

struct = SpacegroupAnalyzer(struct).get_conventional_standard_structure() # get conventional cell from primitive cell
b = struct.get_sorted_structure()
b.to(filename="POSCAR.bulk")
slabs = generate_all_slabs(struct, 1, 15.0, 20.0, primitive=False,max_normal_search=1)
slab_dict = {slab.miller_index:slab for slab in slabs}

# ni_slab_111 = slab_dict[(1, 1, 1)]
c = slab_dict[(1, 0, 0)]
d = c.get_orthogonal_c_slab()
#d.to(filename="POSCAR.ortho")
wf = get_wf_slab(d, vasp_cmd=VASP_CMD, db_file=DB_FILE)

lpad = LaunchPad.auto_load()
lpad.add_wf(wf)
