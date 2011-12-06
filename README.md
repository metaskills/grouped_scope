
# GroupedScope: Has Many Associations IN (GROUPS)

GroupedScope aims to make two things easier in your ActiveRecord models. First, provide an 
easy way to group objects. Second, to allow the group to share association collections via existing 
has_many relationships. See installation and usage for more details.

http://metaskills.net/2008/09/28/jack-has_many-things/



## Installation

Install the gem with bundler. We follow a semantic versioning format that tracks ActiveRecord's minor version. So this means to use the latest 3.1.x version of GroupedScope with any ActiveRecord 3.1 version.

```ruby
gem 'grouped_scope', '~> 3.1.0'
```


## Setup

To use GroupedScope on a model it must have a `:group_id` column.

```ruby
class AddGroupId < ActiveRecord::Migration
  def up
    add_column :employees, :group_id, :integer
  end
  def down
    remove_column :employees, :group_id
  end
end
```


## General Usage

Assume the following model.

```ruby
class Employee < ActiveRecord::Base
  has_many :reports
  grouped_scope :reports
end
```

By calling grouped_scope on any association you create a new group accessor for each 
instance. The object returned will act just like an array and at least include the 
current object that called it.

```ruby
@employee_one.group   # => [#<Employee id: 1, group_id: nil>]
```

To group resources, just assign the same `:group_id` to each record in that group.

```ruby
@employee_one.update_attribute :group_id, 1
@employee_two.update_attribute :group_id, 1
@employee_one.group   # => [#<Employee id: 1, group_id: 1>, #<Employee id: 2, group_id: 1>]
```

Calling grouped_scope on the :reports association leaves the existing association intact.

```ruby
@employee_one.reports  # => [#<Report id: 2, employee_id: 1>]
@employee_two.reports  # => [#<Report id: 18, employee_id: 2>, #<Report id: 36, employee_id: 2>]
```

Now the good part, all associations passed to the grouped_scope method can be called 
on the group proxy. The collection will return resources shared by the group.

```ruby
@employee_one.group.reports # => [#<Report id: 2, employee_id: 1>, 
                                  #<Report id: 18, employee_id: 2>, 
                                  #<Report id: 36, employee_id: 2>]
```

You can even call scopes or association extensions defined on the objects in the collection
defined on the original association. For instance:

```ruby
@employee.group.reports.urgent.assigned_to(user)
```


## Advanced Usage

The object returned by the `#group` method is an ActiveRecord relation on the targets class, 
in this case `Employee`. Given this, you can further scope the grouped proxy if needed. Below,
we use the `:email_present` scope to refine the group down.

```ruby
class Employee < ActiveRecord::Base
  has_many :reports
  grouped_scope :reports
  scope :email_present, where("email IS NOT NULL")
end

@employee_one = Employee.create :group_id => 5, :name => 'Ken'
@employee_two = Employee.create :group_id => 5, :name => 'MetaSkills', :email => 'ken@metaskills.net'

# Only one employee is returned now.
@employee_one.group.email_present # => [#<Employee id: 1, group_id: 5, name: 'MetaSkills', email: 'ken@metaskills.net']
```






## Todo List

* Make group association conditions use pure SQL. Avoid many ids. Deprecate #quoted_ids.
* Raise errors for :finder_sql/:counter_sql.
* Add a user definable group_id schema.
* Make SelfGrouping use targeted relation class for #primary_key.



## Testing

Simple! Just clone the repo, then run `bundle install` and `bundle exec rake`. The tests will begin to run. We also use Travis CI to run our tests too. Current build status is:

[![Build Status](https://secure.travis-ci.org/metaskills/grouped_scope.png)](http://travis-ci.org/metaskills/grouped_scope)



## License

Released under the MIT license.
Copyright (c) 2011 Ken Collins

