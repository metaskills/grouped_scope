module GroupedScope
  class AssociationReflection < ActiveRecord::Reflection::AssociationReflection
    
    ((ActiveRecord::Reflection::AssociationReflection.instance_methods-Class.instance_methods) +
    (ActiveRecord::Reflection::AssociationReflection.private_instance_methods-Class.private_instance_methods)).each do |m| 
      undef_method(m)
    end
    
    attr_accessor :name, :options
    
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
    
    def method_missing(method, *args, &block)
      ungrouped_reflection.send(method, *args, &block)
    end
    
    def verify_ungrouped_reflection
      if ungrouped_reflection.blank? || ungrouped_reflection.macro.to_s !~ /has_many|has_and_belongs_to_many/
        raise ArgumentError, "Cannot create a group scope for :#{@ungrouped_name} because it is not a has_many " + 
                             "or a has_and_belongs_to_many association. Make sure to call grouped_scope after " + 
                             "the has_many associations."
      end
    end
    
    def create_grouped_association
      active_record.send(macro, name, options)
      association_proxy_class = options[:through] ? ActiveRecord::Associations::HasManyThroughAssociation : ActiveRecord::Associations::HasManyAssociation
      active_record.send(:collection_reader_method, self, association_proxy_class)
      
      active_record.reflections[name] = self
      active_record.grouped_scopes[@ungrouped_name] = true
      options[:grouped_scope] = true
    end
    
  end
end
