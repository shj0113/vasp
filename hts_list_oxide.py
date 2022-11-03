#!/usr/bin/env python

from matminer.data_retrieval.retrieve_MP import MPDataRetrieval
import numpy as np
mpdr = MPDataRetrieval(api_key='nQq8zJxtOpVsPgFk')


import os
import sys

cation = input("Cation : ")

criteria = {"elements":{"$in":[cation],"$all":["O"]},
            "nelements":2,
           }

properties = ['pretty_formula','spacegroup.symbol',"icsd_ids"]
df = mpdr.get_dataframe(criteria,properties)
#df_icsd = df['icsd_ids'] == 0
df = df.astype({'icsd_ids':'str'})
df = df[df['icsd_ids'] != '[]']
print("# of data: {}".format(len(df)))
df.to_csv("List.txt", header=None,sep=",")
