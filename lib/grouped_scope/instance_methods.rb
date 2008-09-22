module GroupedScope
  module InstanceMethods
    
    def group
      @group ||= SelfGroupping.new(self)
    end
    
    
  end
end
