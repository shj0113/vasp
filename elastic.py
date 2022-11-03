#!/usr/bin/env python3
import sys
import string
from pymatgen.io.vasp.outputs import Outcar
from pymatgen.analysis.elasticity.elastic import ElasticTensor

#for i in ["sr0.0", "sr0.25", "sr0.5", "sr0.75", "sr1.0"]
#do
#	cd $i 	
outcar=Outcar("OUTCAR")
et_table=outcar.read_elastic_tensor()

#elastic_matrix = outcar.elastic_tensor
print(et_table)


#tensor = ElasticTensor(elastic_matrix) 
#print(k_voigt)
#cd ..
#done 
