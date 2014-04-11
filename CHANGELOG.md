## 0.4.0

* Updates for Rails 4.1
* Removes `.with_default_scope` which has been deprecated.
* Enables retrieval of destroyed objects by time via `.destroyed`
  method, which now takes an optional time attribute. - Lin Reid & Dan
McClain
* Removes `m` as a development dependency, since it is not compatible
  with `minitest 5`.

## 0.3.1
**Stable for Rails 4.0**

* [Bug] Fixed route not raising when resource constant does not exist -
  Brian Cardarella

## 0.3.0

* Fix issue with has_many destroy against regular models - Brian
  Cardarella
* Relation.destoyed removes the destoyed scope and adds a scope 
  for records that have been destoyed - Dan McClain
* Added /restore route for restorable resources - Brian Cardarella &
  Romina Vargas
