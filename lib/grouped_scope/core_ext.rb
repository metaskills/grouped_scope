
class ActiveRecord::Base
  
  class << self
    
    private
    
    def attribute_condition_with_grouped_scope(*args)
      if ActiveRecord::VERSION::STRING >= '2.3.0'
        quoted_column_name, argument = args
        case argument
          when GroupedScope::SelfGroupping then "#{quoted_column_name} IN (?)"
          else attribute_condition_without_grouped_scope(quoted_column_name,argument)
        end
      else
        argument = args.first
        case argument
          when GroupedScope::SelfGroupping then "IN (?)"
          else attribute_condition_without_grouped_scope(argument)
        end
      end
    end
    alias_method_chain :attribute_condition, :grouped_scope
    
  end
  
end


