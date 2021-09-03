/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 19 ao�t 2021 at 18:04:52
 *********************************************/

// D�claration de variables d�cisionnels
dvar float+ x; // "float+ x" "signifie que x dois �tre une valeurs r�el positive. contrainte de positivit�
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