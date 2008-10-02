
class ActiveRecord::Base
  
  class << self
    
    private
    
    def attribute_condition_with_grouped_scope(argument)
      case argument
        when GroupedScope::SelfGroupping then "IN (?)"
        else attribute_condition_without_grouped_scope(argument)
      end
    end
    
    alias_method_chain :attribute_condition, :grouped_scope
    
  end
  
end


