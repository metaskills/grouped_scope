require File.dirname(__FILE__) + '/../helper'

class ClassMethodsTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For .grouped_scopes' do
    
    should 'have a inheritable attribute hash' do
      assert_instance_of Hash, Employee.grouped_scopes
    end
    
    should 'add to inheritable attributes with new grouped_scope' do
      Employee.grouped_scopes[:foobars] = nil
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
      assert Employee.grouped_scopes[:foobars]
    end

  end
  
  context 'For .grouped_scope' do
    
    should 'create a belongs_to :grouping association' do
      assert Employee.reflections[:grouping]
    end
    
    should 'not recreate belongs_to :grouping on additional calls' do
      Employee.stubs(:belongs_to).never
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
    end
    
    should 'create a has_many assoc named :grouped_scope_* using existing association as a suffix' do
      grouped_reports_assoc = Employee.reflections[:grouped_scope_reports]
      assert_instance_of GroupedScope::AssociationReflection, grouped_reports_assoc
      assert Factory(:employee).respond_to?(:grouped_scope_reports)
    end
    
    should 'not add the :grouped_scope option to existing reflection' do
      assert_nil Employee.reflections[:reports].options[:grouped_scope]
    end
    
    should 'have added the :grouped_scope option to new grouped reflection' do
      assert Employee.reflections[:grouped_scope_reports].options[:grouped_scope]
    end
    
  end
  
  
end
