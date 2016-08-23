#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Coeffs vs. Angle"
	
	set xlabel "Angle (rad)"
	set ylabel "Coeffs ( )"
	set xtic auto
	set ytic auto
	set grid 
	plot	"globalCoeffs.txt" using 2:3 title 'Cm' with lines,\
			"globalCoeffs.txt" using 2:4 title 'Cd' with lines,\
			"globalCoeffs.txt" using 2:5 title 'Cl' with lines,\
			"globalCoeffs.txt" using 2:6 title 'Cp' with lines
EOF
