#!/usr/bin/env python

from pymatgen.io.vasp import Vasprun, BSVasprun
from pymatgen.electronic_structure.plotter import BSPlotter

v = BSVasprun("vasprun.xml")
bs = v.get_band_structure(kpoints_filename="KPOINTS",line_mode=True)
plt = BSPlotter(bs)
plt.get_plot(vbm_cbm_marker=True)
plt.show()

