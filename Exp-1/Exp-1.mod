/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 19 août 2021 at 18:04:52
 *********************************************/

// Déclaration de variables décisionnels
dvar float+ x; // "float+ x" "signifie que x dois être une valeurs réel positive. contrainte de positivité
dvar float+ y; // idem

//Definition de la fonction objectif (expression )
dexpr float cost = 0.12*x + 0.15*y; // "dexpr = definition expresion"

//Model
minimize cost;
subject to {  
  Cons01:
  60*x+60*y>=300;
  
  Cons02:
  12*x+6*y>=36;
  
  Cons03:
  10*x+30*y>=90;
}