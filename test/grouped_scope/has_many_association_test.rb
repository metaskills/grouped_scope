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
      
      context 'training association extensions' do
      
        setup do
          @e1 = Factory(:employee_with_urgent_reports, :group_id => 1)
          @e2 = Factory(:employee, :group_id => 1)
          @urgent_reports = @e1.reports.select(&:urgent_title?)
        end
        
        should 'find urgent report via normal ungrouped association' do
          assert_same_elements @urgent_reports, @e1.reports(true).urgent
        end
        
        should 'find urgent report via grouped reflection' do
          assert_same_elements @urgent_reports, @e2.group.reports(true).urgent
        end
        
        should 'use assoc extension SQL along with group reflection' do
          assert_sql(/'URGENT'/,/"reports".employee_id IN/) do
            @e2.group.reports(true).urgent
          end
        end
      
      end
      
      context 'training named scopes' do
    
        setup do
          @e1 = Factory(:employee_with_urgent_reports, :group_id => 1)
          @e2 = Factory(:employee, :group_id => 1)
          @urgent_titles = @e1.reports.select(&:urgent_title?)
          @urgent_bodys = @e1.reports.select(&:urgent_body?)
        end
        
        should 'find urgent reports via normal named scopes by normal owner' do
          assert_same_elements @urgent_titles, @e1.reports(true).with_urgent_title
          assert_same_elements @urgent_bodys, @e1.reports(true).with_urgent_body
        end
        
        should 'find urgent reports via group reflection by group member' do
          assert_same_elements @urgent_titles, @e2.group.reports(true).with_urgent_title
          assert_same_elements @urgent_bodys, @e2.group.reports(true).with_urgent_body
        end
        
        should 'use named scope SQL along with group reflection' do
          assert_sql(/body LIKE '%URGENT%'/,/"title" = 'URGENT'/,/employee_id IN/) do
            @e2.group.reports(true).with_urgent_title.with_urgent_body.inspect
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
