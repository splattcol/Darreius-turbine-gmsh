#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Coeffs vs. Angle"
	
	set xlabel "Angle (deg)"
	set ylabel "Coeffs ( )"
	set xtic auto
	set ytic auto
	set grid 
	plot	"globalCoeffs.txt" using 2:3 title 'Cm' with points pointtype 1 pointsize 1,\
			"globalCoeffs.txt" using 2:4 title 'Cd' with points pointtype 2 pointsize 1,\
			"globalCoeffs.txt" using 2:5 title 'Cl' with points pointtype 3 pointsize 1,\
			"globalCoeffs.txt" using 2:6 title 'Cp' with points pointtype 4 pointsize 1
EOF
