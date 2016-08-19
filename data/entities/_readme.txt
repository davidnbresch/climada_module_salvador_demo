contains the full entities for San Salvador, plus a TEST file. 

In order to TEST:
1) copy FL_entity_Acelhuate_TEST.xls (and .xlsx) to your local climada data folder 
(either ../climada/data or ../climada_data)
(there are .xls and .xslx as it might depend which one your local OS likes better)
2) also copy ../hazards/Salvador_hazard_FL_2015.mat to your local climada data folder
(either ../climada/data or ../climada_data)
3) then start climada and run
>> hazard=climada_hazard_load('Salvador_hazard_FL_2015');
>> entity=climada_entity_read('FL_entity_Acelhuate_TEST',hazard);
Note: if you encounter troubles Excel files in climada, see at the bottom of this .txt file
>> measures_impact=climada_measures_impact(entity,hazard,'no’);
>> climada_adaptation_cost_curve(measures_impact);

last command should result in output as (and a figure):

FL_entity_Acelhuate_TEST | Salvador_hazard_FL_2015 :
 Measure 		    Cost (USD mio)    Benefit (USD mio)  Benefit/Cost
 Sanitarios de descarga Du 0.27              15               3.8e+02
 Sanitarios de descarga Du 0.093             14               1.5e+02
 Ahorradores en Agua en ca 0.41              15               1.3e+02
 Ahorradores en Agua en ca 0.14              15               1.1e+02
 No descargas en Lluvia (A 0.12              16                 57
 No descargas en Lluvia (B 0.042             16                 53
 Reuso de agua de enjuage  0.31              14                 46
 Reuso de agua de enjuage  0.26              15                 39
 Puentes sin basura (A)     1.1              15                 36
 Puentes sin basura (B)    0.38              15                 13
 Captacion de agua de tech  5.3              20                8.2
 Captacion de agua de tech  1.8              15                3.8
 *Residual damage                         *-1.3e+02*


Excel hint: in case you do get WARN and Error(s) after calling entity=climada_entity_read and/or if entity does only contain entity.assets.filenamem, please proceed as follows: Open the Excel file in Excel and save it under a new name, then delete the (now old) original Excel file and rename the one yu saved under a new name to the old name (in your file system), this usually fixes the issue with Excel.

copyright (c) 2016, David N. Bresch, david.bresch@gmail.com
all rights reserved.
