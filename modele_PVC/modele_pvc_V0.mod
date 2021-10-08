/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 15 sept. 2021 at 12:33:40
 *********************************************/

 	// indices du modèle
int S = ...; 		// Index of suppliers
int R = ...; 		// Index of raw materials
int F = ...;		// Index of manufacturing plants
int P = ...;		// Index of products
int W = ...; 		// Index of warehouses
int T = ...; 		// Index of transportation modes
int N = ...; 		// Index of customers

// parcours de tous les indices

range suppliers = 1..S;
range raw_materials = 1..R;
range manufacturing_plants = 1..F;
range products = 1..P;
range warehouses = 1..W;
range trans_mode = 1..T;
range customers = 1..N;

								/******************************** Model parameters *********************/

// Capacity of raw material r provided by supplier s
float CPS[raw_materials][suppliers]=...;

// Selection costs of supplier s
float SLC[suppliers]=...;

// Life cycle CO2 emissions per unit of raw material r provided by supplier s
//float ems[raw_materials][suppliers]=...;

// Price per unit of raw material r provided by supplier s
float PRS[raw_materials][suppliers]=...;

// Conversion rate of raw material r to product p
float CR[raw_materials][products]=...;

// Capacity of product p produced by plant f
float CPF[products][manufacturing_plants]=...;

// Capital costs of establishing plant f
//float CCF[manufacturing_plants]=...;

// Annualized capital costs of establishing plant f
float ACF[manufacturing_plants]=...;

// Variable costs of producing one unit of product p
float VCF[products]=...;

// CO2 emissions for producing one unit of product p
float EMP[products]=...;

// Storage capacity of product p in warehouse w
float CPW[products][warehouses]=...;

// Capital costs of establishing warehouse w
//float CCW[warehouses]=...;

// Annualized capital costs of establishing warehouse w
float ACW[warehouses]=...;

// Unit transportation costs for shipping a unit of raw material from supplier s to plant f through mode t
float TCS[suppliers][manufacturing_plants][trans_mode]=...;

// Distance from supplier s to plant f through mode t
float DTS[trans_mode][suppliers][manufacturing_plants]=...;

// Unit transportation costs for shipping a unit of product from plant f to warehouse w through mode t
float TCF[trans_mode][manufacturing_plants][warehouses]=...;

// Distance from plant f to warehouse w through mode t
float DTF[trans_mode][manufacturing_plants][warehouses]=...;

// Unit transportation costs for shipping a unit of product from warehouse w to customer n through mode t
float TCW[trans_mode][warehouses][customers]=...;

// Distance from warehouse w to customer n through mode t
float DTW[trans_mode][warehouses][customers]=...;

// Unit CO2 emissions for shipping through mode t
float EMT[trans_mode]=...;

// Demand for product p from customer n
float DM[products][customers]=...;

// Market price per unit of CO2 emissions allowance
float cp=...;


							/**************** Decision variables *************/
							
							
// Amount of raw material r provided by supplier s to plant f
dvar float+ AS[raw_materials][suppliers][manufacturing_plants];

// Amount of product p transported from supplier s to plant f by mode t
dvar float+ TS[raw_materials][trans_mode][suppliers][manufacturing_plants];

// Amount of product p produced by plant f
dvar float+ AF[products][manufacturing_plants];

// Amount of product p transported from plant f to warehouse w through transportation mode t
dvar float+ TF[products][trans_mode][manufacturing_plants][warehouses];

// Amount of product p transported from warehouse w to customer n through transportation mode t
dvar float+ TW[products][trans_mode][warehouses][customers];

// 1, If supplier is selected 0, otherwise
dvar boolean SI[suppliers];

// 1, if plant is established 0, otherwise
dvar boolean SF[manufacturing_plants];

// 1, If warehouse is established 0, otherwise
dvar boolean SW[warehouses];


							/**************** Objectif function *************/

