Author: Stephen Kac [Updated May 14, 2019] (Revision 0.1)

#  Introduction

When creating a data centric program creating an efficient means to change, search for, or loop over large quanitites of objects takes lots of design time and introduces lots of bugs and race conditions in conccurent programming and access of data. Entity Components and Systems provide the foundation and structure for efficient search, concurrent access, and looping of lots of data.

## The Entities and Their Components.

First you start with 4 types of data that are needed for your program. Theses types are neatly packed in buffers for each type and each instance of the type is assigned to *Entities* which are represented by simple Integers like so: 

![EntitiesWithTypes](/Users/stephenkac/Documents/🛠 Developer/Ember WorkSpace/EmberEngineWorkSpace/SAKECS/Resources/EntitiesWithTypes.jpg)

These 4 entities are represented by the integers 1, 2, 3 , 4. Entity 1 has the types A, B and C assigned to it. A, B and C is any simple value type. These types, in general, will only have 1 to 3 variables. These types are known as *Components*.

To sum up , *Entities* are integers that are used to define groups of components which are stored within buffers of like kind.

## The Systems

Systems are simple classes  that execute using a subset of an Entities components. Systems are like functions in the sense that they perform a specific purpose and only gets the data required for that purpose.



A system can either run on the data provide

