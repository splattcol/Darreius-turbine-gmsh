#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Coeffs vs. Angle"
	
	set xlabel "Angle (rad)"
	set ylabel "Coeffs ( )"
	set xtic auto
	set ytic auto
	set grid 
	plot	"forceCoeffs.txt" using 2:3 title 'Cm' with linespoints,\
			"forceCoeffs.txt" using 2:4 title 'Cd' with linespoints,\
			"forceCoeffs.txt" using 2:5 title 'Cl' with linespoints,\
			"forceCoeffs.txt" using 2:6 title 'Cp' with linespoints
EOF
