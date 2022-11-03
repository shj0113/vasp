#!/usr/bin/env python
import random
import numpy as np
import math

# specify params
domain = "Si"
dopant = "Li"
total_num = 100 
doping_num = 10
mindist = 2 
volume = [12.69, 12.69, 12.69] # [a, b, c]

def genpt():
    x = random.uniform(mindist/2, volume[0]-mindist/2) # periodic boundary condition 때문에 mindist/2 추가
    y = random.uniform(mindist/2, volume[1]-mindist/2)
    z = random.uniform(mindist/2, volume[2]-mindist/2)
    newp = np.array([x, y, z])
    return newp

def distance(p1,p2):
    squared_dist = np.sum((p1-p2)**2, axis=0)
    dist = np.sqrt(squared_dist)
    return dist

sample = []
while len(sample) < total_num:
    newp = genpt()
    for p in sample:
        if distance(newp,p) < mindist:
            break
    else:
        sample.append(newp)


f = open("POSCAR", 'w')

f.write(domain + str(total_num-doping_num) + " " + dopant + str(doping_num) + "\n")
f.write("1.0")
f.write("\n       " + "%-20s %-20s %-20s" % (str(volume[0]), "0.0000000000", "0.0000000000"))
f.write("\n       " + "%-20s %-20s %-20s" % ("0.0000000000", str(volume[1]), "0.0000000000"))
f.write("\n       " + "%-20s %-20s %-20s" % ("0.0000000000", "0.0000000000", str(volume[2])))
f.write("\n   " + domain + "   " + dopant)
f.write("\n   " + str(total_num-doping_num) + "   " + str(doping_num))
f.write("\nCartesian")
for i in range(len(sample)):
    f.write("\n     " + "%-20s %-20s %-20s" % (sample[i][0], sample[i][1], sample[i][2]))

f.close()

