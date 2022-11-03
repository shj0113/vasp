#!/usr/bin/env python
#from pymatgen.electronic_structure.boltztrap2 import *
from monty.serialization import loadfn
from pymatgen.io.vasp import Vasprun, BSVasprun
from monty.serialization import dumpfn
from pymatgen.electronic_structure.plotter import BSPlotter, DosPlotter
import matplotlib.pyplot as plt


#vr = Vasprun("vasprun.xml")
#bs = vr.get_band_structure()
#dumpfn(bs, "bs.json")
#bs = loadfn('bs.json')
#vrun = Vasprun('vasprun.xml',parse_projected_eigen=True)
#data = VasprunBSLoader(vrun)
#bs = vrun.get_band_structure()
#nele = vrun.parameters['NELECT']
#st = vrun.final_structure
#data = VasprunBSLoader(bs,structure=st,nelect=nele)
#data = VasprunBSLoader.from_file('vasprun.xml')

#bztInterp = BztInterpolator(data,lpfac=10,energy_range=6,curvature=True)

#sbs = bztInterp.get_band_structure()

#bsplot = BSPlotter(sbs)
#bsplot.get_plot(vbm_cbm_marker=True,ylim=(-1,6))

#bsplot.show()

v = Vasprun('vasprun.xml')
#tdos = v.tdos
cdos = v.complete_dos
element_dos = cdos.get_element_dos()
plotter = DosPlotter(sigma=0.05)
#plotter.add_dos("Total DOS", tdos)
plotter.add_dos_dict(element_dos)
plotter.show(xlim=[-5,5])
plotter.show(xlim=[-15,15])