dexpr float z = ( (sum(r in raw_materials, s in suppliers, f in manufacturing_plants) PRS[r][s]*AS[r][s][f] + 
				     cp*(sum(r in raw_materials, s in suppliers, f in manufacturing_plants) AS[r][s][f]) + 
				     sum(s in suppliers) SLC[s]*SI[s])/* PC = The procurement costs*/ +
				  (sum(f in manufacturing_plants) ACF[f]*SF[f] + 
				     sum(p in products, f in manufacturing_plants) VCF[p]*AF[p][f] +
				     cp*(sum(p in products, f in manufacturing_plants) EMP[p]*AF[p][f]) + 
				     sum(w in warehouses) ACW[w]*SW[w])/* MC = The manufacturing and storage costs*/ +
				  (sum(r in raw_materials, t in trans_mode, s in suppliers, f in manufacturing_plants) DTS[t][s][f]*TCS[s][f][t]*TS[r][t][s][f] +
				     cp*(sum(r in raw_materials, t in trans_mode, s in suppliers, f in manufacturing_plants) EMT[t]*DTS[t][s][f]*TS[r][t][s][f]) +
				     sum(p in products, t in trans_mode, f in manufacturing_plants, w in warehouses) TCF[t][f][w]*DTF[t][f][w]*TF[p][t][f][w] +  
				     cp*(sum(p in products, t in trans_mode, f in manufacturing_plants, w in warehouses) EMT[t]*DTF[t][f][w]*TF[p][t][f][w]) + 
				     sum(p in products, t in trans_mode, w in warehouses, n in customers) TCW[t][w][n]*DTW[t][w][n]*TW[p][t][w][n] + 
				     cp*(sum(p in products, t in trans_mode, w in warehouses, n in customers) EMT[t]*DTW[t][w][n]*TW[p][t][w][n]) /*TC = The transportation costs*/));
				     
// objective		 
minimize z;				 
				     		/**************** Constraints model *************/
				     		

subject to {
	//La contrainte (7) garantit que la quantité de chaque matière première, r, fournie par chaque fournisseur,s, ne doit pas dépasser la capacité correspondante
	forall(r in raw_materials, s in suppliers)	
	  	c1:
		sum(f in manufacturing_plants) AS[r][s][f] <= CPS[r][s]*SI[s];
	
	//La contrainte (8) garantit que pour chaque usine, f, la quantité totale de produit, p, qu'elle produit doit être dans sa capacité pour ce produit
	forall(f in manufacturing_plants, p in products)	
	  	c2:
		sum(p in products) AF[p][f] <= CPF[p][f]*SF[f];	
		
	//La contrainte (9) applique la limitation de stockage en entrepôt selon laquelle la quantité de tous les produits envoyés à l'entrepôt w ne doit pas être supérieure à sa capacité	
	forall(p in products, w in warehouses, f in manufacturing_plants)	//p in products, t in trans_mode, f in manufacturing_plants, 
	  	c3:
		sum(p in products, t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] <= CPW[p][w]*SW[w];  
	
	//La contrainte (10) montre que la quantité de chaque matière première r du fournisseur s à l'usine f est égale à la quantité totale de cette matière première r transportée par tous les modes entre les mêmes nœuds
	forall(r in raw_materials, s in suppliers, f in manufacturing_plants)	//,  t in trans_mode
	  	c4: 
		AS[r][s][f] == sum(t in trans_mode) TS[r][t][s][f];
	
	//La contrainte (11) représente la relation de bilan massique entre l'entrée de matière première introduite dans le processus de fabrication et la sortie de celui-ci
	forall(r in raw_materials, f in manufacturing_plants,  p in products)	//s in suppliers,  p in products, 
	  	c5:
		CR[r][p]*(sum(s in suppliers) AS[r][s][f]) == sum(p in products) AF[p][f];
	
	// La contrainte (12) garantit que la sortie du produit p de l'usine f est égale à la quantité totale de ce produit de la même usine vers tous les entrepôts via tous les modes de transport
	forall(p in products, f in manufacturing_plants)	// t in trans_mode, , w in warehouses
	  	c6:
		AF[p][f] == sum(t in trans_mode, w in warehouses) TF[p][t][f][w];
	
	//La contrainte (13) formule le solde d'entrée et de sortie de chaque produit dans chaque entrepôt
	forall(p in products, w in warehouses)	// t in trans_mode, f in manufacturing_plants, 
	  	c7:
		sum(t in trans_mode, f in manufacturing_plants) TF[p][t][f][w] == sum(t in trans_mode, n in customers) TW[p][t][w][n];
	
	//La contrainte (14) impose que la sortie du produit p de l'entrepôt w vers le client n réponde à la demande de ce produit du client n
	forall(p in products, n in customers)	// t in trans_mode, w in warehouses,  
	  	c8:
		sum(t in trans_mode, w in warehouses) TW[p][t][w][n] == DM[p][n];
	
	//La contrainte (15) garantit que la production totale du produit p de toutes les usines doit répondre à la demande totale de tous les clients
	forall(p in products, n in customers)	// , f in manufacturing_plants, n in customers
	  	c9:
		sum(f in manufacturing_plants) AF[p][f] == sum(n in customers) DM[p][n];  

}