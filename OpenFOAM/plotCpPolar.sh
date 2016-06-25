#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Coeffs vs. Angle"
	unset border
	set clip
	set polar
	set key outside top right samplen 0.7
	set style line 10 lc 0 #redefine a new line style for the grid

	set grid polar pi/4
	set grid ls 10
	unset xtics
	unset ytics
	plot	"forceCoeffs.txt" using 2:6 title 'Cp' with points pointtype 7 pointsize 1
EOF
