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
    
    should 'respond true to grouped associations' do
      assert @employee.group.respond_to?(:reports)
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
    

      

    
    context 'with no group_id schema' do

      should 'raise a GroupedScope::NoGroupIdError exception' do
        assert_raise(GroupedScope::NoGroupIdError) { FooBar.new.group }
      end
      
    end
    
    context 'with a NIL group_id' do
      
      setup do
        @employee = Factory(:employee)
      end
      
      should 'return an array of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert @employee.group.include?(@employee)
      end
      
      should 'return #ids array' do
        assert_equal [@employee.id], @employee.group.ids
      end
      
      should 'return #quoted_ids string for use in sql statments' do
        assert_equal "#{@employee.id}", @employee.group.quoted_ids
      end
      
    end
    
    context 'with a set group_id' do
      
      setup do
        @employee = Factory(:employee, :group_id => 1)
      end
      
      should 'return an array of one' do
        assert_equal 1, @employee.group.size
      end
      
      should 'include self in group' do
        assert @employee.group.include?(@employee)
      end
      
    end
    
    # context 'with different employees in different groups' do
    # 
    #   setup do
    #     @e1_g1 = Factory(:employee_with_reports, :group_id => 1)
    #     @e2_g1 = Factory(:employee, :group_id => 1)
    #     @e2_g2 = Factory(:employee_with_reports, :group_id => 2)
    #     @e2_g2 = Factory(:employee, :group_id => 2)
    #   end
    # 
    #   should 'have creaed factories in a sane manner' do
    #     # raise Employee.reflect_on_association(:reports).inspect
    #     # raise Employee.reflect_on_association(:grouped_scope_reports).inspect
    #     # assert_equal @e1_g1.reports.size, @e1_g1.group.reports.size
    #   end
    # 
    # end
    
    
  end
  
  # Make sure legacy quoted_ids are quoted
  
end
