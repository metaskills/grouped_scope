require 'grouped_scope/errors'
require 'grouped_scope/proxy'
require 'grouped_scope/grouping'
require 'grouped_scope/group'

module GroupedScope
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    
    def grouped_scopes
      read_inheritable_attribute(:grouped_scopes) || write_inheritable_attribute(:grouped_scopes, {})
    end
    
    def grouped_scope(*args)
      belongs_to :grouping, :foreign_key => 'group_id', :class_name => 'GroupedScope::Grouping'
      args.each do |association|
        ung_assoc = reflect_on_association(association)
        unless ung_assoc && ung_assoc.macro == :has_many
          raise ArgumentError, "Cannot create a group scope for :#{association} because it is not a has_many association."
        end
        group_association = "group_#{association}".to_sym
        grouped_scopes[group_association] = true
        group_association_options = {:class_name => ung_assoc.class_name, :foreign_key => ung_assoc.primary_key_name}
        group_association_options.merge!(ung_assoc.options)
        has_many group_association, group_association_options
      end
      include InstanceMethods
    end
    
  end
  
  module InstanceMethods
    
    def group
      @group ||= Group.new(self)
    end
    
  end
  
  module HasManyAssociation
    
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :construct_sql, :group_scope
      end
    end

    def construct_sql_with_group_scope
      if @owner.class.grouped_scopes[@reflection.name]
        @finder_sql = "#{@reflection.klass.table_name}.#{@reflection.primary_key_name} IN (#{@owner.group.quoted_ids})"
        @finder_sql << " AND (#{conditions})" if conditions
        @counter_sql = @finder_sql
      else
        construct_sql_without_group_scope
      end
    end
    
  end
  
end


ActiveRecord::Base.send :include, GroupedScope
ActiveRecord::Associations::HasManyAssociation.send :include, GroupedScope::HasManyAssociation


