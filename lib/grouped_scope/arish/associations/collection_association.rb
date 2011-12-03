module GroupedScope
  module Arish
    module Associations
      module CollectionAssociation

        extend ActiveSupport::Concern

        module InstanceMethods

          def association_scope
            if klass
              @association_scope ||= GroupedScope::Associations::AssociationScope.new(self).scope
            end
          end

        end

      end
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.send :include, GroupedScope::Arish::Associations::CollectionAssociation
