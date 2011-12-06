
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

The group scoped object can respond to either `blank?` or `present?` which checks the group's 
target `group_id` presence or not. We use this internally so that grouped scopes only use grouping
SQL when absolutely needed.

```ruby
@employee_one = Employee.create :group_id => nil
@employee_two = Employee.create :group_id => 38

@employee_one.group.blank?   # => true
@employee_two.group.present? # => true
```

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

We always use raw SQL to get the group ids vs. mapping them to an array and using those in scopes. 
This means that large groups can avoid pushing down hundreds of keys in SQL form. So given an employee
with a `group_id` of `43` and calling `@employee.group.reports`, you would get something similar to
the following SQL.

```sql
SELECT "reports".* 
FROM "reports"  
WHERE "reports"."employee_id" IN (
  SELECT "employees"."id" 
  FROM "employees"  
  WHERE "employees"."group_id" = 43
)
```

You can pass the group scoped object as a predicate to ActiveRecord's relation interface. In past 
versions, this would have treated the group object as an array of IDs. The new behavior is to return 
a SQL literal to be used with IN statements. So note, the following would generate SQL similar to 
the one above.

```ruby
Employee.where(:group_id => @employee.group).all
```

If you need more control and you are working with the group at a lower level, you can always 
use the `#ids` or `#ids_sql` methods on the group.

```ruby
# Returns primary key array.
@employee.group.ids # => [33, 58, 240]

# Returns a Arel::Nodes::SqlLiteral object.
@employee.group.ids_sql # => 'SELECT "employees"."id" FROM "employees"  WHERE "employees"."group_id" = 33'
```


## Todo List

* Raise errors for :finder_sql/:counter_sql.
* Add a user definable group_id schema.
* Remove SelfGrouping#with_relation, has not yet proved useful.



## Testing

Simple! Just clone the repo, then run `bundle install` and `bundle exec rake`. The tests will begin to run. We also use Travis CI to run our tests too. Current build status is:

[![Build Status](https://secure.travis-ci.org/metaskills/grouped_scope.png)](http://travis-ci.org/metaskills/grouped_scope)



## License

Released under the MIT license.
Copyright (c) 2011 Ken Collins

