# DestroyedAt #

[![Build Status](https://secure.travis-ci.org/dockyard/destroyed_at.png?branch=master)](http://travis-ci.org/dockyard/destroyed_at)
[![Dependency Status](https://gemnasium.com/dockyard/destroyed_at.png?travis)](https://gemnasium.com/dockyard/destroyed_at)
[![Code Climate](https://codeclimate.com/github/dockyard/destroyed_at.png)](https://codeclimate.com/github/dockyard/destroyed_at)

## Looking for help? ##

If it is a bug [please open an issue on GitHub](https://github.com/dockyard/destroyed_at/issues).

## Installation ##

Add the `destroyed_at` gem to your `Gemfile`

```ruby
gem 'destroyed_at'
```

You can either mixin the modules on a case-by-case basis:

```ruby
class User < ActiveRecord::Base
  include DestroyedAt
end
```

or make the changes globally:

```ruby
class ActiveRecord::Base
  include DestroyedAt
end
```

**Please note you will need to make a migration**

Each model's table that is expected to have this behavior **must** have
a `destroyed_at` column of type `DateTime`.

## Usage ##
Allows you to "destroy" an object without deleting the record or
associated records.

### Destroying ###
Overides `#destroy` to set `#destroyed_at` to the current time on an object. The
default scope of the class is then set to return objects that have not
been destroyed (i.e., have `nil` for their destroyed_at value).

`#destroyed?` will be `true` when your model is destroyed; it will be
`false` when your model has been undestroyed.

```ruby
class User < ActiveRecord::Base
  include DestroyedAt
end

user = User.create
user.destroy 
# => true
user.destroyed_at
# => <DateTime>
```

### Undestroying ####
When you'd like to "undestroy" a record, call the `#undestroy` method on
the instance. This will set its `#destroyed_at` value to `nil`, thereby
including it in the default scope of the class again.

To include this functionality on `has_many through` relationships,
be sure to `include DestroyedAt` on the through model, as well as the
parent model.

```ruby
class User < ActiveRecord::Base
  include DestroyedAt
end

user = User.create
user.destroy
user.undestroy
# => true
user.destroyed_at
# => nil
```

#### Callbacks ####
`before_undestroy` and `after_undestroy` callbacks are added to your
model. They work similarly to the `before_destroy` and `after_destroy`
callbacks.

```ruby
class User < ActiveRecord::Base
  before_understroy :before_undestroy_action
  after_undestroy   :after_undestroy_action
  
  private
  
  def before_undestroy_action
    ...
  end
  
  def after_undestroy_action
    ...
  end
end
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

