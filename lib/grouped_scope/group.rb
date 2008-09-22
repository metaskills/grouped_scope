module GroupedScope
  class Group < Proxy
    
    def initialize(owner)
      super
    end
    
    def respond_to?(method, include_private=false)
      super || !proxy_class.grouped_scopes[method].blank?
    end
    
    protected
    
    def method_missing(method, *args, &block)
      if proxy_class.grouped_scopes[method]
        grouped_assoc = proxy_owner.class.grouped_scope_for(method)
        proxy_owner.send(grouped_assoc, *args, &block)
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


