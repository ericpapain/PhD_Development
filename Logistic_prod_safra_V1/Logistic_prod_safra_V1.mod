/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 3 sept. 2021 at 11:41:10
 *********************************************/

/* implémentation du premeier modèle tactique pour la gestion de la logistique de 
 production, gestion de stock, de commande utilisateur, modèle de base */
 
//parametres du models 

	// indices du modèle
int J = ...; 		// ensemble de dépots
int K = ...; 		// ensemble des site de production K=UuV
int U = ...;		// ensmeble de site de production interne
int V = ...;		// ensemble de sous traitant 
int I = ...; 		// ensemble des clients
int L = ...; 		// ensemble de modes de transport
int P = ...; 		// ensemble des produits finis
int T = ...; 		// ensemble de période de l'horizon de planification

// parcours de tous les indices

range depots = 1..J;
range sites_prod = 1..K;
range sites_prod_interne = 1..U;
range sites_prod_sous_traitant = 1..V;
range clients = 1..I;
range trans_mode = 1..L;
range produit_finis = 1..P;
range period_planif = 1..T;


	// paramètre cout de transport

float CT[sites_prod][depots][produit_finis][trans_mode][period_planif]=...;		// cout unitaire de transport du produit p du site k vers le depot j via le mode de transport l durant la periode T
float CS[depots][clients][produit_finis][trans_mode][period_planif]=...; 		// cout unitaire de transport du produit p du depot j vers le client i via le mode de transport L durant la periode T
float CF[sites_prod][depots][produit_finis][trans_mode][period_planif]=...; 		// cout fixe de transport du produit p du site k vers le depot j via le mode de transport L durant la periode T
float CFS[depots][clients][produit_finis][trans_mode][period_planif]=...; 		// cout fixe de transport du produit P du dépot j vers le client i via le mode de transport L durant la période T

	// paramètre cout de production

float C[produit_finis][sites_prod][period_planif]=...; 		// cout unitaire de transport du produit p du site k vers le depot j via le mode de transport l durant la periode T
float S[produit_finis][sites_prod][period_planif]=...; 		// cout de lancement de la prod du produit P dans le site de prod K durant la periode de planification T
float G[produit_finis][sites_prod][period_planif]=...; 		// cout de sous traitance du produit P chez le site du sous traitant V durant la periode T
float CSU[sites_prod][period_planif]=...; 					// cout de sous utilisation  de la cpté interne de production dans le site de production K durant la période T
	
	// paramètre stock

float KP[produit_finis][depots][period_planif]=...; 		// cout de possession de stock  du produit P dans le dépot J durant la période T
float W[depots]=...; 										// capacité de stockage du dépot J

	// paramètre capacités et délais
	
int D[produit_finis][clients][period_planif]=...; 		// demande de production du produit P pour le client I a satisfaire a la fin de la periode T
float UU[sites_prod][period_planif]=...; 					//capacité maximale de production dans le site K durant la periode T
float VV[produit_finis]=...; 								// Volume d'occupation dans un mode de transport d'un produit P exprimé en unité de volume de produit
float TP[produit_finis]=...; 								// temps néccessaire pour produire une unité de produit P
float CAP[trans_mode]=...; 									// capacité du moyen de transport L
int e[trans_mode]=...; 									// délai de transport; 2 pour le bateeau et 0 pour camion et avion
float alpha[sites_prod][period_planif]=...; 				// pourcentage de la capacité de production dispponible dans l'unité de production K durant la période T'

// definitions des variables décisionnelle du modele

	// variable de décision liées à l'activité de production
	
dvar int+ X[produit_finis][sites_prod][period_planif]; 		//qté de produit P produite dans le site K durant la periode T
dvar int+ SU[sites_prod][period_planif]; 						// cpté de production non utilisée dans le site K durant la periode T
dvar boolean Y[produit_finis][sites_prod][period_planif]; 		// vaut 1 si le produit P est produit sur le site K a la période T											// 1 si le produit P est produit dans le site k PENDANT LA P2RIODE t ET 0 SINON

	// variable de décision liées à l'activité de stockage

dvar int+ JD[produit_finis][depots][period_planif]; 			//niveau de stock de produit P dans le dépot J a la fin de la période T

	// variable de décision liées à l'activité de transport
	
dvar int+ Z1[sites_prod][depots][produit_finis][trans_mode][period_planif]; 		//Qté de produit P transportée du site K au dépot J pendant la période T via le mode de transport L
dvar int+ Z2[depots][clients][produit_finis][trans_mode][period_planif]; 			//Qté de produit P transportée du dépot J au client i pendant la période T via le mode de transport L
dvar int+ N1[sites_prod][depots][trans_mode][period_planif]; 						//Nombre de moyen de transport (bateau..) utilisés pour transpporter des produits du site K au dépôts J pendant la période T via le mode de transport L
dvar int+ N2[depots][clients][trans_mode][period_planif]; 						//Nombre de moyen de transport (bateau..) utilisés pour transpporter des produits du dépot J au client I pendant la période T via le mode de transport L



