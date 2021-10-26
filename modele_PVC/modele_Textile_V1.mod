/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 06 oct. 2021 at 12:33:40
 *********************************************/

 	// indices du modèle
int S = ...; 		// Index of suppliers
int R = ...; 		// Index of raw materials
int F = ...;		// Index of manufacturing plants
int P = ...;		// Index of products
int W = ...; 		// Index of warehouses
int T = ...; 		// Index of transportation modes
int N = ...; 		// Index of customers

int U = ...;        // Index sous traitants

// parcours de tous les indices

range suppliers = 1..S;
range raw_materials = 1..R;
range manufacturing_plants = 1..F;
range products = 1..P;
range warehouses = 1..W;
range trans_mode = 1..T;
range customers = 1..N;
//
range sous_traitants = 1..U;

								/******************************** Model parameters *********************/

// Capacity of raw material r provided by supplier s
int CPS[raw_materials][suppliers]=...;

// Selection costs of supplier s
float SLC[suppliers]=...;


// cout de selections des sous traitants
float spl[sous_traitants]=...;


// Life cycle CO2 emissions per unit of raw material r provided by supplier s
float EMS[raw_materials][suppliers]=...;
float EMSS[raw_materials][sous_traitants]=...;

// Price per unit of raw material r provided by supplier s
float PRS[raw_materials][suppliers]=...;

// Conversion rate of raw material r to product p
int CR[raw_materials][products]=...;

// Capacity of product p produced by plant f
int CPF[products][manufacturing_plants]=...;

//capacité de production du site de chaque sous traitant par produit 
 int cpfs[products][sous_traitants]=...;

// Capital costs of establishing plant f
//float CCF[manufacturing_plants]=...;

// Annualized capital costs of establishing plant f
int ACF[manufacturing_plants]=...;

// Variable costs of producing one unit of product p
float VCF[products][manufacturing_plants]=...;

// cout variable de production chez les sous traitants
float vcu[products][sous_traitants]=...;

// CO2 emissions for producing one unit of product p
//float EMP[products]=...; cahngement d'indice car chaque produit  a sa qté de co2 en fction du site
float EMP[products][manufacturing_plants]=...;

// nouveau cout de carbonne pour sous traitants
float eup[products][sous_traitants]=...;

// Storage capacity of product p in warehouse w
float CPW[products][warehouses]=...;

// Capital costs of establishing warehouse w
//float CCW[warehouses]=...;

// Annualized capital costs of establishing warehouse w
int ACW[warehouses]=...;

// Unit transportation costs for shipping a unit of raw material from supplier s to plant f through mode t
float TCS[raw_materials][suppliers][manufacturing_plants][trans_mode]=...;

// Distance from supplier s to plant f through mode t
float DTS[trans_mode][suppliers][manufacturing_plants]=...;

// Unit transportation costs for shipping a unit of product from plant f to warehouse w through mode t
float TCF[products][trans_mode][manufacturing_plants][warehouses]=...;

//////
float TCFS[products][trans_mode][sous_traitants][warehouses]=...;

// Distance from plant f to warehouse w through mode t
float DTF[trans_mode][manufacturing_plants][warehouses]=...;

//// distance sous traitants entrepot de stockage
float DTFS[trans_mode][sous_traitants][warehouses]=...;

// Unit transportation costs for shipping a unit of product from warehouse w to customer n through mode t
float TCW[products][trans_mode][warehouses][customers]=...;

// Distance from warehouse w to customer n through mode t
float DTW[trans_mode][warehouses][customers]=...;

// Unit CO2 emissions for shipping through mode t
float EMT[trans_mode]=...;

// Demand for product p from customer n
int DM[products][customers]=...;

// Market price per unit of CO2 emissions allowance
float cp=...;
int M = 1000000000000000;

													/* ajout de nouvelle variable pour le nouveau modèle*/

// cout de sous utilisation capacité interne
int csu[products][manufacturing_plants]=...;
//cout de stockage par produit
int kp[products][warehouses]=...;
//cout de lancement d'un produit p par site
int s[products][manufacturing_plants]=...;
//prix unitaire de matières premieres disponible chez les sous traitants
int pms[raw_materials][sous_traitants]=...;

// volume d'une MP r occupé sur un mode de transport
float vr[raw_materials]=...;

// volume d'un produit p occupé sur un mode de transport
float vp[products]=...;

float cf0[raw_materials][trans_mode][suppliers][manufacturing_plants] =...;

float cf1[products][trans_mode][manufacturing_plants][warehouses]=...;

float cf11[products][trans_mode][sous_traitants][warehouses]=...;

