require File.dirname(__FILE__) + '/../helper'

class GroupedScope::HasManyThroughAssociationTest < GroupedScope::TestCase
  
  def setup
    setup_environment
    @e1 = Factory(:employee, :group_id => 1)
    @e1.departments << Department.hr << Department.finance
    @e2 = Factory(:employee, :group_id => 1)
    @e2.departments << Department.it
    @all_group_departments = [Department.hr, Department.it, Department.finance]
  end
  
  
  context 'For default association' do

    should 'scope to owner' do
      assert_sql(/employee_id = #{@e1.id}/) do
        @e1.departments(true)
      end
    end
    
    should 'scope count to owner' do
      assert_sql(/employee_id = #{@e1.id}/) do
        @e1.departments(true).count
      end
    end
    
  end
  
  context 'For grouped association' do

    should 'scope to group' do
      assert_sql(/employee_id IN \(#{@e1.id},#{@e2.id}\)/) do
        @e2.group.departments(true)
      end
    end
    
    should 'scope count to group' do
      assert_sql(/employee_id IN \(#{@e1.id},#{@e2.id}\)/) do
        @e1.group.departments(true).count
      end
    end
    
    should 'have a group count equal to sum of seperate owner counts' do
      assert_equal @e1.departments(true).count + @e2.departments(true).count, @e2.group.departments(true).count
    end
    
  end
  
  
  
end
