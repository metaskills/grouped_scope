require File.dirname(__FILE__) + '/../helper'

class HasManyAssociationTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For existing ungrouped has_many associations' do
    
    context 'for an Employee' do
      
      setup { @employee = Factory(:employee) }
      
      should 'simply work' do
        assert_instance_of Array, @employee.reports
      end
      
      should 'scope existing association to owner' do
        assert_sql(/"reports".employee_id = #{@employee.id}/) do
          @employee.reports(true)
        end
      end
      
      should 'scope group association to group' do
        assert_sql(/"reports".employee_id IN \(#{@employee.id}\)/) do
          @employee.group.reports(true)
        end
      end
      
    end
    
  end
  
  
  
end
