module GroupedScope
  class Group < Proxy
    
    def initialize(owner)
      super
    end
    
    
    protected
    
    def method_missing(method, *args, &block)
      group_method = "group_#{method}".to_sym
      if proxy_class.grouped_scopes[method]
        proxy_owner.send(group_method, *args, &block)
      else
        super
      end
    end
    
    def loaded?
      @target && !@target.blank?
    end
    
    def reset_target!
      @target = nil
    end
    
    def load_group
      SelfGroupping.new(proxy_owner)
    end
    
    def load_target
      @target = load_group unless loaded?
    end
        
  end
end


