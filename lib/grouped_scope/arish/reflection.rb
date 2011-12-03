module GroupedScope
  module Arish
    module Reflection
      module AssociationReflection
        
        extend ActiveSupport::Concern
        
        included do
          attr_accessor :grouped_scope
          alias :grouped_scope? :grouped_scope
        end

      end
    end
  end
end

ActiveRecord::Reflection::AssociationReflection.send :include, GroupedScope::Arish::Reflection::AssociationReflection
