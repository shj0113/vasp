from pymatgen.core.structure import Structure

structure = Structure.from_file("POSCAR")

num_of_atoms = len(list(structure))
dist = []
for i in range(num_of_atoms):
    for j in range(num_of_atoms):
        distance = structure.get_distance(i,j)
        if distance == 0.0:
            break
        else:
            dist.append(distance)

print(min(dist))
