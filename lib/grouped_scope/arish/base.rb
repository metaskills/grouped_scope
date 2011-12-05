module GroupedScope
  module Arish
    module Base

      extend ActiveSupport::Concern

      included do
        class_attribute :grouped_reflections, :instance_reader => false, :instance_writer => false
        self.grouped_reflections = {}.freeze
      end

      module ClassMethods

        def grouped_scope(*association_names)
          Associations::Builder::GroupedCollectionAssociation.build(self, *association_names)
        end

      end

    end
  end
end

ActiveRecord::Base.send :include, GroupedScope::Arish::Base
