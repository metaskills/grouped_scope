module GroupedScope
  class SelfGroupping
    
    attr_reader :proxy_owner, :reflection
    
    delegate :quote_value, :columns_hash, :to => :proxy_class
    
    [].methods.each do |m|
      unless m =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/
        delegate m, :to => :grouped_proxy
      end
    end
    
    
    def initialize(proxy_owner)
      raise NoGroupIdError.new(proxy_owner) unless proxy_owner.class.column_names.include?('group_id')
      @proxy_owner = proxy_owner
    end
    
    def blank?
      proxy_owner.group_id.blank?
    end
    
    def present?
      !blank?
    end
    
    def ids
      grouped_scoped_ids.map(&primary_key.to_sym)
    end
    
    def ids_sql
      Arel.sql(grouped_scoped_ids.to_sql)
    end
    
    # TODO: Note this.
    def quoted_ids
      ids.map { |id| quote_value(id,columns_hash[primary_key]) }.join(',')
    end
    
    def with_reflection(reflection)
      @reflection = reflection
      yield
    ensure
      @reflection = nil
    end
    
    def respond_to?(method, include_private=false)
      super || proxy_class.grouped_reflections[method].present? || grouped_proxy.respond_to?(method, include_private)
    end
    
    
    protected
    
    def primary_key
      reflection ? reflection.association_primary_key : proxy_class.primary_key
    end
    
    def arel_group_id
      arel_table['group_id']
    end
    
    def arel_primary_key
      arel_table[primary_key]
    end
    
    def arel_table
      reflection ? Arel::Table.new(reflection.table_name) : proxy_class.arel_table
    end
    
    def grouped_proxy
      @grouped_proxy ||= grouped_scoped
    end
    
    def all_grouped?
      proxy_owner.all_grouped? rescue false
    end
    
    def grouped_scoped
      return proxy_class.scoped if all_grouped?
      proxy_class.where present? ? arel_group_id.eq(proxy_owner.group_id) : arel_primary_key.eq(proxy_owner.id)
    end
    
    def grouped_scoped_ids
      grouped_scoped.select(arel_primary_key)
    end
    
    def proxy_class
      proxy_owner.class
    end
    
    
    private
    
    def method_missing(method, *args)
      if proxy_class.grouped_reflections[method]
        if block_given?
          proxy_owner.send(:"grouped_scope_#{method}", *args)  { |*block_args| yield(*block_args) }
        else
          proxy_owner.send(:"grouped_scope_#{method}", *args)
        end
      elsif grouped_proxy.respond_to?(method)
        if block_given?
          grouped_proxy.send(method, *args)  { |*block_args| yield(*block_args) }
        else
          grouped_proxy.send(method, *args)
        end
      else
        super
      end
    end
    
  end
end

