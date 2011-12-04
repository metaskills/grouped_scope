require 'helper'

class GroupedScope::ReflectionTest < GroupedScope::TestCase
  
  it 'creates a has_many association named :grouped_scope_* using existing association as a suffix' do
    assert FactoryGirl.create(:employee).respond_to?(:grouped_scope_reports)
  end
  
  it 'does not add the #grouped_scope to existing reflection' do
    assert_nil Employee.reflections[:reports].grouped_scope?
  end
  
  it 'should have added the #grouped_scope to new grouped reflection' do
    assert Employee.reflections[:grouped_scope_reports].grouped_scope?
  end
  
  describe 'Class attribute for #grouped_reflections' do
    
    it 'should one' do
      assert_instance_of Hash, Employee.grouped_reflections
    end

    it 'populate with new grouped scopes' do
      assert_nil Employee.grouped_reflections[:newgroupes]
      Employee.class_eval { has_many(:newgroupes) ; grouped_scope(:newgroupes) }
      assert Employee.grouped_reflections[:newgroupes]
    end
    
  end
  
  describe 'Raise and exception' do

    it 'when a association does not exist' do
      begin
        raised = false
        Employee.class_eval{ grouped_scope(:doesnotexist) }
      rescue ArgumentError => e
        raised = true
        e.message.must_match %r{Cannot create a group scope for :doesnotexist}
      ensure
        assert raised, 'Did not raise an ArgumentError'
      end
    end

    it 'when the association is not a has_many or a has_and_belongs_to_many' do
      begin
        raised = false
        Employee.class_eval { belongs_to(:belongstowillnotwork) ; grouped_scope(:belongstowillnotwork) }
      rescue ArgumentError => e
        raised = true
        e.message.must_match %r{:belongstowillnotwork.*the reflection is blank or not supported}
      ensure
        assert raised, 'Did not raise an ArgumentError'
      end
    end

  end
  

  
  
end
