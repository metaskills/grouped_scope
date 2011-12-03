module GroupedScope
  module Arish
    module Base

      extend ActiveSupport::Concern

      included do
        class_attribute :grouped_scopes, :instance_reader => false, :instance_writer => false
        self.grouped_scopes = {}
      end

      module ClassMethods

        def grouped_scope(*association_names)
          GroupedScope::Arish::Associations::Builder::GroupedScope.build(self, *association_names)
        end

      end

    end
  end
end

ActiveRecord::Base.send :include, GroupedScope::Arish::Base
