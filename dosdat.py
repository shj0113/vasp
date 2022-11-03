#!/usr/bin/env python3

##!/usr/local/bin/python3.5

import numpy as np
import numpy.linalg as linalg
import math

###############
# read_doscar #
###############
def read_doscar(filename):
	natom = 0
	emax = 0
	emin = 0
	nedos = 0
	efermi = 0
	weight = 0
	norbital = 0
	total = []
	tdos = []
	projected = []
	Projected = []
	pdos = []

	f = open(filename, 'r')

	doscar = f.read()
	doscar = doscar.splitlines()
	tmp = doscar[0]
	tmp = tmp.split()
	natom = int(tmp[0])
	tmp = doscar[5]
	tmp = tmp.split()
	emax = float(tmp[0])
	emin = float(tmp[1])
	nedos = int(tmp[2])
	efermi = float(tmp[3])
	weight = float(tmp[4])

#read TDOS
	tmp = doscar[6]
	tmp = tmp.split()
	spin = len(tmp)
	for i in range(6,nedos+6):
		tmp = doscar[i]
		tmp = tmp.split()
		for j in range(0,spin):
			tmp[j] = float(tmp[j])
			total.append(tmp[j])
		total[0] = total[0]-efermi
		tdos.append(total)
		total = []

#read PDOS
	index = nedos+7
	tmp = doscar[index]
	tmp = tmp.split()
	norbital = len(tmp)
	index = index-2
	for i in range(0,natom):
		index = index+1
		for j in range(0,nedos):
			index = index+1
			tmp = doscar[index]
			tmp = tmp.split()
			for k in range(0,norbital):
				tmp[k] = float(tmp[k])
				projected.append(tmp[k])
			projected[0] = projected[0]-efermi
			Projected.append(projected)
			projected = []
		Projected = np.asarray(Projected)
		pdos.append(Projected)
		Projected = []

#transform to array
	tdos = np.asarray(tdos)
	pdos = np.asarray(pdos)

	f.close()	

	return(natom, nedos, spin, norbital, tdos, pdos)

###############
# read_doscar #
###############
def write_dosdat(data, nedos, spin):
	fout = open("dos.dat", 'wt')

	if(spin == 3):
		for i in range(0,nedos):
			print('{0:>10.4f}{1:>25.16f}'.format(data[i][0], data[i][1]), file=fout)
	else:
		for i in range(0,nedos):
			print('{0:>10.4f}{1:>25.16f}{2:>25.16f}'.format(data[i][0], data[i][1], data[i][2]), file=fout)

	fout.close()

(natom, nedos, spin, norbital, tdos, pdos)=read_doscar("DOSCAR")

data = []

#print('\nTotal DOS = t // Projected DOS = p')
#tp = input('t or p: ')
tp = "p"

if(tp == "t"):
	if(spin == 3):
		print('\nnon-spin polarized calculation')
		for i in range(0,nedos):
			tmp = []
			tmp.append(tdos[i][0])
			tmp.append(tdos[i][1])
			data.append(tmp)
	else:
		print('\nspin polarized calculation')
		for i in range(0,nedos):
			tmp = []
			tmp.append(tdos[i][0])
			tmp.append(tdos[i][1])
			tmp.append(-tdos[i][2])
			data.append(tmp)

elif(tp == "p"):
#	print('\nselect atoms ('+str(natom)+' atoms in the system)')
#	first = int(input('first atom number: '))
	first = 1
#	last = int(input('last atom number: '))
	last = natom
	merged = []
	Data = []
	for i in range(0,nedos):
		tmp = []
		for j in range(1,norbital):
			up = 0
			up = float(up)
			for k in range(first-1,last):
				up = up+pdos[k][i][j]
			tmp.append(up)
		merged.append(tmp)
	merged = np.asarray(merged)
			
	case = 0
	while(case == 0):
