#!/usr/bin/python3
print('Importing libraries... ', end='')
import numpy as np
import matplotlib.pyplot as plt
#import scipy.integrate as integrate
from scipy.interpolate import interp1d



#################### 1. Read data from DOSCAR and make an array: E_b4, D_b4 ####################
print('Done!\nExtracting data from DOSCAR using dosdat.py... ', end='')
from dosdat import *
# dosdat output to be used: natom, nedos, data[i][j]    0 ≤ i ≤ nedos-1, 0 ≤ j ≤ 2
# data[i][j]: 2D array of 'numpy.float64' type data
#
# output example
# nedos = 3001
# data =
# [[-11.85892095   0.          -0.        ]
#  [-11.82492095   0.          -0.        ]
#  [-11.79092095   0.          -0.        ]
#  ...
#  [  5.18607905   0.          -0.        ]
#  [  5.22007905   0.          -0.        ]
#  [  5.25407905   0.          -0.        ]]

E_b4 = []
D_b4 = []
for i in range(0,nedos-1):	# e.g. nedos = 3001
	E_b4.append(data[i][0])
	D_b4.append(data[i][1])

print('Done!\n\n {0} atoms in the system'.format(natom))
print(' nedos = {0}'.format(nedos))
#print('DOS data:')
#print(data+'\n')



#################### 2. Make linear space of E and interpolate DOS function ####################
print('\nMaking E space... ', end='')
lowbound_E = np.floor(data[2][0]*1000)/1000    # e.g. lowbound_E = -11.791 eV
upbound_E = np.ceil(data[-3][0]*1000)/1000    # e.g. upbound_E = 5.187 eV
dE = 0.001    # e.g. dE = 0.001 eV = 1 meV
E = np.linspace(lowbound_E, upbound_E, num=(upbound_E-lowbound_E)/dE+1, endpoint=True)
# e.g. E = [-11.791, -11.79, -11.789, ..., 5.185, 5.186, 5.187] eV
#print(E)
print('Done!\n\n  E = [{0:>6.3f}, {1:>6.3f}, {2:>6.3f}, ..., {3:>6.3f}, {4:>6.3f}, {5:>6.3f}] eV\n dE = {6:>5.3f} eV'.format(lowbound_E, lowbound_E+dE, lowbound_E+2*dE, upbound_E-2*dE, upbound_E-dE, upbound_E, dE))

print('\nInterpolating DOS function. This may take a while... ', end='')
D = interp1d(E_b4, D_b4, kind='cubic') # interpolate DOS function

### plot DOS ###
#plt.xlim([-3,3])    # x axis range
#plt.ylim([0,20])     # y axis range
#plt.plot(E_b4, D_b4, '-', E, D(E), '-')
#plt.plot(E_b4, D_b4, '-')
#plt.legend(['data', 'cubic'], loc='best')
#plt.show()



#################### 3. Define constants and Fermi-Dirac distribution function  ####################
e = 1.602176634e-19    # elementary charge, using 2019 redefinition by CGPM
# = 1.602176634e-19 C
k_B = (1.380649e-23) / (e)    # Boltzmann constant, using 2019 redefinition by CGPM
  # = (1.380649e-23 J/K) / (1.602176634e-19 J/eV)
  # ≒ 8.6173332621451774e-05 eV/K

ax = 9.82399900000000000    # x-component of the a-vector of the supercell
# e.g. ax = 15.4737147354903009 Å
by = 8.50783300000000000    # y-component of the b-vector of the supercell
# e.g. by = 13.4006300518482000 Å

T = 300
# = 300 K
def f(x):    # define Fermi-Dirac distribution function
	return 1/(1 + np.exp( (x)/(k_B*T) ))



#################### 4. Make linear space of φ and compute integration ####################
print('Done!\nMaking φ(local potential) space... ', end='')
lowbound_phi = -0.600    # e.g. lowbound_phi = -0.6 V
upbound_phi = 0.600    # e.g. upbound_phi = 0.9 V
dphi = 0.03    # e.g. dphi = dφ = 0.03 V
local_potential = np.linspace(lowbound_phi, upbound_phi, num=(upbound_phi-lowbound_phi)/dphi+1, endpoint=True)
# e.g. local_potential = [-0.6, -0.57, -0.54, ..., 0.84, 0.87, 0.9] V
#print(local_potential)
print('Done!\n\n  φ = [{0:>6.3f}, {1:>6.3f}, {2:>6.3f}, ..., {3:>6.3f}, {4:>6.3f}, {5:>6.3f}] V\n dφ = {6:>5.3f} V'.format(lowbound_phi, lowbound_phi+dphi, lowbound_phi+2*dphi, upbound_phi-2*dphi, upbound_phi-dphi, upbound_phi, dphi))

print('\nIntegration now...\n')
print("   φ(V)    ΔQ(μC/cm^2)   C_Q(μF/cm^2)")
####### -0.480 -10.0289465392  12.2822325891
#######E=-12.63
for phi in local_potential:
	sum_Q = 0.0
	sum_C = 0.0
	for i in E:
	#E+eφ = (i eV) + (1.602176634e-19 C)*(phi V) = i eV + (1.602176634e-19)*phi J
	#     = i eV + ((1.602176634e-19)*phi J)*(eV/(1.602176634e-19 J)) = i eV + phi eV = (i+phi) eV
		product_Q = D(i)*( f(i) - f(i + phi) )*dE
		sum_Q += product_Q
		product_C = D(i)*( ( 1/np.cosh((i + phi)/(2*k_B*T)) )**2 )*dE
		sum_C += product_C
		print('E = {0:>6.3f}'.format(i), end='\r')
	sum_Q *= e    # [sum_Q] = C / cell
	sum_Q *= 1/(ax*by)    # [sum_Q] = C / Å^2
	sum_Q *= 1e20    # [sum_Q] = C / m^2
	sum_Q *= 1e2    # [sum_Q] = μC / cm^2

	sum_C *= (e**2)/(4*k_B*T)    # [sum_C] = C^2 / eV * cell
	sum_C *= 1/(ax*by)    # [sum_C] = C^2 / eV * Å^2
	sum_C *= (1e20)/(e)    # [sum_C] = F / m^2
	sum_C *= 1e2    # [sum_C] = μF / cm^2
	print(' {0:>6.3f} {1:>14.10f} {2:>14.10f}'.format(phi, sum_Q, sum_C))



print("Calculation Complete!!")



