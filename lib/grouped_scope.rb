require 'grouped_scope/errors'
require 'grouped_scope/proxy'
require 'grouped_scope/grouping'
require 'grouped_scope/self_grouping'
require 'grouped_scope/group'
require 'grouped_scope/class_methods'
require 'grouped_scope/instance_methods'
require 'grouped_scope/has_many_association'

module GroupedScope
  
  VERSION = '1.0.0'
    
end

ActiveRecord::Base.send :extend, GroupedScope::ClassMethods
ActiveRecord::Associations::HasManyAssociation.send :include, GroupedScope::HasManyAssociation

