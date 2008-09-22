module GroupedScope
  class SelfGroupping
    
    include Enumerable
    
    delegate :size, :first, :last, :[], :inspect, :to => :group
    delegate :primary_key, :quote_value, :columns_hash, :to => :proxy_class
    
    attr_reader :proxy_owner
    
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
    
    def group
      @group ||= find_selves(group_scope_options)
    end
    
    def each
      group.each { |member| yield member }
    end
    
    def respond_to?(method, include_private=false)
      super || !proxy_class.grouped_scopes[method].blank?
    end
    
    
    protected
    
    def all_grouped?
      false
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
        grouped_assoc = proxy_owner.class.grouped_scope_for(method)
        proxy_owner.send(grouped_assoc, *args, &block)
      else
        super
      end
    end
    
  end
end

