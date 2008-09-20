require File.dirname(__FILE__) + '/../helper'

class HasManyAssociationTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  context 'For existing ungrouped has_many associations' do
    
    setup do
      @con = ActiveRecord::Base.connection
    end
    
    should 'be able to call it' do
      @employee = Factory(:employee)
      assert_instance_of Array, @employee.reports
    end
    
    # should 'description' do
    #   @employee = Factory(:employee)
    #   assert_instance_of Array, e.reports
    #   # assert_sql(/\(#{@con.quote_table_name('employees')}.#{@con.quote_column_name('id')} = dddd/) do
    #   #   
    #   # end
    # end
    

  end
  
  
  
end
