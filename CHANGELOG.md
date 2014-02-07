## 0.4.0
* Enables retrieval of destroyed objects by time via `.destroyed`
  method, which now takes an optional time attribute. - Lin Reid & Dan
McClain

## 0.3.1

* [Bug] Fixed route not raising when resource constant does not exist -
  Brian Cardarella

## 0.3.0

* Fix issue with has_many destroy against regular models - Brian
  Cardarella
* Relation.destoyed removes the destoyed scope and adds a scope 
  for records that have been destoyed - Dan McClain
* Added /restore route for restorable resources - Brian Cardarella &
  Romina Vargas
