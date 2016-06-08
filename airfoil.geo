/* 
NACA XXXX Airfoil structured mesh generation in gmsh
Made for Nicolas Vargas C
splattcol@gmail.com
n.vargas1304@uniandes.edu.co 
NACA equation from: http://airfoiltools.com/airfoil/naca4digit
*/

/* NACA parameters (NACA MPXX)*/

Chord 	= 1; // Chord lenght (m)
Camber 	= 6; // maximun camber in % of Chord ( if M = 2 then maximun camber = 2*Chord/100)
PCamber	= 4;// position of the maximun camber (if P = 1 then position = 1*Chord/10)
Thickness=12;//maximun thickness of the airfoil in % of Chord (if XX = 12 then thickness = 12*Chord/100)

/* NACA equation constants */

a0 = 0.2969;
a1 = -0.126;
a2 = -0.3516;
a3 = 0.2843;
a4 = -0.1036; //closed trailing edge!
M  = Camber*Chord/100; 
P  = PCamber*Chord/10;
XX = Thickness*Chord/100;
/* Mesh parameters */

nPoint	= 50; // number of points to divide the Chord
nearBlade = 1/2*Chord; // Near blade zone - structured mesh zone - 
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
		xc = Chord*x;
		xu = xc - yt*Sin(theta);
		yu = yc + yt*Cos(theta);
		xl = xc + yt*Sin(theta);
		yl = yc - yt*Cos(theta);
	Point(count++)={xu,yu,0};upperSurface[]+=count;
	Point(count++)={xl,yl,0};lowerSurface[]+=count;
EndFor
	Point(count++)={Chord,0,0};upperSurface[]+=count;lowerSurface[]+=count;
fline = newl;

upperMesh[]={}; // Lines for the upperMesh
lowerMesh[]={}; // Lines for the lowerMesh

	Line(fline++) = upperSurface[];upperMesh[]+=fline;
	Line(fline++) = lowerSurface[];lowerMesh[]+=fline;

/* ---- End Airfoil generation ---- */

/* ---- Start Mesh generation  ---- */

upperPointMesh[] = {};
lowerPointMesh[] = {};

For beta In {0:Pi:Pi/nPoint}

	x = -nearBlade+(Chord+2*nearBlade)*(1-Cos(beta))/2; // improve head - tail resolution
	
	y = Sqrt(1-((x-1/2*Chord)/(nearBlade+1/2*Chord))^2)*(nearBlade+XX);
	Point(count++)={x, y,0};upperPointMesh[]+=count;
	Point(count++)={x,-y,0};lowerPointMesh[]+=count;
EndFor
	Point(count++)={Chord+nearBlade,0,0};upperPointMesh[]+=count;lowerPointMesh[]+=count;

	


