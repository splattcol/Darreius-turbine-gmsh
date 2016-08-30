#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "yPlus vs. Time"
	
	set xlabel "Angle (rad)"
	set ylabel "Coeffs ( )"
	set xtic auto
	set ytic auto
	set grid 
	plot	"yPlus_Average" using 1:2 title 'Patch 1' with lines,\
		"yPlus_Average" using 1:3 title 'Patch 2' with lines,\
		"yPlus_Average" using 1:4 title 'Patch 3' with lines
EOF
