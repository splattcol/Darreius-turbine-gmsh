/* 
Mesh for a Darreius Turbine 2D
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
nPointCenter	= 30;		// number of points for center shaft
rMesh		= 1/4;		// ratio mesh - if rMesh = 1/4 then Mesh radius = (1+1/4)rRotor
nPoint		= 50; 		// number of points to divide the Chord
nearBlade	 = 1/2*Chord;	// Near blade zone - structured mesh zone - 

/* NACA parameters (NACA MPXX)*/

Chord 	= 0.032; // Chord lenght (m)
Camber 	= 2; // maximun camber in % of Chord ( if M = 2 then maximun camber = 2*Chord/100)
PCamber	= 4;// position of the maximun camber (if P = 1 then position = 1*Chord/10)
Thickness=18;//maximun thickness of the airfoil in % of Chord (if XX = 12 then thickness = 12*Chord/100)



cont=1;
For theta In {0:2*Pi:2*Pi/nBlades}

	/* ---- Start Airfoil generation ----*/
	count = newp;
	upperSurface[]={};
	lowerSurface[]={};

	For beta In {0:Pi:Pi/nPoint}
	
		x = (1-Cos(beta))/2; // improve head - tail resolution

		If (x<(PCamber/10))
			yc = (M/(P^2))*((2*P*x)-x^2);
			dyx= (2*M/P^2)*(P-x);
		EndIf
		If (x>=(PCamber/10) && x<1)
			yc = (M/(1-P)^2)*(1-2*P+2*P*x-x^2);
			dyx= (2*M/(1-P))*(P-x);
		EndIf
	
		yt = XX/0.2*(a0*x^(1/2)+a1*x+a2*x^(2)+a3*x^(3)+a4*x^(4));
		theta= Atan(dyx);
		xu = (x - yt*Sin(theta))*Chord;
		yu = (yc + yt*Cos(theta))*Chord;
		xl = (x + yt*Sin(theta))*Chord;
		yl = (yc - yt*Cos(theta))*Chord;
	
		Point(count++)={xu,yu,0};upperSurface[]+=count;
		Point(count++)={xl,yl,0};lowerSurface[]+=count;
	EndFor
		Point(count++)={Chord,0,0};upperSurface[]+=count;lowerSurface[]+=count;
	fline = newl;

	upperMesh[]={}; // Lines for the upperMesh
	lowerMesh[]={}; // Lines for the lowerMesh

	Line(fline++) = upperSurface[]; Transfinite Line {fline}=nPoint; upperMesh[]+=fline;
	Line(fline++) = lowerSurface[]; Transfinite Line {fline}=nPoint; lowerMesh[]+=-fline;

	/* ---- End Airfoil generation ---- */

	/* ---- Start Mesh generation  ---- */

	upperPointMesh[] = {};
	lowerPointMesh[] = {};

	For beta In {0:Pi:Pi/nPoint}

		x = -nearBlade+(Chord+2*nearBlade)*(1-Cos(beta))/2; // improve head - tail resolution
	
		y = Sqrt(1-((x-1/2*Chord)/(nearBlade+1/2*Chord))^2)*(nearBlade+XX*Chord);
		Point(count++)={x, y,0};upperPointMesh[]+=count;
		Point(count++)={x,-y,0};lowerPointMesh[]+=count;
	EndFor
		Point(count++)={Chord+nearBlade,0,0};upperPointMesh[]+=count;lowerPointMesh[]+=count;

		Line(fline++) = upperPointMesh[]; Transfinite Line {fline}=nPoint; upperMesh[]+=-fline;
		Line(fline++) = lowerPointMesh[]; Transfinite Line {fline}=nPoint; lowerMesh[]+=fline;
		Line(fline++) = {upperPointMesh[0],upperSurface[0]}; upperMesh[]+=fline; Transfinite Line {fline}=nPoint/2 Using Progression 1/1.2;
		Line(fline++) = {lowerPointMesh[0],lowerSurface[0]}; lowerMesh[]+=-fline; Transfinite Line {fline}=nPoint/2 Using Progression 1/1.2;
		Line(fline++) = {upperSurface[nPoint],upperPointMesh[nPoint]}; upperMesh[]+=fline;Transfinite Line {fline}=nPoint/2 Using Progression 1.2;
		Line(fline++) = {lowerPointMesh[nPoint],lowerSurface[nPoint]}; lowerMesh[]+=fline; Transfinite Line {fline}=nPoint/2 Using Progression 1/1.2;
	/* ----- Line loops and Surfaces generation -----*/
	Line loop(fline++) = upperMesh[]; upperLoop = fline;
	Line loop(fline++) = lowerMesh[]; lowerLoop = fline;
	Airfoil~{cont}[]={};
	Plane Surface(fline++) = {upperLoop}; Airfoil[]+=fline; Transfinite Surface {fline}; Recombine Surface {fline};
	Plane Surface(fline++) = {lowerLoop}; Airfoil[]+=fline; Transfinite Surface {fline}; Recombine Surface {fline};
	Translate{-Chord/2,0,0}{Surface{Airfoil[]};}
	/* ---- End structured mesh generation ---- */

/* ---- Traslation and rotation ----*/
	x = rRotor*Sin(theta);
	y = Sqrt(rRotor^2-x^2);
	Translate{x,y,0}{Duplicata{Airfoil[]};}
EndFor