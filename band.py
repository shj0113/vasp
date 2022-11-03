#!/usr/bin/env python3

import sys
import numpy as np
import os

#  from pymatgen.io.vasp.inputs import Kpoints
from pymatgen.io.vasp.outputs import Vasprun, Outcar, BSVasprun
#  from pymatgen.symmetry.bandstructure import HighSymmKpath
#  from pymatgen.electronic_structure.core import Spin, Orbital
from pymatgen.electronic_structure.bandstructure import BandStructure
from pymatgen.electronic_structure.plotter import BSPlotter, BSDOSPlotter
import pymatgen as pmg
import matplotlib.pyplot as plt



if __name__ == "__main__":
    #read data
    #  path = HighSymmKpath(pmg.Structure.from_file("CONTCAR"))
    #  kpath = Kpoints.from_file("KPOINTS")
    #  labels = [r"$%s$" % lab for lab in path[0][0:4]]
    #  print(path.kpath)
    #  print(path.prim_rec)
    xml = Vasprun('vasprun.xml')
    band=xml.get_band_structure()
    eg=band.get_band_gap()
    deg=band.get_direct_band_gap()
    print("bandgap= \n",eg)
    #  print("direct bandgap= \n",deg)
    bsp_object=BSPlotter(band)
    data=bsp_object.bs_plot_data
    print(data)
    ax=bsp_object.get_plot()
    plt.show()


    
    #  print(xml.finalenergy())
