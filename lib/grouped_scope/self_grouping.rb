module GroupedScope
  class SelfGroupping
    
    attr_reader :proxy_owner
    
    delegate :primary_key, :quote_value, :columns_hash, :to => :proxy_class
    
    [].methods.each do |m|
      unless m =~ /(^__|^nil\?|^send|^object_id$|class|extend|respond_to\?)/
        delegate m, :to => :group_proxy
      end
    end
    
    
    def initialize(proxy_owner)
      raise NoGroupIdError.new(proxy_owner) unless proxy_owner.class.column_names.include?('group_id')
      @proxy_owner = proxy_owner
    end
    
    def ids
      @ids ||= find_selves(group_id_scope_options).map(&:id)
    end
    
    def quoted_ids
      ids.map { |id| quote_value(id,columns_hash[primary_key]) }.join(',')
    end
    
    def respond_to?(method, include_private=false)
      super || !proxy_class.grouped_scopes[method].blank?
    end
    
    
    protected
    
    def group_proxy
      @group_proxy ||= find_selves(group_scope_options)
    end
    
    def all_grouped?
      proxy_owner.all_grouped? rescue false
    end
    
    def no_group?
      proxy_owner.group_id.blank?
    end
    
    def find_selves(options={})
      proxy_owner.class.find :all, options
    end
    
    def group_scope_options
      return {} if all_grouped?
      conditions = no_group? ? { primary_key => proxy_owner.id } : { :group_id => proxy_owner.group_id }
      { :conditions => conditions }
    end
    
    def group_id_scope_options
      { :select => primary_key }.merge(group_scope_options)
    end
    
    def proxy_class
      proxy_owner.class
    end
    
    
    private
    
    def method_missing(method, *args, &block)
      if proxy_class.grouped_scopes[method]
        proxy_owner.send("grouped_scope_#{method}", *args, &block)
      else
        super
      end
    end
    
  end
end

