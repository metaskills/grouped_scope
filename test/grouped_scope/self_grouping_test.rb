require 'helper'

class GroupedScope::SelfGrouppingTest < GroupedScope::TestCase
  
  setup do
    setup_environment
  end
  
  context 'General behavior' do
    
    setup do
      @employee = FactoryGirl.create(:employee)
    end
    
    should 'return an array' do
      assert_instance_of Array, @employee.group
    end
    
    should 'return #ids array' do
      assert_equal [@employee.id], @employee.group.ids
    end
    
    should 'return #quoted_ids string for use in sql statments' do
      assert_equal "#{@employee.id}", @employee.group.quoted_ids
    end
    
    should 'respond true to grouped associations' do
      assert @employee.group.respond_to?(:reports)
    end
    
    should 'raise a GroupedScope::NoGroupIdError exception for objects with no group_id schema' do
      FooBar.column_names.wont_include 'group_id'
      lambda{ GroupedScope::SelfGroupping.new(FooBar.new) }.must_raise(GroupedScope::NoGroupIdError)
    end
    
    should 'return correct attribute_condition for GroupedScope::SelfGroupping object' do
      assert_sql(/"?group_id"? IN \(#{@employee.id}\)/) do
        Employee.find :all, :conditions => {:group_id => @employee.group}
      end
    end
    
    context 'for Array delegates' do

      should 'respond to first/last' do
        [:first,:last].each do |method|
          assert @employee.group.respond_to?(method), "Should respond to #{method.inspect}"
        end
      end
      
      should 'respond to each' do
        assert @employee.group.respond_to?(:each)
        @employee.group.each do |employee|
          assert_instance_of Employee, employee
        end
      end
      
    end
    
  end
  
  context 'Calling #group' do
    
    should 'return an array' do
      assert_instance_of Array, FactoryGirl.create(:employee).group
    end
    
    context 'with a NIL group_id' do
      
      setup do
        @employee = FactoryGirl.create(:employee)
      end
      
      should 'return a collection of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert @employee.group.include?(@employee)
      end
      
    end
    
    context 'with a set group_id' do
      
      setup do
        @employee = FactoryGirl.create(:employee, :group_id => 1)
      end
      
      should 'return a collection of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert @employee.group.include?(@employee)
      end
      
    end
    
    context 'with different groups available' do
      
      setup do
        @e1 = FactoryGirl.create(:employee_with_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:employee, :group_id => 1)
        @e3 = FactoryGirl.create(:employee_with_reports, :group_id => 2)
        @e4 = FactoryGirl.create(:employee, :group_id => 2)
      end
      
      should 'return a collection of group members' do
        assert_equal 2, @e1.group.size
      end
      
      should 'include all group members' do
        assert_same_elements [@e1,@e2], @e1.group
      end
      
      should 'allow member to find grouped associations of other member' do
        assert_same_elements @e1.reports, @e2.group.reports
      end
      
      should 'allow proxy owner to define all grouped which ignores group_id schema' do
        @e2.stubs(:all_grouped?).returns(true)
        assert_same_elements [@e1,@e2,@e3,@e4], @e2.group
        assert_same_elements @e1.reports + @e3.reports, @e2.group.reports
      end
      
    end
    
    context 'with different groups in legacy schema' do
      
      setup do
        @e1 = FactoryGirl.create(:legacy_employee_with_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:legacy_employee, :group_id => 1)
        @e3 = FactoryGirl.create(:legacy_employee_with_reports, :group_id => 2)
        @e4 = FactoryGirl.create(:legacy_employee, :group_id => 2)
      end
      
      should 'honor legacy reports association options like class_name and foreign_key' do
        @e2.group.reports.all? { |r| r.is_a?(LegacyReport) }
      end
      
    end
    
  end
  
  
end
