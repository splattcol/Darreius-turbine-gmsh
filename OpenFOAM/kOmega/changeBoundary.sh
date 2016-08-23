#!/bin/bash
pyFoamChangeBoundaryType.py . FrontAndBack empty
pyFoamChangeBoundaryType.py . patch1 wall
pyFoamChangeBoundaryType.py . patch2 wall
pyFoamChangeBoundaryType.py . patch3 wall
pyFoamChangeBoundaryType.py . Shaft wall
pyFoamChangeBoundaryType.py . Lat-Wall wall
pyFoamChangeBoundaryType.py . AMI-St cyclicAMI
pyFoamChangeBoundaryType.py . AMI-Rt cyclicAMI
