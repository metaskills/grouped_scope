require File.dirname(__FILE__) + '/../helper'

class GroupTest < GroupedScope::TestCase
  
  def setup
    setup_environment
  end
  
  should 'be true' do
    assert true
  end
  
  
end
