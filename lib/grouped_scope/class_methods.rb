module GroupedScope
  module ClassMethods
    
    def grouped_scopes
      read_inheritable_attribute(:grouped_scopes) || write_inheritable_attribute(:grouped_scopes, {})
    end
    
    def grouped_scope(*associations)
      create_belongs_to_for_grouped_scope
      associations.each { |association| AssociationReflection.new(self,association) }
      create_grouped_scope_accessor
    end
    
    private
    
    def create_grouped_scope_accessor
      define_method(:group) do
        @group ||= SelfGroupping.new(self)
      end
    end
    
    def create_belongs_to_for_grouped_scope
      grouping_class_name = 'GroupedScope::Grouping'
      existing_grouping = reflections[:grouping]
      return false if existing_grouping && existing_grouping.macro == :belongs_to && existing_grouping.options[:class_name] == grouping_class_name
      belongs_to :grouping, :foreign_key => 'group_id', :class_name => grouping_class_name
    end
    
  end
end
