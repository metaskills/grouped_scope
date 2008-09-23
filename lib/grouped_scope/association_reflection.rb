module GroupedScope
  class AssociationReflection < ActiveRecord::Reflection::AssociationReflection
    
    (ActiveRecord::Reflection::MacroReflection.instance_methods + 
     ActiveRecord::Reflection::AssociationReflection.instance_methods).uniq.each do |m| 
      unless m =~ /^(__|nil\?|send)|^(object_id|options|name)$/
        delegate m, :to => :ungrouped_reflection
      end
    end
    delegate :derive_class_name, :to => :ungrouped_reflection
    
    def initialize(active_record,ungrouped_name)
      @active_record = active_record
      @ungrouped_name = ungrouped_name
      @name = :"grouped_scope_#{@ungrouped_name}"
      verify_ungrouped_reflection
      super(ungrouped_reflection.macro, @name, ungrouped_reflection.options.dup, @active_record)
      create_grouped_association
    end
    
    def ungrouped_reflection
      @active_record.reflections[@ungrouped_name]
    end
    
    
    private
    
    def verify_ungrouped_reflection
      if ungrouped_reflection.blank? || ungrouped_reflection.macro.to_s !~ /has_many|has_and_belongs_to_many/
        raise ArgumentError, "Cannot create a group scope for :#{@ungrouped_name} because it is not a has_many " + 
                             "or a has_and_belongs_to_many association. Make sure to call grouped_scope after " + 
                             "the has_many associations."
      end
    end
    
    def create_grouped_association
      active_record.send :has_many, name, options
      active_record.reflections[name] = self
      active_record.grouped_scopes[@ungrouped_name] = true
      options[:grouped_scope] = true
    end
    
  end
end
