/* 
Mesh for a Darreius Turbine 2D
Made for Nicolas Vargas C
splattcol@gmail.com
n.vargas1304@uniandes.edu.co 
*/

/* ---- Rotor parameters ----*/
nBlades	= 3; 	// number of blades
rRotor	= 0.175/2;// Rotor radius 
rCenter = 0.005;// Center shaft radius

/* NACA parameters (NACA MPXX)*/

Chord 	= 0.032;	// Chord length (m)
Camber 	= 2; 		// maximun camber in % of Chord ( if M = 2 then maximun camber = 2*Chord/100)
PCamber	= 4;		// position of the maximun camber (if P = 1 then position = 1*Chord/10)
Thickness=18;		//maximun thickness of the airfoil in % of Chord (if XX = 12 then thickness = 12*Chord/100)

/* ---- Mesh parameters ----*/
nPointCenter	= 10;		// Shaft nPoint
nPoint		= 25; 		// Chord nPoint
nPointRotor 	= 120;		// RotateMesh nPoint
nPointFar 	= 50;		// Farfield nPoint
nPointInletOulet= 80;		// Inlet-Oulet nPoint
rMesh		= 1/4;		// ratio mesh - if rMesh = 1/4 then Mesh radius = (1+1/4)rRotor
nearBlade	= 1/2*Chord;	// Near blade zone - structured mesh zone - 
nearRotor	= 1.5*rRotor;	// Near Rotor zone - rotation mesh zone -  !! nearRotor > rRotor !!
nearShaft	= 1.5;		// Near Shaft zone - structured mesh zone -!! nearShaft > 1 !!
dx 		= 1e-6;		// Diference between staticMeshRotor and rotationMeshRotor
dInlet		= 0.35;		// length from {0,0,0} to Inlet (in -x)
dOutlet		= 0.75;		// length from {0,0,0} to Outlet (in x)
dWall		= 0.35;		// length from {0,0,0} to lateral walls
lenghtZ		= 0.005;		// lenght for Extrusion
dz		= 1;		// number of Extrusion's layers
dh		= dz*0.1;		// point element zise


/* NACA equation constants */

a0 = 0.2969;
a1 = -0.126;
a2 = -0.3516;
a3 = 0.2843;
a4 = -0.1036; //closed trailing edge!
M  = Camber/100; 
P  = PCamber/10;
XX = Thickness/100;

Acont=1;
Airfoil[]={};
aHole[]={};
/* --- Rotor Mesh Generation ----*/
For alpha In {0:1.999*Pi:2*Pi/nBlades}
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
		If (yu==yl)
			Point(count++)={xu,yu,0, dh};upperSurface[]+=count; lowerSurface[]+=count;
		EndIf
		If (yu!=yl)
			Point(count++)={xu,yu,0, dh};upperSurface[]+=count;
			Point(count++)={xl,yl,0, dh};lowerSurface[]+=count;
		EndIf
	EndFor
		Point(count++)={Chord,0,0, dh};upperSurface[]+=count;lowerSurface[]+=count;
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
		If (y==0)
			Point(count++)={x, y,0, dh};upperPointMesh[]+=count; lowerPointMesh[]+=count;
		EndIf
		If (y!=0)
			Point(count++)={x, y,0, dh};upperPointMesh[]+=count; 
			Point(count++)={x,-y,0, dh};lowerPointMesh[]+=count;
		EndIf
	EndFor
		Point(count++)={Chord+nearBlade,0,0, dh};upperPointMesh[]+=count;lowerPointMesh[]+=count;

		Line(fline++) = upperPointMesh[]; Transfinite Line {fline}=nPoint; upperMesh[]+=-fline; temp = fline;
		Line(fline++) = lowerPointMesh[]; Transfinite Line {fline}=nPoint; lowerMesh[]+=fline; temp1 = fline;
		Line loop(fline++) = {-temp1, temp}; aHole[]+=fline;
		Line(fline++) = {upperPointMesh[0],upperSurface[0]}; upperMesh[]+=fline; lowerMesh[]+=-fline ; Transfinite Line {fline}=nPoint/2 Using Progression 1/1.2;

		Line(fline++) = {upperSurface[nPoint],upperPointMesh[nPoint]}; upperMesh[]+=fline; lowerMesh[]+=-fline;Transfinite Line {fline}=nPoint/2 Using Progression 1.2;
	/* ----- Line loops and Surfaces generation -----*/
	Line loop(fline++) = upperMesh[]; upperLoop = fline; Airfoil[]+=fline; 
	Line loop(fline++) = lowerMesh[]; lowerLoop = fline; Airfoil[]+=fline; 
	Airfoil~{Acont}[]={};
	Plane Surface(fline++) = {upperLoop}; Airfoil~{Acont}[]+=fline; Transfinite Surface {fline}; Recombine Surface {fline};
	Plane Surface(fline++) = {lowerLoop}; Airfoil~{Acont}[]+=fline; Transfinite Surface {fline}; Recombine Surface {fline};
	Translate{-Chord/2,0,0}{Surface{Airfoil~{Acont}[]};} // Translate Center Airfoil to {0,0,0}
	/* ---- End structured mesh generation ---- */

