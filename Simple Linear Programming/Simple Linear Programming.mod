/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 19 ao�t 2021 at 17:08:18
 *********************************************/

/* Dans cette section nous allons impl�menter un petit programme lin�aire ayant 2 variables
de d�cisions, et une fonction de co�t donc l'objectif principale est de minimiser le co�t,
ensuite  notre fonction objectif aura trois contrainte et nous verons �galement comment 
ins�rer des log et des script dans le code 

-------------------------------------------
 Min 0.12*x + 0.15*y
 ST---
  	60*x+60*y>=300;
  	12*x+6*y>36;
  	10*x+30*y>=90;
	x>=0;
	y>=0;
	
*/

// D�claration de variables d�cisionnels

dvar float+ x; // "float+ x" "signifie que x dois �tre une valeurs r�el positive. contrainte de positivit�
dvar float+ y; // idem

//Definition de la fonction objectif (expression )

dexpr float cost = 0.12*x + 0.15*y; // "dexpr = definition expresion"

/* Definition du model qui est une s�quence de contrainte et definition de minimisation 
et de contrainte 
*/

minimize cost; // on defini qui est ce qu'on veut minimiser ou maximiser

// Definition de contraintes

subject to {
  Cons01:
  60*x+60*y>=300;
  
  Cons02:
  12*x+6*y>=36;
  
  Cons03:
  10*x+30*y>=90;
}

// post processing


