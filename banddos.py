#!/usr/bin/env python
import matplotlib.pyplot as plt
from pymatgen.electronic_structure.plotter import *
from pymatgen.io.vasp import Vasprun, BSVasprun

dosrun = Vasprun("vasprun.xml", parse_dos=True)
dos=dosrun.complete_dos

run = BSVasprun("vasprun.xml", parse_projected_eigen=True)
bs = run.get_band_structure("KPOINTS", efermi=dos.efermi)

bsdos = BSDOSPlotter(bs_projection="elements", dos_projection="elements", egrid_interval=1)
plt=bsdos.get_plot(bs,dos=dos)
plt.show()
