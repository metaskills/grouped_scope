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
      
      context 'calling association extensions' do

        setup do
          @e1 = Factory(:employee_with_reports, :group_id => 1)
          @e2 = Factory(:employee, :group_id => 1)
          @urget_report = Factory.build(:report, :title => 'URGET')
          @e1.reports << @urget_report
          @e1.save!
        end
        
        should 'find urget report via normal ungrouped association' do
          assert_equal [@urget_report], @e1.reports(true).urget
        end
        
        should 'find urget report via grouped reflection' do
          assert_equal [@urget_report], @e2.group.reports.urget
        end
        
        should 'use extension sql along with group reflection' do
          assert_sql(/'URGET'/,/"reports".employee_id IN/) do
            @e2.group.reports.urget
          end
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
