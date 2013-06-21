# DestroyedAt #

[![Build Status](https://secure.travis-ci.org/dockyard/destroyed_at.png?branch=master)](http://travis-ci.org/dockyard/destroyed_at)
[![Dependency Status](https://gemnasium.com/dockyard/destroyed_at.png?travis)](https://gemnasium.com/dockyard/destroyed_at)
[![Code Climate](https://codeclimate.com/github/dockyard/destroyed_at.png)](https://codeclimate.com/github/dockyard/destroyed_at)

## Looking for help? ##

If it is a bug [please open an issue on GitHub](https://github.com/dockyard/destroyed_at/issues).

## Installation ##

In your `Gemfile`

```ruby
gem 'destroyed_at'
```

You can either mixin the modules on a case-by-case basis or make the
changes global:

```ruby
class User < ActiveRecord::Base
  include DestroyedAt
end
```

or

```ruby
class ActiveRecord::Base
  include DestroyedAt
end
```

Each model's table that is expected to have this behavior **must** have
a `destroyed_at` column of type `DateTime`.

## Usage ##
Allows you to 'destroy' an object without deleting the record or
associated records.

Overides the `destroy` method to set `destroyed_at` on an object. The
default scope of the class is then set to return objects that have not
been destroyed (i.e.,have `nil` for their destroyed_at value). The
`undestroy` method can be called on an object to set its `destroyed_at`
value to `nil`.

To include this functionality on `has_many through` relationships,
be sure to `include DestroyedAt` on the through model, as well as the
parent model.

### Destroying ###
```ruby
class User < ActiveRecord::Base
  include DestroyedAt
end

user = User.create
user.destroy #=> true
```

### Undestroying ###
```ruby
class User < ActiveRecord::Base
  include DestroyedAt
end

user = User.create
user.destroy
user.undestroy #=> true
```

## Authors ##

* [Michael Dupuis](http://twitter.com/michaeldupuisjr)
* [Brian Cardarella](http://twitter.com/bcardarella)

[We are very thankful for the many contributors](https://github.com/dockyard/destroyed_at/graphs/contributors)

## Versioning ##

This gem follows [Semantic Versioning](http://semver.org)

## Want to help? ##

Please do! We are always looking to improve this gem. Please see our
[Contribution Guidelines](https://github.com/dockyard/destroyed_at/blob/master/CONTRIBUTING.md)
on how to properly submit issues and pull requests.

## Legal ##

[DockYard](http://dockyard.com), LLC &copy; 2013

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)

