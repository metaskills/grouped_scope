require 'helper'

class GroupedScope::HasManyThroughTest < GroupedScope::TestCase
  
  before do
    @e1 = FactoryGirl.create(:employee, :group_id => 1)
    @e1.departments << Department.hr << Department.finance
    @e2 = FactoryGirl.create(:employee, :group_id => 1)
    @e2.departments << Department.it
    @all_group_departments = [Department.hr, Department.it, Department.finance]
  end
  
  describe 'For default association' do

    it 'scope to owner' do
      assert_sql(/"employee_id" = #{@e1.id}/) do
        @e1.departments(true)
      end
    end
    
    it 'scope count to owner' do
      assert_sql(/"employee_id" = #{@e1.id}/) do
        @e1.departments(true).count
      end
    end
    
  end
  
  describe 'For grouped association' do

    it 'scope to group' do
      raise @e2.group.departments(true).inspect
      assert_sql(/"employee_id" IN \(#{@e1.id}, #{@e2.id}\)/) do
        @e2.group.departments(true)
      end
    end
    
    # it 'scope count to group' do
    #   assert_sql(/employee_id IN \(#{@e1.id},#{@e2.id}\)/) do
    #     @e1.group.departments(true).count
    #   end
    # end
    # 
    # it 'have a group count equal to sum of seperate owner counts' do
    #   assert_equal @e1.departments(true).count + @e2.departments(true).count, @e2.group.departments(true).count
    # end
    
  end
  
  
end
