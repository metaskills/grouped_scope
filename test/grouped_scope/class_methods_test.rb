require File.dirname(__FILE__) + '/../helper'

class ClassMethodsTest < Test::Unit::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For .grouped_scopes' do
    
    should 'have a inheritable attribute hash' do
      assert_instance_of Hash, Employee.grouped_scopes
    end
    
    should 'add to inheritable attributes with new grouped_scope' do
      assert_nil Employee.grouped_scopes[:foobars]
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
      assert Employee.grouped_scopes[:foobars]
    end

  end
  
  context 'For .grouped_scope' do

    should 'create a belongs_to :grouping association' do
      assert Employee.reflect_on_association(:grouping)
    end
    
    should 'raise an exception when has_many association does not exist' do
      assert_raise(ArgumentError) { Employee.class_eval{grouped_scope(:foobars)} }
    end
    
    should 'not recreate belongs_to :grouping on additional calls' do
      Employee.stubs(:belongs_to).never
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
    end
    
  end
  
  
end
