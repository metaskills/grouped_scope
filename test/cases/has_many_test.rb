require 'helper'

class GroupedScope::HasManyTest < GroupedScope::TestCase
  
  describe 'For an Employee' do
    
    before do 
      @employee = FactoryGirl.create(:employee)
    end
    
    it 'scopes existing association to owner' do
      assert_sql(/"employee_id" = #{@employee.id}/) do
        @employee.reports(true)
      end
    end
    
    it 'scopes group association to owner when no group present' do
      assert_sql(/"employee_id" = #{@employee.id}/) do
        @employee.group.reports(true)
      end
    end
    
    it 'scopes group association to owner when group present' do
      @employee.update_attribute :group_id, 43
      assert_sql(/"employee_id" IN \(SELECT "employees"\."id" FROM "employees"  WHERE "employees"\."group_id" = 43\)/) do
        @employee.group.reports(true)
      end
    end
    
    describe 'for counting sql' do
      
      before do
        @e1 = FactoryGirl.create(:employee_with_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:employee_with_reports, :group_id => 1)
      end
      
      it 'scope count sql to owner' do
        assert_sql(/SELECT COUNT\(\*\)/,/"employee_id" = #{@e1.id}/) do
          @e1.reports(true).count
        end
      end
      
      it 'scope count sql to group' do
        assert_sql(/SELECT COUNT\(\*\)/,/"employee_id" IN \(SELECT "employees"\."id" FROM "employees"  WHERE "employees"\."group_id" = #{@e1.group_id}\)/) do
          @e1.group.reports(true).count
        end
      end
      
      it 'have a group count equal to sum of seperate owner counts' do
        assert_equal @e1.reports(true).count + @e2.reports(true).count, @e2.group.reports(true).count
      end
      
    end
    
    describe 'training association extensions' do
    
      before do
        @e1 = FactoryGirl.create(:employee_with_urgent_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:employee, :group_id => 1)
        @urgent_reports = @e1.reports.select(&:urgent_title?)
      end
      
      it 'find urgent report via normal ungrouped association' do
        assert_same_elements @urgent_reports, @e1.reports(true).urgent
      end
      
      it 'find urgent report via grouped reflection' do
        assert_same_elements @urgent_reports, @e2.group.reports(true).urgent
      end
      
      it 'use association extension SQL along with group reflection' do
        assert_sql(select_from_reports, where_for_groups(@e2.group_id), where_for_urgent_title) do
          @e2.group.reports.urgent
        end
      end
    
    end
    
    describe 'training named scopes' do
      
      before do
        @e1 = FactoryGirl.create(:employee_with_urgent_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:employee, :group_id => 1)
        @urgent_titles = @e1.reports.select(&:urgent_title?)
        @urgent_bodys = @e1.reports.select(&:urgent_body?)
      end
      
      it 'find urgent reports via normal named scopes by normal owner' do
        assert_same_elements @urgent_titles, @e1.reports(true).with_urgent_title
        assert_same_elements @urgent_bodys, @e1.reports(true).with_urgent_body
      end
      
      it 'find urgent reports via group reflection by group member' do
        assert_same_elements @urgent_titles, @e2.group.reports(true).with_urgent_title
        assert_same_elements @urgent_bodys, @e2.group.reports(true).with_urgent_body
      end
      
      it 'use named scope SQL along with group reflection' do
        assert_sql(select_from_reports, where_for_groups(@e2.group_id), where_for_urgent_body, where_for_urgent_title) do
          @e2.group.reports.with_urgent_title.with_urgent_body.inspect
        end
      end
      
    end
    
  end
  
  describe 'For a LegacyEmployee' do
  
    before do
      @employee = FactoryGirl.create(:legacy_employee)
    end
  
    it 'scope existing association to owner' do
      assert_sql(/"legacy_reports"."email" = '#{@employee.id}'/) do
        @employee.reports(true)
      end
    end
    
    it 'scope group association to owner, since no group is present' do
      assert_sql(/"legacy_reports"."email" = '#{@employee.id}'/) do
        @employee.group.reports(true)
      end
    end
    
    it 'scopes group association to owners group when present' do
      @employee.update_attribute :group_id, 43
      assert_sql(/"legacy_reports"."email" IN \(SELECT "legacy_employees"\."email" FROM "legacy_employees"  WHERE "legacy_employees"\."group_id" = 43\)/) do
        @employee.group.reports(true)
      end
    end
    
  end
  
  
  protected
  
  def select_from_reports
    /SELECT "reports"\.\* FROM "reports"/
  end
  
  def where_for_groups(id)
    /WHERE "reports"."employee_id" IN \(SELECT "employees"\."id" FROM "employees"  WHERE "employees"\."group_id" = #{id}\)/
  end
  
  def where_for_urgent_body
    /WHERE.*body LIKE '%URGENT%'/
  end
  
  def where_for_urgent_title
    /WHERE.*"?reports"?."?title"? = 'URGENT'/
  end
  
  
end
