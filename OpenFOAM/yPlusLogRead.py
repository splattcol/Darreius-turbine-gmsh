#!/usr/bin/python
import os
import sys
import fileinput
if os.path.exists('yPlus_Average'):
	print ('file: yPlus_Average already exist \nexit! \n')
	sys.exit()
if os.path.exists('yPlus_Patch_1'):
	print ('file: yPlus_Patch_1 already exist \nexit! \n')
	sys.exit()
fileName = raw_input ('enter file name:\n')
fRead = open (fileName, 'r')
fWriteA = open ('yPlus_Average', 'w') 
fWriteP = open ('yPlus_Patch_1', 'w')
fWriteA.write('## Average yPlus ##\nTime\t patch_1\t patch_2\t patch_3\n')
fWriteP.write('## Min, Max and Average yPlus Patch 1 ##\nTime\t Min\t Max\t Average\n')
boolean = False;
for line in fRead:
	if line.startswith('Time'):
		time = line
	elif line.startswith('Patch'):
		strTemp = line
		tNum = strTemp.find('average')
		if strTemp[6]=='1':
			nMin = strTemp.find('min: ')
			nMax = strTemp.find('max: ')
			patch_1 = strTemp[tNum+9 :-1]
			fWriteP.write(time[7:-1]+'\t'+strTemp[nMin+5:nMax-1]+'\t'+strTemp[nMax+5:tNum-1]+'\t'+patch_1+'\n')
		elif strTemp[6]=='2':
			patch_2 = strTemp[tNum+9 :-1]
		elif strTemp[6]=='3':
			patch_3 = strTemp[tNum+9 :]
			boolean = True
	if boolean:
		fWriteA.write(time[7:-1]+'\t'+patch_1+'\t'+patch_2+'\t'+patch_3)
		boolean = False
fRead.close()
fWriteA.close()
fWriteP.close()
print('Process finished! \n Enjoy!\n')
