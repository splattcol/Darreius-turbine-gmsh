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

Chord 	= 0.032; // Chord lenght (m)
Camber 	= 2; // maximun camber in % of Chord ( if M = 2 then maximun camber = 2*Chord/100)
PCamber	= 4;// position of the maximun camber (if P = 1 then position = 1*Chord/10)
Thickness=18;//maximun thickness of the airfoil in % of Chord (if XX = 12 then thickness = 12*Chord/100)

/* ---- Mesh parameters ----*/
nPointCenter	= 30;		// number of points for center shaft
rMesh		= 1/4;		// ratio mesh - if rMesh = 1/4 then Mesh radius = (1+1/4)rRotor
nPoint		= 50; 		// number of points to divide the Chord
nearBlade	= 1/2*Chord;	// Near blade zone - structured mesh zone - 
nearRotor	= 1.5*rRotor;	// Near Rotor zone - rotation mesh zone -  !! nearRotor > rRotor !!
nearShaft	= 1.5*rCenter;	// Near Shaft zone - structured mesh zone -!! nearShaft > rCenter !!

/* NACA equation constants */

a0 = 0.2969;
a1 = -0.126;
a2 = -0.3516;
a3 = 0.2843;
a4 = -0.1036; //closed trailing edge!
M  = Camber/100; 
P  = PCamber/10;
XX = Thickness/100;
Printf ("Inicio generación Perfil");
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
			Point(count++)={xu,yu,0};upperSurface[]+=count; lowerSurface[]+=count;
		EndIf
		If (yu!=yl)
			Point(count++)={xu,yu,0};upperSurface[]+=count;
			Point(count++)={xl,yl,0};lowerSurface[]+=count;
		EndIf
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
		If (y==0)
			Point(count++)={x, y,0};upperPointMesh[]+=count; lowerPointMesh[]+=count;
		EndIf
		If (y!=0)
			Point(count++)={x, y,0};upperPointMesh[]+=count; 
			Point(count++)={x,-y,0};lowerPointMesh[]+=count;
		EndIf
	EndFor
		Point(count++)={Chord+nearBlade,0,0};upperPointMesh[]+=count;lowerPointMesh[]+=count;

		Line(fline++) = upperPointMesh[]; Transfinite Line {fline}=nPoint; upperMesh[]+=-fline; temp = fline; Printf("%g",fline);
		Line(fline++) = lowerPointMesh[]; Transfinite Line {fline}=nPoint; lowerMesh[]+=fline; temp1 = fline; Printf("%g",fline);
		Line loop(fline++) = {-temp1, temp}; aHole[]+=fline; Printf("%g",aHole[Acont-1]);
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

upperSCenter[]={};
lowerSCenter[]={};
upperPCenter[]={};
lowerPCenter[]={};
upperMCenter[]={};
lowerMCenter[]={};
temp = 1;
For alpha In {-Pi/2:Pi/2:Pi/nPointCenter}
	If (Cos(alpha)==0)
		Point(pShaft++)={ rCenter*Sin(alpha), rCenter*Cos(alpha), 0}; upperSCenter[]+=pShaft; lowerSCenter[]+=pShaft;
		Point(pShaft++)={ nearShaft*Sin(alpha), nearShaft*Cos(alpha), 0}; upperPCenter[]+=pShaft; lowerPCenter[]+=pShaft;
	EndIf
	If (Cos(alpha)!=0)
		Point(pShaft++)={ rCenter*Sin(alpha), rCenter*Cos(alpha), 0}; upperSCenter[]+=pShaft;
		Point(pShaft++)={-rCenter*Sin(alpha),-rCenter*Cos(alpha), 0}; lowerSCenter[]+=pShaft;
		Point(pShaft++)={ nearShaft*Sin(alpha), nearShaft*Cos(alpha), 0}; upperPCenter[]+=pShaft;
		Point(pShaft++)={-nearShaft*Sin(alpha),-nearShaft*Cos(alpha), 0}; lowerPCenter[]+=pShaft;
	EndIf
EndFor
	/* ----- Line loops and Surfaces generation -----*/
	Line (lShaft++)={upperSCenter[0],upperPCenter[0]}; Transfinite Line{lShaft}= nPointCenter/2 Using Progression 1.2;  upperMCenter[]+=-lShaft;
	Line (lShaft++)={upperSCenter[nPointCenter],upperPCenter[nPointCenter]}; Transfinite Line{lShaft}= nPointCenter/2 Using Progression 1.2; upperMCenter[]+= lShaft;
	Line (lShaft++)={lowerSCenter[0],lowerPCenter[0]}; Transfinite Line{lShaft}= nPointCenter/2 Using Progression 1.2;  lowerMCenter[]+= lShaft;
	Line (lShaft++)={lowerSCenter[nPointCenter],lowerPCenter[nPointCenter]}; Transfinite Line{lShaft}= nPointCenter/2 Using Progression 1.2;  lowerMCenter[]+=- lShaft; 
	Line (lShaft++)=upperSCenter[]; Transfinite Line{lShaft} = nPointCenter; upperMCenter[]+= lShaft; 
	Line (lShaft++)=lowerSCenter[]; Transfinite Line{lShaft} = nPointCenter; lowerMCenter[]+=-lShaft; 
	Line (lShaft++)=upperPCenter[]; temp = lShaft; Transfinite Line{lShaft} = nPointCenter; upperMCenter[]+=-lShaft; 
	Line (lShaft++)=lowerPCenter[]; temp1= lShaft; Transfinite Line{lShaft} = nPointCenter; lowerMCenter[]+= lShaft; 
	Line loop(lShaft++) = {-temp1, temp}; Shaft = lShaft; Printf(" %g ",Shaft);
	Line loop(lShaft++) = upperMCenter[]; ShaftU = lShaft;
	Plane Surface(lShaft++) = {ShaftU};  Transfinite Surface{lShaft}; Recombine Surface{lShaft};
	Line loop(lShaft++) = lowerMCenter[]; ShaftL = lShaft;
	Plane Surface(lShaft++) = {ShaftL};  Transfinite Surface{lShaft}; Recombine Surface{lShaft};
	/* ---- End structured mesh generation ---- */
/* ---- End Center Shaft Generation ---- */
/* ---- Rotor Mesh ---- */

RotorPoint[]={};
RotorMesh []={};

pRotor = newp;
lRotor = newl;
For alpha In {0:2*Pi:Pi/nPoint}
	Point(pRotor++)={ nearRotor*Sin(alpha), nearRotor*Cos(alpha), 0}; RotorPoint[]+=pRotor;
EndFor
	RotorPoint[]+=RotorPoint[0];
	Line (lRotor) = RotorPoint[]; temp = lRotor;
	Line loop(lRotor++) = {temp}; temp = lRotor;
	Plane Surface (lRotor++) = {temp, aHole[], Shaft};

