#!/bin/bash
 gmsh MaitreMesh.geo -3 -o malla.msh
 gmshToFoam malla.msh
 rm malla.msh
 # checkMesh
 ./changeBoundary.sh # requiere instalacion de pyFOAM
 ./boundaryCyclicAMI.py 
 #  yPlus
 # moveDynamicMesh # prueba el movimiento de la malla con cyclicAMI
 # pimpleDyMFoam # inicia la simulacion en serie
 # decomposePar # divide la malla de acuerdo a decomposePar ubicado en la carpeta system
 # mpirun -n 4 pimpleDyMFoam - parallel > log & # corre la simulacion en paralelo en n nodos
 # paraview foam.foam & # para visualizar el caso en cualquier momento
