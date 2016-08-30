#!/usr/bin/python
import os
import sys
import fileinput

boundaryFile = './constant/polyMesh/boundary'

f = open ( boundaryFile, 'r')
lines = f.readlines()
f.close()
f = open (boundaryFile, 'w')
boo = False
for line in lines:
    if 'AMI-St' in line:
        strTemp = 'AMI-Rt'
    elif 'AMI-Rt' in line:
        strTemp = 'AMI-St'
    if boo:
        tempStr = 'neighbourPatch '+ strTemp+ ';\n matchTolerance 1e-4; \n transform noOrdering;\n'
        f.write(tempStr)
        boo = False
    if 'cyclicAMI' in line:
        boo = True
    f.write(line)
    
        
f.close()

