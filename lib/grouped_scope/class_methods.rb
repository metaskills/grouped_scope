module GroupedScope
  module ClassMethods
    
    def grouped_scopes
      read_inheritable_attribute(:grouped_scopes) || write_inheritable_attribute(:grouped_scopes, {})
    end
    
    def grouped_scope(*args)
      belongs_to_grouped_scope_grouping
      args.each do |association|
        ung_assoc = reflect_on_association(association)
        unless ung_assoc && ung_assoc.macro == :has_many
          raise ArgumentError, "Cannot create a group scope for :#{association} because it is not a has_many association."
        end
        grouped_scopes[association] = true
        group_association_options = {:class_name => ung_assoc.class_name, :foreign_key => ung_assoc.primary_key_name}
        group_association_options.merge!(ung_assoc.options)
        has_many "group_#{association}".to_sym, group_association_options
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
