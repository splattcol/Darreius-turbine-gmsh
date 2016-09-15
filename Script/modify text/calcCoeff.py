#!/usr/bin/python

import os
import sys
import math


blades = 3

r = 0.175/2 # radio
w = 52.57   # rotational vel (rad/s)
v = 2.8     # inlet vel (m/s)
l = r*w/v   # tip speed ratio

for i in range(blades):
	i_str = str(i+1);
	Coeffs_file = "AirFoil_"+i_str+"/0/forceCoeffs.dat"
	A_dict = {}
	
	
	if not os.path.isfile(Coeffs_file):
		print "Coeffs file not found at "+Coeffs_file
		print "Be sure that the case has been run and you have the right directory!"
		print "Exiting."
		sys.exit()	
	

	def line2dict(line):
		tokens_unprocessed = line.split()
		tokens = [x.replace(")","").replace("(","") for x in tokens_unprocessed]
		floats = [float(x) for x in tokens]

		A_dict['time'] = floats[0]
		A_dict['Cm'] = floats[1]
		A_dict['Cx'] = floats[2]
		A_dict['Cy'] = floats[3]
	
		return A_dict

	time = []
	Cd   = []
	Cl   = []
	Cm   = []
	Cp   = []
	angle= []

	with open(Coeffs_file,"r") as datafile:
		for line in datafile:
			if line[0] == "#":
				continue
			A_dict = line2dict(line)
			alpha = float(w*A_dict['time']-(i*(2*math.pi/blades)))
			angle+= [alpha]
			time += [A_dict['time']]
			Cd   += [math.cos(alpha)*A_dict['Cx'] +math.sin(alpha)*A_dict['Cy']]
			Cl   += [math.sin(alpha)*A_dict['Cx'] +math.cos(alpha)*A_dict['Cy']]
			Cm   += [A_dict['Cm']]
	##		 Calculo coeficiente de presion
			Cp   +=[A_dict['Cm']*l]

	datafile.close()

	outputfile = open('AirFoil_'+i_str+'_Coeffs.txt','w')
	for i in range(0,len(time)):
		outputfile.write(str(time[i])+' '+str(angle[i])+' '+str(Cm[i])+' '+str(Cd[i])+' '+str(Cl[i])+' '+str(Cp[i])+'\n')
	outputfile.close()


