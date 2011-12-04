module GroupedScope
  module Arish
    module Associations
      module Builder
        class GroupedCollectionAssociation
          
          class << self
            
            def build(model, *association_names)
              association_names.each do |name|
                ungrouped_reflection = find_ungrouped_reflection(model, name)
                options = ungrouped_reflection_options(ungrouped_reflection)
                grouped_reflection = model.send ungrouped_reflection.macro, :"grouped_scope_#{name}", options
                grouped_reflection.grouped_scope = true
                model.grouped_reflections = model.grouped_reflections.merge(name => grouped_reflection)
              end
              define_grouped_scope_reader(model)
            end
            
            private
            
            def define_grouped_scope_reader(model)
              model.send(:define_method, :group) do
                @group ||= GroupedScope::SelfGroupping.new(self)
              end
            end
            
            def find_ungrouped_reflection(model, name)
              reflection = model.reflections[name.to_sym]
              if reflection.blank? || [:has_many, :has_and_belongs_to_many].exclude?(reflection.macro)
                msg = "Cannot create a group scope for #{name.inspect}. Either the reflection is blank or not supported. " + 
                      "Make sure to call grouped_scope after the association you are trying to extend has been defined."
                raise ArgumentError, msg
              end
              reflection
            end
            
            def ungrouped_reflection_options(ungrouped_reflection)
              ungrouped_reflection.options.dup.tap do |options|
                options[:class_name] = ungrouped_reflection.class_name
              end
            end
            
          end
          
        end
      end
    end
  end
end
