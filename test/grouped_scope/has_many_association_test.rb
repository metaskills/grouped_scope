require File.dirname(__FILE__) + '/../helper'

class HasManyAssociationTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For existing ungrouped has_many associations' do
    
    context 'for an Employee' do
      
      setup do 
        @employee = Factory(:employee)
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
    
    context 'for a LegacyEmployee' do

      setup do
        @employee = Factory(:legacy_employee)
      end

      should 'scope existing association to owner' do
        assert_sql(/"legacy_reports".email = '#{@employee.id}'/) do
          @employee.reports(true)
        end
      end
      
      should 'scope group association to group' do
        assert_sql(/"legacy_reports".email IN \('#{@employee.id}'\)/) do
          @employee.group.reports(true)
        end
      end
      
    end
    
    
  end
  
  
  
end
