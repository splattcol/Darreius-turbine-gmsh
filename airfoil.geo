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

nPoint	= 200; // number of points to divide the Chord
nearBlade = 1/2*Chord; // Near blade zone - structured mesh zone - 
count = newp;

upperSurface[]={};
lowerSurface[]={};
//x=0;
//yc=0;
For x In {0:1:1/nPoint}

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
	Point(count++)={Chord,0,0};upperSurface[]+=count;
	Point(count++)={Chord,0,0};lowerSurface[]+=count;
fline = newl;
	Line(fline)   = upperSurface[];
	Line(fline++) = lowerSurface[];
	


