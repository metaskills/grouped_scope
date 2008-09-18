module GroupedScope
  
  class GroupedScopeError < StandardError #:nodoc:
  end
  
  class NoGroupIdError < GroupedScopeError #:nodoc:
    def initialize(owner) ; @owner = owner ; end
    def message ; %|The #{@owner.class} class does not have a "group_id" attribute.| ; end
  end
  
  
end