#		print('\ntype of orbital (x orbital = x) [total = t]')
#		orbit = input('t or s or p or d or f: ')
		orbit = "t"
		if(orbit == "t"):
			case = 50
		elif(orbit == "s"):
			case = 1
		elif(orbit == "p"):
			case = 41
			while(case == 41):
				print('\ntotal = t // x = x // y = y // z = z (return = r)')
				porbit = input('t or x or y or z: ')
				if(porbit == "r"):
					case = 0
				elif(porbit == "t"):
					case = 51
				elif(porbit == "y"):
					case = 2
				elif(porbit == "z"):
					case = 3
				elif(porbit == "x"):
					case = 4
				else:
					case = 41
		elif(orbit == "d"):
			case = 42
			while(case == 42):
				print('\ntotal = t // xy = xy // yz = yz // z^2 = zz // zx = zx // x^2-y^2 = xx (return = r)')
				dorbit = input('t or xy or yz or zz or zx or xx: ')
				if(dorbit == "r"):
					case = 0
				elif(dorbit == "t"):
					case = 52
				elif(dorbit == "xy"):
					case = 5
				elif(dorbit == "yz"):
					case = 6
				elif(dorbit == "zz"):
					case = 7
				elif(dorbit == "zx"):
					case = 8
				elif(dorbit == "xx"):
					case = 9
				else:
					case = 42
		elif(orbit == "f"):
			case = 0
		else:
			case = 0

		if(spin == 3):
			print('\nnon-spin polarized calculation')
			if(case < 50):
				for i in range(0,nedos):
					Data.append(merged[i][case-1])
			elif(case == 50):
				for i in range(0,nedos):
					up = 0
					up = float(up)
					for j in range(0,norbital-1):
						up = up+merged[i][j]
					Data.append(up)
			elif(case == 51):
				for i in range(0,nedos):
					up = 0
					up = float(up)
					for j in range(1,4):
						up = up+merged[i][j]
					Data.append(up)
			elif(case == 52):
				for i in range(0,nedos):
					up = 0
					up = float(up)
					for j in range(4,9):
						up = up+merged[i][j]
					Data.append(up)
			else:
				pass

		else:
#			print('\nspin polarized calculation')
			Norbital = int((norbital-1)/2)
			if(case < 50):
				for i in range(0,nedos):
					mid = []
					mid.append(merged[i][2*case-2])
					mid.append(-merged[i][2*case-1])
					Data.append(mid)
			elif(case == 50):
				for i in range(0,nedos):
					up = 0
					dw = 0
					up = float(up)
					dw = float(dw)
					mid = []
					for j in range(0,Norbital):
						up = up+merged[i][2*j]
						dw = dw+merged[i][2*j+1]
					mid.append(up)
					mid.append(-dw)
					Data.append(mid)
			elif(case == 51):
				for i in range(0,nedos):
					up = 0
					dw = 0
					up = float(up)
					dw = float(dw)
					mid = []
					for j in range(1,4):
						up = up+merged[i][2*j]
						dw = dw+merged[i][2*j+1]
					mid.append(up)
					mid.append(-dw)
					Data.append(mid)
			elif(case == 52):
				for i in range(0,nedos):
					up = 0
					dw = 0
					up = float(up)
					dw = float(dw)
					mid = []
					for j in range(4,9):
						up = up+merged[i][2*j]
						dw = dw+merged[i][2*j+1]
					mid.append(up)
					mid.append(-dw)
					Data.append(mid)
			else:
				pass
			Data = np.asarray(Data)

	for i in range(0,nedos):
		tmp = []
		tmp.append(pdos[0][i][0])
		if(spin == 3):
			tmp.append(Data[i])
		else:
			tmp.append(Data[i][0])
			tmp.append(Data[i][1])
		data.append(tmp)

else:
	print('\n----------------------------')
	print('>>>  incorrect variable  <<<')
	print('----------------------------')

data = np.asarray(data)

#write_dosdat(data, nedos, spin)
#print(data)

#print('\nFinished')
