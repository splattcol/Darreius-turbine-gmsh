#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "yPlus vs. Time"
	
	set xlabel "Time (s)"
	set ylabel "yPlus ( )"
	set xtic auto
	set ytic auto
	set grid 
	plot	"yPlus_Patch_1" using 1:2 title 'Min' with lines,\
		"yPlus_Patch_1" using 1:3 title 'Max' with lines,\
		"yPlus_Patch_1" using 1:4 title 'Average' with lines
EOF
