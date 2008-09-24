require File.dirname(__FILE__) + '/../helper'

class AssociationReflectionTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For initialization' do

    context 'Raise and exception' do

      setup { @reflection_klass = GroupedScope::AssociationReflection }

      should 'when a association does not exist' do
        assert_raise(ArgumentError) { @reflection_klass.new(Employee,:foobars) }
      end

      should 'when the association is not a has_many or a has_and_belongs_to_many' do
        Employee.class_eval { belongs_to(:foo) }
        assert_raise(ArgumentError) { @reflection_klass.new(Employee,:foo) }
      end

    end
    
    should_eventually 'TEST COLLECTION READER METHOD GENERATION' do
      
    end

  end
  
  
  context 'For #ungrouped_reflection' do
    
    setup do
      @ungrouped_reflection = Employee.reflections[:reports]
      @grouped_reflection = Employee.reflections[:grouped_scope_reports]
    end
    
    should 'access ungrouped reflection' do
      assert_equal @ungrouped_reflection, @grouped_reflection.ungrouped_reflection
    end
    
    should 'delegate instance methods to #ungrouped_reflection' do
      [:class_name,:klass,:table_name,:quoted_table_name,:primary_key_name,:active_record,
       :association_foreign_key,:counter_cache_column,:source_reflection].each do |m|
        assert_equal @ungrouped_reflection.send(m), @grouped_reflection.send(m),
          "The method #{m.inspect} does not appear to be proxied to the ungrouped reflection."
      end
    end
    
    should 'not delegate to #ungrouped_reflection for #options and #name' do
      assert_not_equal @ungrouped_reflection.name, @grouped_reflection.name
      assert_not_equal @ungrouped_reflection.options, @grouped_reflection.options
    end
    
    should 'derive class name to same as ungrouped reflection' do
      assert_equal @ungrouped_reflection.send(:derive_class_name), @grouped_reflection.send(:derive_class_name)
    end
    
    should 'derive primary key name to same as ungrouped reflection' do
      assert_equal @ungrouped_reflection.send(:derive_primary_key_name), @grouped_reflection.send(:derive_primary_key_name)
    end
    
  end
  
  
  
end
