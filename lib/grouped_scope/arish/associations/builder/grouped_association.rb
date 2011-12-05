module GroupedScope
  module Arish
    module Associations
      module Builder
        class GroupedAssociation
          
          attr_reader :model, :ungrouped_name, :ungrouped_reflection, :grouped_name, :grouped_options
          
          def self.build(model, *association_names)
            association_names.each { |ungrouped_name| new(model, ungrouped_name).build }
          end
          
          def initialize(model, ungrouped_name)
            @model = model
            @ungrouped_name = ungrouped_name
            @ungrouped_reflection = find_ungrouped_reflection
            @grouped_name = :"grouped_scope_#{ungrouped_name}"
            @grouped_options = copy_ungrouped_reflection_options
          end
          
          def build
            model.send(ungrouped_reflection.macro, grouped_name, grouped_options).tap do |grouped_reflection|
              grouped_reflection.grouped_scope = true
              model.grouped_reflections = model.grouped_reflections.merge(ungrouped_name => grouped_reflection)
              define_grouped_scope_reader(model)
            end
          end
          
          
          private
          
          def define_grouped_scope_reader(model)
            model.send(:define_method, :group) do
              @group ||= GroupedScope::SelfGroupping.new(self)
            end
          end
          
          def find_ungrouped_reflection
            model.reflections[ungrouped_name]
          end
          
          def copy_ungrouped_reflection_options
            ungrouped_reflection.options.dup
          end
          
        end
      end
    end
  end
end
