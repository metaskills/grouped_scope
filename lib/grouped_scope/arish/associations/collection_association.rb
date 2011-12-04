module GroupedScope
  module Arish
    module Associations
      module CollectionAssociation

        extend ActiveSupport::Concern

        module InstanceMethods
          
          def association_scope
            if reflection.grouped_scope?
              @association_scope ||= GroupedScope::Arish::Associations::AssociationScope.new(self).scope if klass
            else
              super
            end
          end

        end

      end
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.send :include, GroupedScope::Arish::Associations::CollectionAssociation
