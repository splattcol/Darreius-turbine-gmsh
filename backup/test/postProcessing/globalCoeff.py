#!/usr/bin/python

import os
import sys
import math

blades  = 3
omega   = 52.57
Uinf    = 2.8
radio   = .175/2
Aref    = 2*radio*.005
rho     = 1000
files   = {}
Datas   = {}

def getData (fileN):
	aData = {}
	cont = 0
	with open(fileN,'r') as datafile:
		for line in datafile:
			tokens = line.split()
			floats = [float(x) for x in tokens]
			aData[('time',cont)]= floats[0]
			aData[('angle',cont)]=floats[1]
			aData[('Fd',cont)] = floats[2]
			aData[('Fl',cont)] = floats[3]
			aData[('m',cont)] = floats[4]
			cont +=1
		datafile.close()
		return aData

def lengthData ():
	cont=0
	with open("forces_1.txt","r") as datafile:
		for line in datafile:
			cont+=1
	return cont
	
for i in range(blades):
	i_str  = str(i+1)
	name = "forces_"+i_str+".txt"

	if not os.path.isfile(name):
		print "Coeffs file not found at "+name
		print "Be sure that the case has been run and you have the right directory!"
		print "Exiting."
		sys.exit()
	Datas[i]=getData(name)

time = []
angle= []
Cm   = []
Cd   = []
Cl   = []
Cp   = []

outputfile = open('globalCoeffs.txt','w')
for j in range(0,lengthData()):
	CmT = 0
	CdT = 0
	ClT = 0
	CpT = 0
	for k in range(blades):
		CmT+=Datas[k][('m',j)]/(.5*rho*Uinf**2*Aref*radio)
		CdT+=Datas[k][('Fd',j)]/(.5*rho*Uinf**2*Aref)
		ClT+=Datas[k][('Fl',j)]/(.5*rho*Uinf**2*Aref)
		CpT+=Datas[k][('m',j)]*omega/(.5*rho*Uinf**3*Aref)
	time += [Datas[0][('time',j)]]
	angle+=[Datas[0][('angle',j)]]
	Cm += [CmT]
	Cd += [CdT]
	Cl += [ClT]
	Cp += [CpT]
	
	outputfile.write(str(time[j])+' '+str(angle[j])+' '+str(Cm[j])+' '+str(Cd[j])+' '+str(Cl[j])+' '+str(Cp[j])+'\n')	

outputfile.close()

