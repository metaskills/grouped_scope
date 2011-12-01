require 'helper'

class GroupedScope::ClassMethodsTest < GroupedScope::TestCase
  
  describe 'For .grouped_scopes' do
    
    it 'have a inheritable attribute hash' do
      assert_instance_of Hash, Employee.grouped_scopes
    end
    
    it 'add to inheritable attributes with new grouped_scope' do
      Employee.grouped_scopes[:foobars] = nil
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
      assert Employee.grouped_scopes[:foobars]
    end

  end
  
  describe 'For .grouped_scope' do
    
    it 'create a belongs_to :grouping association' do
      assert Employee.reflections[:grouping]
    end
    
    it 'not recreate belongs_to :grouping on additional calls' do
      Employee.expects(:belongs_to).never
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
    end
    
    it 'create a has_many assoc named :grouped_scope_* using existing association as a suffix' do
      grouped_reports_assoc = Employee.reflections[:grouped_scope_reports]
      assert_instance_of GroupedScope::AssociationReflection, grouped_reports_assoc
      assert FactoryGirl.create(:employee).respond_to?(:grouped_scope_reports)
    end
    
    it 'not add the :grouped_scope option to existing reflection' do
      assert_nil Employee.reflections[:reports].options[:grouped_scope]
    end
    
    it 'have added the :grouped_scope option to new grouped reflection' do
      assert Employee.reflections[:grouped_scope_reports].options[:grouped_scope]
    end
    
  end
  
  
end
