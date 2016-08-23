#!/usr/bin/python

import os
import sys
import math

Ui  = 2.8
Ut  = 52.57*.175/2
blades = 3

def line2dict(line):
	tokens_unprocessed = line.split()
	tokens = [x.replace(")","").replace("(","") for x in tokens_unprocessed]
	floats = [float(x) for x in tokens]
	data_dict = {}
	data_dict['time'] = floats[0]
	force_dict = {}
	force_dict['pressure'] = floats[1:4]
	force_dict['viscous'] = floats[4:7]
	force_dict['porous'] = floats[7:10]
	moment_dict = {}
	moment_dict['pressure'] = floats[10:13]
	moment_dict['viscous'] = floats[13:16]
	moment_dict['porous'] = floats[16:19]
	data_dict['force'] = force_dict
	data_dict['moment'] = moment_dict
	return data_dict

for i in range(blades):
    i_str = str(i+1);
    forces_file = "AirFoil_"+i_str+"/0/forces.dat"

    if not os.path.isfile(forces_file):
	    print "Forces file not found at "+forces_file
	    print "Be sure that the case has been run and you have the right directory!"
	    print "Exiting."
	    sys.exit()

    time = []
    Fl=[]
    Fd=[]
    moment = []
    angle=[]
    rev = 0
    with open(forces_file,"r") as datafile:
    	for line in datafile:
    		if line[0] == "#":
    			continue
    		data_dict = line2dict(line)
    		time += [data_dict['time']]
    		Fx  = data_dict['force']['pressure'][0] + data_dict['force']['viscous'][0]
    		Fy  = data_dict['force']['pressure'][1] + data_dict['force']['viscous'][1]
    		moment += [data_dict['moment']['pressure'][2] + data_dict['moment']['viscous'][2]]
    		alpha = float(52.57*data_dict['time']-(i*(2*math.pi/blades)))
    		U   = math.sqrt(Ui**2+Ut**2-2*Ui*Ut*math.cos(alpha))
    		theta = math.asin(Ut*math.sin(alpha)/U)
    		if math.degrees(alpha)-360*rev>360:
    		    rev+=1
    		angle+= [math.degrees(alpha)-360*rev]
    		Fl +=[Fy*math.cos(theta)+Fx*math.sin(theta)]
    		Fd +=[Fx*math.cos(theta)+Fy*math.sin(theta)]
    
    datafile.close()

    outputfile = open('forces_'+i_str+'.txt','w')
    for i in range(0,len(time)):
    	outputfile.write(str(time[i])+' '+str(angle[i])+' '+str(Fd[i])+' '+str(Fl[i])+' '+str(moment[i])+'\n')
    outputfile.close()
        
#    os.system("./plotForces.sh")  

