module GroupedScope
  module Arish
    module Associations
      module Builder
        class GroupedCollectionAssociation < GroupedAssociation
          
          private
          
          def find_ungrouped_reflection
            reflection = model.reflections[ungrouped_name]
            if reflection.blank? || [:has_many, :has_and_belongs_to_many].exclude?(reflection.macro)
              msg = "Cannot create a group scope for #{ungrouped_name.inspect}. Either the reflection is blank or not supported. " + 
                    "Make sure to call grouped_scope after the association you are trying to extend has been defined."
              raise ArgumentError, msg
            end
            reflection
          end
          
          def copy_ungrouped_reflection_options
            ungrouped_reflection.options.dup.tap do |options|
              options[:class_name] = ungrouped_reflection.class_name
              if ungrouped_reflection.source_reflection && options[:source].blank?  
                options[:source] = ungrouped_reflection.source_reflection.name 
              end
            end
          end
          
        end
      end
    end
  end
end
