require 'helper'

class GroupedScope::AssociationReflectionTest < GroupedScope::TestCase
  
  setup do
    setup_environment
  end
  
  context 'For initialization' do

    context 'Raise and exception' do

      setup { @reflection_klass = GroupedScope::AssociationReflection }

      should 'when a association does not exist' do
        lambda{ @reflection_klass.new(Employee,:doesnotexist) }.must_raise(ArgumentError)
      end

      should 'when the association is not a has_many or a has_and_belongs_to_many' do
        Employee.class_eval { belongs_to(:foo) }
        lambda{ @reflection_klass.new(Employee,:foo) }.must_raise(ArgumentError)
      end

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
      methods = [:class_name,:klass,:table_name,:primary_key_name,:active_record,
                 :association_foreign_key,:counter_cache_column,:source_reflection]
      methods.each do |m|
        assert_equal @ungrouped_reflection.send(m), @grouped_reflection.send(m),
          "The method #{m.inspect} does not appear to be proxied to the ungrouped reflection."
      end
    end
    
    should 'not delegate to #ungrouped_reflection for #options and #name' do
      @ungrouped_reflection.name.wont_equal @grouped_reflection.name
      @ungrouped_reflection.options.wont_equal @grouped_reflection.options
    end
    
    should 'derive class name to same as ungrouped reflection' do
      assert_equal @ungrouped_reflection.send(:derive_class_name), @grouped_reflection.send(:derive_class_name)
    end
    
    should 'derive primary key name to same as ungrouped reflection' do
      assert_equal @ungrouped_reflection.send(:derive_primary_key_name), @grouped_reflection.send(:derive_primary_key_name)
    end
    
    should 'honor explicit legacy reports association options like class_name and foreign_key' do
      @ungrouped_reflection = LegacyEmployee.reflections[:reports]
      @grouped_reflection   = LegacyEmployee.reflections[:grouped_scope_reports]
      [:class_name,:primary_key_name].each do |m|
        assert_equal @ungrouped_reflection.send(m), @grouped_reflection.send(m),
          "The method #{m.inspect} does not appear to be proxied to the ungrouped reflection."
      end
    end
    
  end
  
  
end