/* ---- Traslation and rotation ----*/
	x = rRotor*Sin(alpha);
	y = rRotor*Cos(alpha);
	Translate{x,y,0}{Surface{Airfoil~{Acont}[]};}
	Rotate {{0,0,1},{x,y,0},-alpha}{Surface{Airfoil~{Acont}[]};}
	
	Acont++;
EndFor
/* ---- End nBlades Generation ----*/
/* ---- Center Shaft ---- */
pCenter= newp;
pShaft = newp;
lShaft = newl;

upperSCenter[]={}; //Shaft Point array
lowerSCenter[]={}; //Shaft Point array
upperPCenter[]={}; //Mesh Point array
lowerPCenter[]={}; //Mesh Point array
upperMCenter[]={}; //Mesh Line array
lowerMCenter[]={}; //Mesh Line array
temp = 1;
For alpha In {-Pi/2:Pi/2:Pi/nPointCenter}
		x = rCenter*Sin(alpha);
		y = rCenter*Cos(alpha);
	If ((y<=1e-10))
		Point(pShaft++)={ x, y, 0, dh}; upperSCenter[]+=pShaft; lowerSCenter[]+=pShaft;
		Point(pShaft++)={ nearShaft*x, nearShaft*y, 0, dh}; upperPCenter[]+=pShaft; lowerPCenter[]+=pShaft;
	EndIf
	If (y>1e-10)
		Point(pShaft++)={ x, y, 0, dh}; upperSCenter[]+=pShaft;
		Point(pShaft++)={ x,-y, 0, dh}; lowerSCenter[]+=pShaft;
		Point(pShaft++)={ nearShaft*x, nearShaft*y, 0, dh}; upperPCenter[]+=pShaft;
		Point(pShaft++)={ nearShaft*x,-nearShaft*y, 0, dh}; lowerPCenter[]+=pShaft;
	EndIf
EndFor
	/* ----- Line loops and Surfaces generation -----*/
	Line (lShaft++)={upperSCenter[0],upperPCenter[0]}; Transfinite Line{lShaft}= nPointCenter/2 Using Progression 1.2;  upperMCenter[]+=-lShaft; lowerMCenter[]+= lShaft;
	Line (lShaft++)={upperSCenter[nPointCenter],upperPCenter[nPointCenter]}; Transfinite Line{lShaft}= nPointCenter/2 Using Progression 1.2; upperMCenter[]+= lShaft;  lowerMCenter[]+=-lShaft;

	Line (lShaft++)=upperSCenter[]; Transfinite Line{lShaft} = nPointCenter; upperMCenter[]+= lShaft; 
	Line (lShaft++)=lowerSCenter[]; Transfinite Line{lShaft} = nPointCenter; lowerMCenter[]+=-lShaft; 
	Line (lShaft++)=upperPCenter[]; Transfinite Line{lShaft} = nPointCenter; upperMCenter[]+=-lShaft; temp = lShaft;
	Line (lShaft++)=lowerPCenter[]; Transfinite Line{lShaft} = nPointCenter; lowerMCenter[]+= lShaft; temp1= lShaft;
	Line loop(lShaft++) = {-temp1, temp}; Shaft = lShaft;
	Line loop(lShaft++) = upperMCenter[]; ShaftU = lShaft;
	Plane Surface(lShaft++) = {ShaftU};  Transfinite Surface{lShaft}; Recombine Surface{lShaft}; ShaftS_U = lShaft;
	Line loop(lShaft++) = lowerMCenter[]; ShaftL = lShaft;
	Plane Surface(lShaft++) = {ShaftL};  Transfinite Surface{lShaft}; Recombine Surface{lShaft}; ShaftS_L = lShaft;
	/* ---- End structured mesh generation ---- */
/* ---- End Center Shaft Generation ---- */
/* ---- Rotor Mesh ---- */

StaticRotorPoint[]={};
RotateRotorPoint[]={};
RotorMesh []={};

pRotor = newp;
lRotor = newl;
For alpha In {0:2*Pi:Pi/nPoint}
	Point(pRotor++)={ nearRotor*Sin(alpha), nearRotor*Cos(alpha), 0, dh}; RotateRotorPoint[]+=pRotor;
	Point(pRotor++)={ nearRotor*(1+dx)*Sin(alpha), nearRotor*(1+dx)*Cos(alpha), 0, dh}; StaticRotorPoint[]+=pRotor;
