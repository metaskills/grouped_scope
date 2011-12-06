require 'helper'

class GroupedScope::SelfGrouppingTest < GroupedScope::TestCase
  
  describe 'General behavior' do
    
    before do
      @employee = FactoryGirl.create(:employee)
    end
    
    it 'return #ids array' do
      assert_equal [@employee.id], @employee.group.ids
      e1 = FactoryGirl.create :employee, :group_id => 3
      e2 = FactoryGirl.create :employee, :group_id => 3
      assert_same_elements [e1.id, e2.id], e1.group.ids
    end
    
    it 'return #quoted_ids string for use in sql statments' do
      assert_equal "#{@employee.id}", @employee.group.quoted_ids
    end
    
    it 'respond true to grouped associations' do
      assert @employee.group.respond_to?(:reports)
    end
    
    it 'raise a GroupedScope::NoGroupIdError exception for objects with no group_id schema' do
      FooBar.column_names.wont_include 'group_id'
      lambda{ GroupedScope::SelfGroupping.new(FooBar.new) }.must_raise(GroupedScope::NoGroupIdError)
    end
    
    it 'return correct attribute_condition for GroupedScope::SelfGroupping object' do
      assert_sql(/"?group_id"? IN \(#{@employee.id}\)/) do
        Employee.find :all, :conditions => {:group_id => @employee.group}
      end
    end
    
    describe 'for #with_reflection' do
      
      before { @reflection = Employee.reflections[:reports] }
      
      it 'will set a reflection and always set it back to nil' do
        assert_nil @employee.group.reflection
        @employee.group.with_reflection(@reflection) do
          assert_equal @reflection, @employee.group.reflection
        end
        assert_nil @employee.group.reflection
      end
      
      it 'will use the primary key of the reflection' do
        pk = 'association_primary_key'
        @reflection.stubs :association_primary_key => pk
        @employee.group.with_reflection(@reflection) do
          assert_equal pk, @employee.group.send(:primary_key)
        end
      end
      
    end
    
    describe 'for Array delegates' do

      it 'respond to first/last' do
        [:first,:last].each do |method|
          assert @employee.group.respond_to?(method), "Should respond to #{method.inspect}"
        end
      end
      
      it 'respond to each' do
        assert @employee.group.respond_to?(:each)
        @employee.group.each do |employee|
          assert_instance_of Employee, employee
        end
      end
      
    end
    
  end
  
  describe 'Calling #group' do
    
    it 'returns a active record relation' do
      assert_instance_of ActiveRecord::Relation, FactoryGirl.create(:employee).group
    end
    
    describe 'with a NIL group_id' do
      
      before do
        @employee = FactoryGirl.create(:employee)
      end
      
      it 'return a collection of one' do
        assert_equal 1, @employee.group.size
      end
      
      it 'include self in group' do
        assert @employee.group.include?(@employee)
      end
      
      it 'returns a sql literal for #ids_sql scoped to single record' do
        @employee.group.ids_sql.must_be_instance_of Arel::Nodes::SqlLiteral
        @employee.group.ids_sql.must_match %r{SELECT \"employees\".\"id\" FROM \"employees\"  WHERE \"employees\".\"id\" = #{@employee.id}}
      end
      
    end
    
    describe 'with a set group_id' do
      
      before do
        @employee = FactoryGirl.create(:employee, :group_id => 1)
      end
      
      it 'return a collection of one' do
        assert_equal 1, @employee.group.size
      end
      
      it 'include self in group' do
        assert @employee.group.include?(@employee)
      end
      
      it 'returns a sql literal for #ids_sql scoped to group' do
        new_group_id = 420
        e1 = FactoryGirl.create :employee, :group_id => new_group_id
        e2 = FactoryGirl.create :employee, :group_id => new_group_id
        e1.group.ids_sql.must_be_instance_of Arel::Nodes::SqlLiteral
        e1.group.ids_sql.must_match %r{SELECT \"employees\".\"id\" FROM \"employees\"  WHERE \"employees\".\"group_id\" = #{new_group_id}}
      end
      
      it 'allows the group to be further scoped' do
        new_group_id = 420
        e1 = FactoryGirl.create :employee, :group_id => new_group_id, :name => 'Ken', :email => 'ken@actionmoniker.com'
        e2 = FactoryGirl.create :employee, :group_id => new_group_id, :name => 'Hostmaster', :email => 'hostmaster@actionmoniker.com'
        e3 = FactoryGirl.create :employee, :group_id => new_group_id, :name => 'Ken', :email => 'ken@metaskills.net'
        assert_same_elements [e1, e2], e1.group.email_for_actionmoniker
      end
      
    end
    
    describe 'with different groups available' do
      
      before do
        @e1 = FactoryGirl.create(:employee_with_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:employee, :group_id => 1)
        @e3 = FactoryGirl.create(:employee_with_reports, :group_id => 2)
        @e4 = FactoryGirl.create(:employee, :group_id => 2)
      end
      
      it 'return a collection of group members' do
        assert_equal 2, @e1.group.size
      end
      
      it 'include all group members' do
        assert_same_elements [@e1,@e2], @e1.group
      end
      
      it 'allow member to find grouped associations of other member' do
        assert_same_elements @e1.reports, @e2.group.reports
      end
      
      it 'allow proxy owner to define all grouped which ignores group_id schema' do
        @e2.stubs :all_grouped? => true
        assert_same_elements [@e1,@e2,@e3,@e4], @e2.group
        assert_same_elements @e1.reports + @e3.reports, @e2.group.reports
      end
      
    end
    
    describe 'with different groups in legacy schema' do
      
      before do
        @e1 = FactoryGirl.create(:legacy_employee_with_reports, :group_id => 1)
        @e2 = FactoryGirl.create(:legacy_employee, :group_id => 1)
        @e3 = FactoryGirl.create(:legacy_employee_with_reports, :group_id => 2)
        @e4 = FactoryGirl.create(:legacy_employee, :group_id => 2)
      end
      
      it 'honor legacy reports association options like class_name and foreign_key' do
        @e2.group.reports.all? { |r| r.is_a?(LegacyReport) }
      end
      
    end
    
  end
  
  
end