float cf2[products][trans_mode][warehouses][customers]=...;

int cap[trans_mode] = ...;

							/**************** Decision variables *************/
							
							
// Amount of raw material r provided by supplier s to plant f
dvar int+ AS[raw_materials][suppliers][manufacturing_plants];

// Amount of product p transported from supplier s to plant f by mode t
dvar int+ TS[raw_materials][trans_mode][suppliers][manufacturing_plants];

// Amount of product p produced by plant f
dvar int+ AF[products][manufacturing_plants];

// Amount of product p transported from plant f to warehouse w through transportation mode t
dvar int+ TF[products][trans_mode][manufacturing_plants][warehouses];

//// nombre de produits transporter des sous traitants au entrepot
dvar int+ TFS[products][trans_mode][sous_traitants][warehouses];

// Amount of product p transported from warehouse w to customer n through transportation mode t
dvar int+ TW[products][trans_mode][warehouses][customers];

// 1, If supplier is selected 0, otherwise
dvar boolean SI[suppliers];

// 1, if plant is established 0, otherwise
dvar boolean SF[manufacturing_plants];

// 1, If warehouse is established 0, otherwise
dvar boolean SW[warehouses];

												/* ajout des variables de decision du nouveau modèle */

// capacité de production non utilisé
dvar int+ SU[products][manufacturing_plants];
// capacité de production non utilisé
dvar boolean Y[products][manufacturing_plants];
// permet de dire les site de sous traitants utilisé pour la prod par produit
dvar boolean Y1[products][sous_traitants];
// quantité de matiere premieres a disposer par un sous traitant 
dvar int+ ASU[raw_materials][sous_traitants];
// quantité de produit p produit dans le site de sous traitance u
dvar int+ AFS[products][sous_traitants];
//variable binaire verifie si le sous traitants est selectionner ou pas
dvar boolean SS[sous_traitants];

//  nbre de moyens de transport utiliser pour transporter les matières premières des fournisseurs vers les clients
dvar int+ N0[suppliers][manufacturing_plants][trans_mode];

// nbre de moyens de transport utiliser pour transporter les produits des usines internes vers les entrepots
dvar int+ N01[manufacturing_plants][warehouses][trans_mode];

// nombre de moyens de transport utiliser pour transporter les produits des sous traitants vers les entrepots
dvar int+ N10[sous_traitants][warehouses][trans_mode];

// nombre de moyens de transport utiliser pour livrer les clients
dvar int+ N2[warehouses][customers][trans_mode];

							/**************** Objectif function *************/

