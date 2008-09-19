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
    
    should 'not create more belongs_to :grouping on additional calls' do
      Employee.expects(:has_many).with(:grouping).never
      Employee.class_eval { has_many(:foobars) ; grouped_scope(:foobars) }
    end
    
  end
  
  
end
