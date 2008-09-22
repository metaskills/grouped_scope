require File.dirname(__FILE__) + '/../helper'

class SelfGrouppingTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  
  context 'Calling #group' do
    
    should 'return an array' do
      assert_instance_of Array, Factory(:employee).group
    end
    
    context 'with a NIL group' do

      setup do
        @employee = Factory(:employee)
      end
      
      should 'return an array of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert @employee.group.include?(@employee)
      end

    end
    
  end
  
  
end