EndFor
	RotateRotorPoint[]+=RotateRotorPoint[0];
	StaticRotorPoint[]+=StaticRotorPoint[0];
	Line (lRotor) = RotateRotorPoint[]; Transfinite Line (lRotor) = nPointRotor; rlRotor = lRotor;
	Line loop(lRotor++) = {rlRotor}; llRotor = lRotor;
	Plane Surface (lRotor++) = {llRotor, aHole[], Shaft}; RotorS = lRotor;
	Line (lRotor++) = StaticRotorPoint[]; Transfinite Line (lRotor) = nPointRotor; temp = lRotor;
//	Line (lRotor++) = {RotateRotorPoint[0], StaticRotorPoint[0]};
	Line loop (lRotor++) = temp; StaticRotorLine = lRotor;
//	Plane Surface (lRotor++) = {StaticRotorLine, llRotor}; StRotorS = lRotor; Recombine Surface {lRotor};

/* ---- Farfield ----*/

ffpoint	= newp;
ffline	= newl;
fInlet[]= {};
fOulte[]= {};
fWallU[]= {};
fWallL[]= {};

Point(ffpoint)	= {-dInlet, dWall, 0, dh}; fInlet[]+=ffpoint; fWallU[]+=ffpoint;
Point(ffpoint++)= {-dInlet,-dWall, 0, dh}; fInlet[]+=ffpoint; fWallL[]+=ffpoint;
Point(ffpoint++)= {dOutlet,-dWall, 0, dh}; fOulte[]+=ffpoint; fWallL[]+=ffpoint;
Point(ffpoint++)= {dOutlet, dWall, 0, dh}; fOulte[]+=ffpoint; fWallU[]+=ffpoint;

Line (ffline)	= fInlet[]; lInlet = ffline; Transfinite Line {lInlet} = nPointInletOulet;
Line (ffline++)	= fOulte[]; lOulet = ffline; Transfinite Line {lOulet} = nPointInletOulet;
Line (ffline++)	= fWallU[]; lWallU = ffline; Transfinite Line {lWallU} = nPointFar Using Bump 0.5;
Line (ffline++)	= fWallL[]; lWallL = ffline; Transfinite Line {lWallL} = nPointFar Using Bump 0.5;

Line loop (ffline++) = {lInlet, lWallL, lOulet,-lWallU}; temp = ffline;
Plane Surface(ffline++) = {temp, StaticRotorLine}; farfieldS = ffline;
/* ---- Extrusion ----*/
FaB[]={};
Avolume[]={};
For i In {1:nBlades} // First Extrusion!!
AirfoilS~{i} = {};
AirfoilS~{i} = Extrude {0,0,lenghtZ}{
	Surface {Airfoil~{i}[]};
	Layers {dz};
	Recombine;
};
Physical Surface (i) = {AirfoilS~{i}[2],AirfoilS~{i}[8]};
FaB+=AirfoilS~{i}[6];FaB+=AirfoilS~{i}[0];FaB+=Airfoil~{i}[];
Avolume[]+=AirfoilS~{i}[1]; Avolume[]+=AirfoilS~{i}[7];
EndFor

ShaftWall[]= {};
ShaftWall[]= Extrude {0,0,lenghtZ}{
	Surface {ShaftS_U, ShaftS_L};
	Layers {dz};
	Recombine;
};

Farfield[] = {};
Farfield[] = Extrude {0,0,lenghtZ}{
	Surface {farfieldS};
	Layers {dz};
	Recombine;
};

Rotor[] = {};
Rotor[] = Extrude {0,0,lenghtZ}{
	Surface{RotorS};
	Layers {dz};
	Recombine;
};
/*
Add[] = Extrude {0,0,lenghtZ}{
	Surface{StRotorS};
	Layers {dz};
	Recombine;
};*/

Physical Surface ("AMI-Rt") = {Rotor[2]};
Physical Surface ("AMI-St") = {Farfield[6]};
Physical Surface ("FrontAndBack") = {Farfield[0], farfieldS, FaB[], ShaftWall[0], ShaftWall[6], ShaftS_L, ShaftS_U, RotorS, Rotor[0]};
Physical Surface ("Inlet") = {Farfield[2]};
Physical Surface ("Lat-Wall") = {Farfield[3], Farfield[5]};
Physical Surface ("Outlet") = {Farfield[4]};
Physical Surface ("Shaft") = {ShaftWall[3], ShaftWall[11]};

Physical Volume ("Farfield") = {Farfield[1]};
Physical Volume ("RotateMesh") = {Avolume[], ShaftWall[1], ShaftWall[7], Rotor[1]};
/* ---- END MESH ----*/
