module GroupedScope
  class Proxy
    
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$)/ } 
    
    def initialize(owner)
      @owner = owner
      reset_target!
    end
    
    def proxy_owner
      @owner
    end
    
    def proxy_class
      @owner.class
    end
    
    
    private
    
    def method_missing(method, *args, &block)
      load_target
      @target.send(method, *args, &block)
    end
    
    
  end
end

