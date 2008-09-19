module GroupedScope
  module ClassMethods
    
    def grouped_scopes
      read_inheritable_attribute(:grouped_scopes) || write_inheritable_attribute(:grouped_scopes, {})
    end
    
    def grouped_scope(*args)
      belongs_to_grouped_scope_grouping
      args.each do |association|
        existing_assoc = reflect_on_association(association)
        unless existing_assoc && existing_assoc.macro == :has_many
          raise ArgumentError, "Cannot create a group scope for :#{association} because it is not a has_many " + 
                               "association. Make sure to call grouped_scope after the has_many associations."
        end
        grouped_scopes[association] = true
        has_many :"grouped_scope_#{association}", existing_assoc.options
      end
      include InstanceMethods
    end
    
    private
    
    def belongs_to_grouped_scope_grouping
      grouping_class_name = 'GroupedScope::Grouping'
      existing_grouping = reflect_on_association(:grouping)
      return false if existing_grouping && existing_grouping.macro == :belongs_to && existing_grouping.options[:class_name] == grouping_class_name
      belongs_to :grouping, :foreign_key => 'group_id', :class_name => grouping_class_name
    end
    
    
  end
end