// définition de la fonction objectif Z = PC+TC+SU minimisation de la fonction de cout de transport production et transport
dexpr float obj_fct = (sum(t in period_planif, p in produit_finis, k in sites_prod_interne) C[p][k][t]*X[p][k][t] + 
           sum(t in period_planif, p in produit_finis, k in sites_prod_interne) S[p][k][t]*Y[p][k][t] + 
           sum(t in period_planif, p in produit_finis, k in sites_prod_sous_traitant) G[p][k][t]*X[p][k][t] + 
           sum(t in period_planif, k in sites_prod_interne) CSU[k][t]*SU[k][t])/*prod*/ + 
           (sum(t in period_planif, p in produit_finis, j in depots)KP[p][j][t]*((JD[p][j][t+1]+JD[p][j][t])/2))/*stockage*/+
           (sum(t in period_planif, p in produit_finis, k in sites_prod, j in depots, l in trans_mode) CT[k][j][p][l][t]*VV[p]*Z1[k][j][p][l][t] + 
            sum(t in period_planif, p in produit_finis, k in sites_prod, j in depots, l in trans_mode)CF[k][j][p][l][t] *N1[k][j][l][t] + 
            sum(t in period_planif, p in produit_finis, i in clients, j in depots, l in trans_mode) CS[j][i][p][l][t]*VV[p]*Z2[j][i][p][l][t]+
            sum(t in period_planif, p in produit_finis, i in clients,l in trans_mode, j in depots)CFS[j][i][p][l][t]*N2[j][i][l][t]) /*transport*/;

minimize obj_fct;

//maximize sum(i in cargos, j in comps) profit[i]*x[i][j] ;


subject to {
  
  forall(j in depots, p in produit_finis, t in period_planif, l in trans_mode:t>=e[l])
  	storage_constraint_1:
  	JD[p][j][t]==JD[p][j][t-1] + sum(k in sites_prod, l in trans_mode) Z1[k][j][p][l][t-e[l]] - sum(i in clients, l in trans_mode) Z2[j][i][p][l][t];
  
  forall(j in depots, t in period_planif)	
  	storage_constraint_2:
	sum(p in produit_finis) JD[p][j][t] <= W[j];
  
  forall(k in sites_prod, t in period_planif)
    activity_production_constraint_1:
    sum(p in produit_finis) TP[p]*X[p][k][t] <= alpha[k][t]*UU[k][t];
    
  /* forall(k in sites_prod, p in produit_finis, t in period_planif)
    activity_production_constraint_2:
    X[p][k][t] <= M*Y[k][t]; */
    
  forall(p in produit_finis, k in sites_prod_sous_traitant, t in period_planif)
    activity_production_constraint_3:
    Y[p][k][t] <= X[p][k][t];
    
  forall(k in sites_prod_interne, t in period_planif)
    capacity_prod_constraint_1:
    SU[k][t] >= alpha[k][t]*UU[k][t] - sum(p in produit_finis) TP[p]*X[p][k][t];
    
  forall(k in sites_prod_interne, p in produit_finis, j in depots, t in period_planif)
    transport_prod_constraint_1:
    X[p][k][t] == sum(k in sites_prod, l in trans_mode) Z1[k][j][p][l][t];
   
  forall(i in clients,j in depots, p in produit_finis, l in trans_mode, t in period_planif:t>=e[l])
	transport_prod_constraint_2:
	D[p][i][t] == sum(k in sites_prod, l in trans_mode) Z2[j][i][p][l][t-e[l]];

  forall(i in clients,j in depots, p in produit_finis, l in trans_mode, t in period_planif)
	transport_prod_constraint_3:
	sum(p in produit_finis) VV[p]*Z2[j][i][p][l][t] <= N2[j][i][l][t]*CAP[l];

  forall(k in sites_prod, j in depots, p in produit_finis, l in trans_mode, t in period_planif)
	transport_capacity_constraint_1:
	sum(p in produit_finis) VV[p]*Z1[k][j][p][l][t] <= N1[k][j][l][t]*CAP[l];
}

// post processing

/* execute{
  if(cplex.getCplexStatus()==1){ // appel de la fonction 1 pour dire si le probleme est resolvable alors faire

	
	writeln("valeur volume : ",volume.solutionValue);
	
  }else{
    writeln("Erreur : solution non trouver");}
  }    */