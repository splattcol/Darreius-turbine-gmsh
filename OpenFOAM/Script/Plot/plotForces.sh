#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Forces vs. Time"
	set polar
	set grid polar
	unset border
	unset xtics
	unset ytics
	plot	"forces.txt" using 1:2 title 'lift' with linespoints,\
			"forces.txt" using 1:3 title 'drag' with linespoints,\
			"forces.txt" using 1:4 title 'Moment' with linespoints
EOF
