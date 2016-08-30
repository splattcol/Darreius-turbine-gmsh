/* 
Rotor for a Darreius Turbine 
Made for Nicolas Vargas C
splattcol@gmail.com
n.vargas1304@uniandes.edu.co 
*/

Include "airfoil.geo";

/* ---- Rotor parameters ----*/
nBlades	= 3; 	// number of blades
rRotor	= 0.175/2;// Rotor radius 
rCenter = 0.011;// Center shaft radius

/* ---- Mesh parameters ----*/
nPointCenter	= 30;	// number of points for center shaft
rMesh		= 1/4;	// ratio mesh - if rMesh = 1/4 then Mesh radius = (1+1/4)rRotor
cont=1;
For theta In {0:2*Pi:2*Pi/nBlades}
	x = rRotor*Sin(theta);
	y = Sqrt(rRotor^2-x^2);
	Airfoil~{cont}[]=Translate{x,y,0}{Duplicata{Surface{Airfoil[]};}};
	Transfinite Surface {Airfoil~{cont}[0]}; Recombine Surface {Airfoil~{cont}[0]};
	cont++;
EndFor
