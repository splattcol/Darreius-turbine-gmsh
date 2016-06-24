#!/usr/bin/python

import os
import sys
import math

Coeffs_file = "forceCoeffs.dat"

if not os.path.isfile(Coeffs_file):
	print "Coeffs file not found at "+Coeffs_file
	print "Be sure that the case has been run and you have the right directory!"
	print "Exiting."
	sys.exit()

def line2dict(line):
	tokens_unprocessed = line.split()
	tokens = [x.replace(")","").replace("(","") for x in tokens_unprocessed]
	floats = [float(x) for x in tokens]
	coeffs_dict = {}
	coeffs_dict['time'] = floats[0]
	coeffs_dict['Cm'] = floats[1]
	coeffs_dict['Cx'] = floats[2]
	coeffs_dict['Cy'] = floats[3]

	return coeffs_dict

time = []
Cd=[]
Cl=[]
Cm = []
angle=[]
with open(Coeffs_file,"r") as datafile:
	for line in datafile:
		if line[0] == "#":
			continue
		coeffs_dict = line2dict(line)
		alpha = float(52.57*coeffs_dict['time'])
		angle+= [alpha]
		time += [coeffs_dict['time']]
		Cd   += [math.sin(alpha)*coeffs_dict['Cx'][0] +math.cos(alpha)*coeffs_dict['Cy'][0]]
		Cl   += [math.cos(alpha)*coeffs_dict['Cx'][0] +math.sin(alpha)*coeffs_dict['Cy'][0]]
		Cm += [coeffs_dict['Cm'][0]

datafile.close()

outputfile = open('forces.txt','w')
for i in range(0,len(time)):
	outputfile.write(str(time[i])+' '+str(angle[i])+' '+str(Cm[i])+' '+str(Cd[i])+' '+str(Cl[i])+'\n')
outputfile.close()

os.system("./plotForces.sh")  

