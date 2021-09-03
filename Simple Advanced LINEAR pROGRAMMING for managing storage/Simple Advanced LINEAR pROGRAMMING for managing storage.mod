/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 23 août 2021 at 15:33:18
 *********************************************/
/*
a cargo plane has three compartments for storing cargo : front, center, and rear. 
these compartments have the following limits on both weight and space :weight 
furthermore, the weight of the cargo in respective compartments must be the same 
proportion of that compartment's weight capacity to maintain the balance of the plane.
The following four cargoes are avaibkles for shipment on the next flight.
Any proportion of these cargoes can be accepted. the objective is to determine 
how much(if any) of each cargo and cargo should be accepted and how to distribute 
each among the compartments so that the total profit is maximized

data https://community.ibm.com/community/user/legacy 
*/


//parametres du models 

int n = ...; //nombre de cargos
int m = ...; // nombre de compartiments de l'avion

range cargos = 1..n;
range comps = 1..m; // pour le parcours de l'ensemnble des compartiments

float profit[cargos]=...;
float weight[cargos]=...;
float volume[cargos]=...;

float weight_cap[comps]=...;
float space_cap[comps]=...;

// definitions des variables décisionnelle du modele

dvar float+ x[cargos][comps];
dvar float+ y;

maximize sum(i in cargos, j in comps) profit[i]*x[i][j];


subject to {
  forall(i in cargos)
    available_weight:
    sum(j in comps) x[i][j] <= weight[i];
    
  forall(j in comps)
    weight_capacity:
    sum(i in cargos) x[i][j] <= weight_cap[j];

  forall(j in comps)
    space_capacity:
    sum(i in cargos) volume[i]*x[i][j] <= space_cap[j];
    
  forall(j in comps)
    balanced_plane:
    sum(i in cargos) x[i][j] / weight_cap[j] == y;
}

// post processing

/* execute{
  if(cplex.getCplexStatus()==1){ // appel de la fonction 1 pour dire si le probleme est resolvable alors faire

	
	writeln("valeur volume : ",volume.solutionValue);
	
  }else{
    writeln("Erreur : solution non trouver");}
  }    */