dexpr float z = ( (sum(r in raw_materials, s in suppliers, f in manufacturing_plants) PRS[r][s]*AS[r][s][f] + 
				     cp*(sum(r in raw_materials, s in suppliers, f in manufacturing_plants) EMS[r][s]*AS[r][s][f]) + 
				     sum(s in suppliers) SLC[s]*SI[s])/* PC = The procurement costs*/ +
				     
				  (sum(f in manufacturing_plants) ACF[f]*SF[f] + 
				     sum(p in products, f in manufacturing_plants) VCF[p][f]*AF[p][f] +
				     sum(p in products, f in manufacturing_plants) s[p][f]*Y[p][f] + // cout de lancement de la production par site de production
				     cp*(sum(p in products, f in manufacturing_plants) EMP[p][f]*AF[p][f])+
				     (sum(p in products, f in manufacturing_plants) csu[p][f]*SU[p][f] /*Coût de sous utilisation interne*/)+
				     (sum(r in raw_materials, u in sous_traitants) pms[r][u]*ASU[r][u])/* cout de MP pour sous traitants*/+
				     (sum(p in products, u in sous_traitants) vcu[p][u]*AFS[p][u])/* cout de production pour sous traitants*/+
				     cp*(sum(p in products, u in sous_traitants) eup[p][u]*AFS[p][u])/* cout de co2 induit par la prod pour sous traitants*/+
				     (sum(u in sous_traitants) spl[u]*SS[u])/* cout de selection des sous-traitants*/+
				     cp*(sum(r in raw_materials, u in sous_traitants) EMSS[r][u]*ASU[r][u])/* cout co2 induit par la matière première des sous-traitants*/)/**** MC = The manufacturing *****/ +
				  
				   (sum(p in products, f in manufacturing_plants, w in warehouses) kp[p][w]*AF[p][f] + 
				     sum(p in products, u in sous_traitants, w in warehouses) kp[p][w]*AFS[p][u] + sum(w in warehouses) ACW[w]*SW[w])/****** WC = storage costs and conservation ******/ +
				  
				   (sum(r in raw_materials, t in trans_mode, s in suppliers, f in manufacturing_plants) vr[r]*TCS[r][s][f][t]*TS[r][t][s][f] +
				  	 (sum(r in raw_materials, t in trans_mode, s in suppliers, f in manufacturing_plants) cf0[r][t][s][f]*N0[s][f][t] /*cout fixe de transport/mode sup-plants*/)+
				     cp*(sum(r in raw_materials, t in trans_mode, s in suppliers, f in manufacturing_plants) EMT[t]*DTS[t][s][f]*TS[r][t][s][f]) +
				     (sum(p in products, t in trans_mode, f in manufacturing_plants, w in warehouses) cf1[p][t][f][w]*N01[f][w][t] /*cout fixe de transport/mode plant-wareh*/)+
				     (sum(p in products, t in trans_mode, u in sous_traitants, w in warehouses) cf11[p][t][u][w]*N10[u][w][t] /*cout fixe de transport/mode traitant-wareh*/)+
				     (sum(p in products, t in trans_mode, f in manufacturing_plants, w in warehouses) /*DTF[t][f][w]*/ vp[p]*TCF[p][t][f][w]*TF[p][t][f][w]) +
				     sum(p in products, t in trans_mode, u in sous_traitants, w in warehouses) TCFS[p][t][u][w]*vp[p]/*DTF[t][f][w]*/*TFS[p][t][u][w] +  /* trans sous traitant*/
				     cp*(sum(p in products, t in trans_mode, f in manufacturing_plants, w in warehouses) EMT[t]*DTF[t][f][w]*TF[p][t][f][w]) + 
				     cp*(sum(p in products, t in trans_mode, u in sous_traitants, w in warehouses) EMT[t]*DTFS[t][u][w]*TFS[p][t][u][w]) + /* sous traitant */
				     (sum(p in products, t in trans_mode, w in warehouses, n in customers) cf2[p][t][w][n]*N2[w][n][t] /*cout fixe de transport/mode wareh-client*/)+
				     (sum(p in products, t in trans_mode, w in warehouses, n in customers) TCW[p][t][w][n]*vp[p]/*DTF[t][f][w]*/*TW[p][t][w][n])+
				     cp*(sum(p in products, t in trans_mode, w in warehouses, n in customers) EMT[t]*DTW[t][w][n]*TW[p][t][w][n]) +
				     (sum(p in products, f in manufacturing_plants) csu[p][f]*SU[p][f] /*Coût de sous utilisation interne*/)/*TC = The transportation costs*/));
				     
				    
// objective		 
minimize z;				 
				     		/**************** Constraints model *************/
				     		
				     	
				     		
				     
				     

