## 2.0.0
* Associated models that do not include `DestroyedAt` will now be
  **deleted** via `dependent: :destroy`. Previously, this was only the
behavior for child records; however, child records can now delete the
parent record (in accordance with default ActiveRecord behavior).

## 1.0.2
* Fixes an issue in which
  `DestroyedAt::BelongsToAssociation#handle_dependency` was not deriving
the action from the `options` hash, but was using `method` and raising
an error for the wrong number of arguments. Thanks to
[harmdewit](https://github.com/harmdewit) for catching this!

## 1.0.1
* Fixes an issue where the incorrect arguments were being passed
  from inside the `BelongsToAssociation` and `HasOneAssociation`, as
reported by [anarchocurious](https://github.com/anarchocurious)

## 1.0.0

* Requires equal to or greater than Ruby `2.0` -
  [ryanwood](https://github.com/ryanwood)
* Updates `reflections` to `_reflections` -
  [mukimov](https://github.com/mukimov)
* Fixes an exception which was was raised when attempting to destroy a 
target record whose parent did not mix in DestroyedAt.

## 0.4.0

* Updates for Rails 4.1
* Removes `.with_default_scope` which has been deprecated.
* Enables retrieval of destroyed objects by time via `.destroyed`
  method, which now takes an optional time attribute. - [linstula](https://github.com/linstula) & [danmcclain](https://github.com/danmcclain)
* Removes `m` as a development dependency, since it is not compatible
  with `minitest 5`.

## 0.3.1
**Stable for Rails 4.0**

* [Bug] Fixed route not raising when resource constant does not exist -
  [bcardarella](https://github.com/bcardarella)

## 0.3.0

* Fix issue with has_many destroy against regular models - [bcardarella](https://github.com/bcardarella)
* Relation.destoyed removes the destoyed scope and adds a scope 
  for records that have been destoyed -
[danmcclain](https://github.com/danmcclain)
* Added /restore route for restorable resources - [bcardarella](https://github.com/bcardarella) &
  [rsocci](https://github.com/rsocci)
