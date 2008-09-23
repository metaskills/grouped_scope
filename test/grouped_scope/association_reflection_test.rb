require File.dirname(__FILE__) + '/../helper'

class AssociationReflectionTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
    
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
  
  context 'For #ungrouped_reflection' do
    
    should 'access ungrouped reflection' do
      assert_equal Employee.reflections[:reports], 
        Employee.reflections[:grouped_scope_reports].ungrouped_reflection
    end
    
    should 'delegate core instance methods to #ungrouped_reflection' do
      [:class_name,:klass,:table_name,:quoted_table_name,:primary_key_name,
       :association_foreign_key,:counter_cache_column,:source_reflection].each do |m|
        assert_equal Employee.reflections[:reports].send(m), 
          Employee.reflections[:grouped_scope_reports].send(m),
          "The method #{m.inspect} does not appear to be proxed to the ungrouped reflection."
      end
    end
    
    should 'not delegate to #ungrouped_reflection for #options and #name' do
      assert_not_equal Employee.reflections[:reports].name, Employee.reflections[:grouped_scope_reports].name
      assert_not_equal Employee.reflections[:reports].options, Employee.reflections[:grouped_scope_reports].options
    end
    
  end
  
  
  
end
