require File.dirname(__FILE__) + '/../helper'

class HasManyAssociationTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For existing ungrouped has_many associations' do
    
    context 'for an Employee' do

      setup do
        @con = ActiveRecord::Base.connection
      end
      
      should 'simply work' do
        @employee = Factory(:employee)
        assert_instance_of Array, @employee.reports
      end
      
      should 'scope existing associations to owner' do
        @employee = Factory(:employee_with_reports)
        assert_sql(/"reports".employee_id = 1/) do
          @employee.reports.reload
        end
      end
      
    end
    
  end
  
  
  
end
