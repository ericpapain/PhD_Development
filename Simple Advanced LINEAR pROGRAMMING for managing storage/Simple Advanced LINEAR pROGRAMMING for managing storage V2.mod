/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epmezatio
 * Creation Date: 23 août 2021 at 17:46:47
 *********************************************/

 {string} cargos=...; // cargo name
 {string} comps=...; // compartments name
 
 tuple cargoType{
   float avaible_weight;
   float volume_per_ton;
   float profit_per_ton;
 }
 
 tuple compType{
   float weight_cap;
   float space_cap;
 }
 
 cargoType cargosData[cargos]=...;
 compType compsData[comps]=...;
 
 // variables de décision 
 
 dvar float+ x[cargos][comps];
 dvar float+ y;
 
 //expressions 
 
 dexpr float TotalProfit = sum(i in cargos, j in comps) cargosData[i].profit_per_ton*x[i][j];
 dexpr float SpaceUsedPerComp[j in comps] = sum(i in cargos) cargosData[i].volume_per_ton*x[i][j];
 dexpr float WeightUsedPerComp[j in comps] = sum(i in cargos) x[i][j];
 
 // definition du model
 
 maximize TotalProfit;
 
 subject to  {
   forall(i in cargos)
    available_weight:
    sum(j in comps) x[i][j] <= cargosData[i].avaible_weight;
    
    forall(j in comps)
    weight_capacity:
    WeightUsedPerComp[j] <= compsData[j].weight_cap;

  forall(j in comps)
    space_capacity:
    SpaceUsedPerComp[j] <= compsData[j].space_cap;
    
  forall(j in comps)
    balanced_plane:
    WeightUsedPerComp[j] / compsData[j].weight_cap == y;
 }