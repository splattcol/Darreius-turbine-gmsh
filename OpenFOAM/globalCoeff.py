#!/usr/bin/python

import os
import sys
import math

blades = 3
files = {}
Datas = {}

def getData (fileN):
	aData = {}
	cont = 0
	with open(fileN,'r') as datafile:
		for line in datafile:
			tokens = line.split()
			floats = [float(x) for x in tokens]
			aData[('time',cont)]= floats[0]
			aData[('angle',cont)]=floats[1]
			aData[('Cm',cont)] = floats[2]
			aData[('Cd',cont)] = floats[3]
			aData[('Cl',cont)] = floats[4]
			aData[('Cp',cont)] = floats[5]
			cont +=1
		datafile.close()
		return aData

def lengthData ():
	cont=0
	with open("AirFoil_1_Coeffs.txt","r") as datafile:
		for line in datafile:
			cont+=1
	return cont
	
for i in range(blades):
	i_str  = str(i+1)
	name = "AirFoil_"+i_str+"_Coeffs.txt"

	if not os.path.isfile(name):
		print "Coeffs file not found at "+Coeffs_file
		print "Be sure that the case has been run and you have the right directory!"
		print "Exiting."
		sys.exit()
	Datas[i]=getData(name)

time = []
angle= []
Cd   = []
Cl   = []
Cm   = []
Cp   = []

outputfile = open('globalCoeffs.txt','w')
for j in range(0,lengthData()):
	CmT = 0
	CdT = 0
	ClT = 0
	CpT = 0
	for k in range(blades):
		CmT+=Datas[k][('Cm',j)]
		CdT+=Datas[k][('Cd',j)]
		ClT+=Datas[k][('Cl',j)]
		CpT+=Datas[k][('Cp',j)]
	time += [Datas[0][('time',j)]]
	angle+=[Datas[0][('angle',j)]]
	Cm += [CmT]
	Cd += [CdT]
	Cl += [ClT]
	Cp += [CpT]
	
	outputfile.write(str(time[j])+' '+str(angle[j])+' '+str(Cm[j])+' '+str(Cd[j])+' '+str(Cl[j])+' '+str(Cp[j])+'\n')	

outputfile.close()

