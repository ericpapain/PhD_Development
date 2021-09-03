/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 19 août 2021 at 17:08:18
 *********************************************/

/* Dans cette section nous allons implémenter un petit programme linéaire ayant 2 variables
de décisions, et une fonction de coût donc l'objectif principale est de minimiser le coût,
ensuite  notre fonction objectif aura trois contrainte et nous verons également comment 
insérer des log et des script dans le code 

-------------------------------------------
 Min 0.12*x + 0.15*y
 ST---
  	60*x+60*y>=300;
  	12*x+6*y>36;
  	10*x+30*y>=90;
	x>=0;
	y>=0;
	
*/

// Déclaration de variables décisionnels

dvar float+ x; // "float+ x" "signifie que x dois être une valeurs réel positive. contrainte de positivité
dvar float+ y; // idem

//Definition de la fonction objectif (expression )

dexpr float cost = 0.12*x + 0.15*y; // "dexpr = definition expresion"

/* Definition du model qui est une séquence de contrainte et definition de minimisation 
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


