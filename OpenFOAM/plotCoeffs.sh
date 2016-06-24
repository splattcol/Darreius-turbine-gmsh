#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Forces vs. Time"
	set polar
	set grid polar
	unset border
	unset xtics
	unset ytics
	plot	"forceCoeffs.txt" using 1:2 title 'Cm' with linespoints,\
			"forces.txt" using 1:3 title 'Cd' with linespoints,\
			"forces.txt" using 1:4 title 'Cl' with linespoints
EOF
