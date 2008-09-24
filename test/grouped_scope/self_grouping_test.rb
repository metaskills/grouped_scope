require File.dirname(__FILE__) + '/../helper'

class SelfGrouppingTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'General behavior' do
    
    setup do
      @employee = Factory(:employee)
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
      assert_does_not_contain FooBar.column_names, 'group_id'
      assert_raise(GroupedScope::NoGroupIdError) { GroupedScope::SelfGroupping.new(FooBar.new) }
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
          # FIXME: Figure out why this does not work: assert_instance_of Employee, employee
          assert_equal Employee.name, employee.class.name
        end
      end
      
    end
    
  end
  
  context 'Calling #group' do
    
    should 'return an array' do
      assert_instance_of Array, Factory(:employee).group
    end
    
    context 'with a NIL group_id' do
      
      setup do
        @employee = Factory(:employee)
      end
      
      should 'return a collection of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert_contains @employee.group, @employee
      end
      
    end
    
    context 'with a set group_id' do
      
      setup do
        @employee = Factory(:employee, :group_id => 1)
      end
      
      should 'return a collection of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert_contains @employee.group, @employee
      end
      
    end
    
    context 'with different groups available' do
      
      setup do
        @e1 = Factory(:employee_with_reports, :group_id => 1)
        @e2 = Factory(:employee, :group_id => 1)
        @e3 = Factory(:employee_with_reports, :group_id => 2)
        @e4 = Factory(:employee, :group_id => 2)
      end
      
      should 'return a collection of group members' do
        assert_equal 2, @e1.group.size
      end
      
      should 'include all group members' do
        assert_same_elements [@e1,@e2], @e1.group
      end
      
      should 'member to find grouped associations of other member' do
        assert_same_elements @e1.reports, @e2.group.reports
      end
      
      should 'allow proxy owner to define all grouped which ignores group_id schema' do
        def @e1.all_grouped? ; true ; end
        assert_same_elements [@e1,@e2,@e3,@e4], @e1.group
      end
      
    end
    
  end
  
  
end