subject to {
	////La contrainte (7) garantit que la quantité de chaque matière première, r, fournie par chaque fournisseur,s, ne doit pas dépasser la capacité correspondante
	forall(r in raw_materials, s in suppliers)	
	  	c1:
		sum(f in manufacturing_plants) AS[r][s][f] <= CPS[r][s]*SI[s];
	
	//La contrainte (8) garantit que pour chaque usine, f, la quantité totale de produit, p, qu'elle produit doit être dans sa capacité pour ce produit
	forall(f in manufacturing_plants, p in products)	
	  	c2:
		AF[p][f] <= CPF[p][f]*SF[f];	
		
	////contraintes de capacité pour les sous traitants
	forall(u in sous_traitants, p in products)	
	  	c3:
		AFS[p][u] <= cpfs[p][u]*SS[u];
		
	////La contrainte (33) permet de controler la cpté de sotckage, tous se qui est transporter peut etre stocker
	forall(p in products, w in warehouses)	//s in suppliers,  p in products, 
	  	c4:
		sum(t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] + 
		sum(t in trans_mode, u in sous_traitants) TFS[p][t][u][w] <= CPW[p][w]*SW[w];
		
	////La contrainte permet de verifier que la qté de mMP vers les usines via tous les modes de transports sont equivalent
	forall(r in raw_materials, s in suppliers, f in manufacturing_plants)	//,  t in trans_mode
	  	c5: 
		AS[r][s][f] == sum(t in trans_mode) TS[r][t][s][f];
		
	//// permet de verifier qu'il y est autant de MP pour la production(contrainte d'assemblage) 
	forall(r in raw_materials, f in manufacturing_plants,  p in products)	//s in suppliers,  p in products, 
	  	c6:
		sum(p in products) (AF[p][f]*CR[r][p]) == sum(s in suppliers) AS[r][s][f];
	
	//// permet de verifier qu'il y est autant de MP pour la production(contrainte d'assemblage) 
	forall(r in raw_materials, u in sous_traitants)	//s in suppliers,  p in products, 
	  	c7:
		sum(p in products) (AFS[p][u]*CR[r][p]) == ASU[r][u];
		
	//// La contrainte (6) permet de se rassurer que la production des sites internes est acheminée vers les entrepots
	forall(p in products, f in manufacturing_plants)	// t in trans_mode, , w in warehouses
	  	c8:
		AF[p][f] == sum(t in trans_mode, w in warehouses) TF[p][t][f][w];
			
	//// La contrainte (20) permet de se rassurer que la production des sites des sous_traitants est acheminée vers les entrepots
	forall(p in products, u in sous_traitants)	// t in trans_mode, , w in warehouses
	  	c9:	
		AFS[p][u]==sum(t in trans_mode, w in warehouses) TFS[p][t][u][w];
		
	////La contrainte (7) garantie que tous les produits transportés sont les meme qui sortent vers les clients
	forall(p in products, w in warehouses)	// t in trans_mode, f in manufacturing_plants, 
	  	c10:
		sum(t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] + sum(t in trans_mode, u in sous_traitants) TFS[p][t][u][w] == sum(t in trans_mode, n in customers) TW[p][t][w][n];
	
	////La contrainte (8) impose que la sortie du produit p de l'entrepôt w vers le client n réponde à la demande de ce produit du client n
	forall(p in products, n in customers)	// t in trans_mode, w in warehouses,  
	  	c11:
		sum(t in trans_mode, w in warehouses) TW[p][t][w][n] == DM[p][n];
		
	////La contrainte (9) garantit que la production totale du produit p de toutes les usines doit répondre à la demande totale de tous les clients
	forall(p in products, n in customers)	// , f in manufacturing_plants, n in customers
	  	c12:
		sum(f in manufacturing_plants) AF[p][f] + sum(u in sous_traitants) AFS[p][u] == sum(n in customers) DM[p][n];  
	
	/**************** ajout de nouvelle contraintes Constraints model *************/
	
	//// contraintes sur la pénalité de la capacité de production non utilisé
	forall(f in manufacturing_plants, p in products)	
	  	c13:
	  	CPF[p][f] - AF[p][f] <= SU[p][f];
		//CPF[p][f] - sum(p in products) AF[p][f] <= SU[p][f];
		
	//// contraintes l'affectation de produit au différents site de produit
	forall(f in manufacturing_plants, p in products)	
	  	c14:
		AF[p][f] <= M*Y[p][f];
	
	//// contraintes l'affectation de produit au différents site de produit
	forall(u in sous_traitants, p in products)	
	  	c15:
		AFS[p][u] <= M*Y1[p][u];
		
	//// contraintes l'affectation de produit au différents site de produit
	forall(u in sous_traitants, p in products)	
	  	c16:
		Y1[p][u]<=AFS[p][u];
		
	//La contrainte (15) nombres de moyens de transport pour la matière première du fournisseurs aux usines de 
	//production en fonction du volume de la matière première/unité, la qté transportée, du moyen de transport et de sa capacité. 
	forall(r in raw_materials, s in suppliers, t in trans_mode, f in manufacturing_plants)	//s in suppliers,  p in products, 
	  	c17:
		sum(r in raw_materials) vr[r]*TS[r][t][s][f] <= N0[s][f][t]*cap[t];
	
	//La contrainte (16) nombres de moyens de transport pour les produits des usines interne au entrepot de stockage
	//en fonction du volume de produit/unité, la qté transportée, du moyen de transport et de sa capacité.
	forall(p in products, w in warehouses, t in trans_mode, f in manufacturing_plants)	//s in suppliers,  p in products, 
		c18:
		sum(p in products) vp[p]*TF[p][t][f][w] <= N01[f][w][t]*cap[t];
	
	//La contrainte (17) nombres de moyens de transport pour les produits des sous-traitants au entrepot de stockage
	//en fonction du volume de produit/unité, la qté transportée, du moyen de transport et de sa capacité.
	forall(p in products, w in warehouses, t in trans_mode, u in sous_traitants)	//s in suppliers,  p in products, 
	  	c19:
		sum(p in products) vp[p]*TFS[p][t][u][w] <= N10[u][w][t]*cap[t];
		
	//La contrainte (18) nombres de moyens de transport pour les produits des entrepots de stockage aux clients
	//en fonction du volume de produit/unité, la qté transportée, du moyen de transport et de sa capacité.
	forall(p in products, w in warehouses, t in trans_mode, n in customers)	//s in suppliers,  p in products, 
	  	c20:
		sum(p in products) vp[p]*TW[p][t][w][n] <= N2[w][n][t]*cap[t];	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//La contrainte (15) garantit que la production totale du produit p de toutes les usines doit répondre à la demande totale de tous les clients
	//forall(p in products, n in customers)	// , f in manufacturing_plants, n in customers
	  //	c9:
		//sum(f in manufacturing_plants) AF[p][f] + sum(u in sous_traitants) AFS[p][u] == sum(n in customers) DM[p][n];
	
	//La contrainte (11) représente la relation de bilan massique entre l'entrée de matière première introduite dans le processus de fabrication et la sortie de celui-ci
	//forall(r in raw_materials, u in sous_traitants, p in products)	//s in suppliers,  p in products, 
	  //	c55:
		//CR[r][p]*(sum(u in sous_traitants) ASU[r][u]) == sum(p in products) AFS[p][u];
		
	/////////////////////// putain de contrainte qui refuse de fonctionner, maintenant faut verifier 
	//forall(r in raw_materials, f in manufacturing_plants,  p in products)	//s in suppliers,  p in products, 
	  //	c999999999:
		//sum(p in products) (AF[p][f]*CR[r][p]) == sum(s in suppliers) AS[r][s][f];
		
	//// La contrainte (19) garantit que la sortie du produit p de l'usine f est égale à la quantité totale de ce produit de la même usine vers tous les entrepôts via tous les modes de transport
	//forall(p in products, u in sous_traitants, f in manufacturing_plants)	// t in trans_mode, , w in warehouses
	  //	c19:
		//AF[p][f] == sum(t in trans_mode, w in warehouses) TF[p][t][f][w];
		
	//// La contrainte (21) garantit l'ensemble des produits transporter permettent de satisfaire la demande
	//forall(p in products, u in sous_traitants, f in manufacturing_plants)	// t in trans_mode, , w in warehouses
	  //	c21:
		//AFS[p][u] + AF[p][f] == sum(t in trans_mode, w in warehouses) TF[p][t][f][w]+sum(t in trans_mode, w in warehouses) TFS[p][t][u][w];
		
	//La contrainte (13) formule le solde d'entrée et de sortie de chaque produit dans chaque entrepôt
	//forall(p in products, w in warehouses)	// t in trans_mode, f in manufacturing_plants, 
	  //	c77:
		//sum(t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] +
		//sum(t in trans_mode, u in sous_traitants) TFS[p][t][u][w] == sum(t in trans_mode, n in customers) TW[p][t][w][n];
	
/********************************************************************************************************/
		
	//La contrainte (9) applique la limitation de stockage en entrepôt selon laquelle la quantité de tous les produits envoyés à l'entrepôt w ne doit pas être supérieure à sa capacité	
	//forall(p in products, w in warehouses, f in manufacturing_plants)	//p in products, t in trans_mode, f in manufacturing_plants, 
	  //	c3:
	//	sum(p in products, t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] <= CPW[p][w]*SW[w];  
	
	
	
	//La contrainte (11) représente la relation de bilan massique entre l'entrée de matière première introduite dans le processus de fabrication et la sortie de celui-ci
	//forall(r in raw_materials, f in manufacturing_plants, u in sous_traitants, p in products)	//s in suppliers,  p in products, 
	  //	c5:
		//CR[r][p]*(sum(s in suppliers) AS[r][s][f]) + CR[r][p]*(sum(u in sous_traitants) ASU[r][u]) == sum(p in products) AF[p][f]+sum(p in products) AFS[p][u];
	
	
	
	//La contrainte (13) formule le solde d'entrée et de sortie de chaque produit dans chaque entrepôt
	//forall(p in products, w in warehouses)	// t in trans_mode, f in manufacturing_plants, 
	  //	c7:
		//sum(t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] == sum(t in trans_mode, n in customers) TW[p][t][w][n];
	
	//La contrainte (14) impose que la sortie du produit p de l'entrepôt w vers le client n réponde à la demande de ce produit du client n
	//forall(p in products, n in customers)	// t in trans_mode, w in warehouses,  
	  //	c8:
		//sum(t in trans_mode, w in warehouses) TW[p][t][w][n] == DM[p][n];
	
	//La contrainte (15) garantit que la production totale du produit p de toutes les usines doit répondre à la demande totale de tous les clients
	//forall(p in products, n in customers)	// , f in manufacturing_plants, n in customers
	 // 	c9:
	//	sum(f in manufacturing_plants) AF[p][f] == sum(n in customers) DM[p][n];  
		
}