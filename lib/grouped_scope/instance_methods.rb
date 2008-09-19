module GroupedScope
  module InstanceMethods
    
    def group
      @group ||= Group.new(self)
    end
    
    
  end
end
