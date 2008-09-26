module GroupedScope
  module HasManyThroughAssociation
    
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :construct_conditions, :group_scope
      end
    end
    
    def construct_conditions_with_group_scope
      conditions = construct_conditions_without_group_scope
      if @reflection.options[:grouped_scope]
        if as = @reflection.options[:as]
          # TODO: Need to add case for polymorphic :as option.
        else
          pattern = "#{@reflection.primary_key_name} = #{@owner.quoted_id}"
          replacement = "#{@reflection.primary_key_name} IN (#{@owner.group.quoted_ids})"
          conditions.sub!(pattern,replacement)
        end
      end
      conditions
    end
    
    
  end
end

ActiveRecord::Associations::HasManyThroughAssociation.send :include, GroupedScope::HasManyThroughAssociation
