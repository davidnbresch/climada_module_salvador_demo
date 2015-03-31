####Welcome to the ***climada additional module*** salvador_demo

#####If you are already familiar with the core ***climada***, dive into this additonal module focusing on San Salvador, El Salvador.  
* Read the Salvador specific introduction document for [tropical cyclones](/blob/master/docs/climada_module_salvador_demo.pdf?raw=true) and for [storm surge](/blob/master/docs/climada_module_salvador_demo_storm_surge.pdf?raw=true).
* See an [example video](../../../climada/wiki/NatCat-modelling#example-hurricane-sidr-affects-bangladesh) of Hurricane Sidr affecting Bangladesh. 


#####Get to know ***climada***
* Go to the [wiki](../../../climada/wiki/Home) and read the [introduction](../../../climada/wiki/Home) and find out what _**climada**_ and ECA is. 
* Are you ready to start adapting? This wiki page helps you to [get started!](../../../climada/wiki/Getting-started)  
* Read more on [natural catastrophe modelling](../../../climada/wiki/NatCat-modelling) and look at the GUI that we have prepared for you.
* Read the [core ***climada*** manual (PDF)](../../../climada/docs/climada_manual.pdf?raw=true).



<br>

#####climada_module_salvador_demo

San Salvador, El Salvador, demo module for tropical cyclone - really just a demo, all numbers and results are for demonstration purposes only.

This module contains the additional climada module to implement a demo tropical cyclone hazard event set for San Salvador in El Salvador.

Please install climada core first, see https://github.com/davidnbresch/climada

In order to grant core climada access to additional modules, create a folder 'modules' in the core climada folder and copy/move any additional modules into climada/modules, without 'climada_module_' in the filename. 

E.g. if the addition module is named climada_module_MODULE_NAME, we should have
* .../climada the core climada, with sub-folders as
* .../climada/code
* .../climada/data
* .../climada/docs   
 
and then .../climada/modules/MODULE_NAME with contents such as  
* .../climada/modules/MODULE_NAME/code
* .../climada/modules/MODULE_NAME/data
* .../climada/modules/MODULE_NAME/docs    

This way, climada sources the code of all modules upon startup. See [climada/docs/climada_manual.pdf](../../../climada/docs/climada_manual.pdf?raw=true) to get started

<br>

copyright (c) 2015, David N. Bresch, david.bresch@gmail.com all rights reserved.


