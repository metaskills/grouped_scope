module GroupedScope
  class SelfGroupping
    
    include Enumerable
    
    delegate :size, :first, :last, :[], :inspect, :to => :group
    delegate :primary_key, :quote_value, :columns_hash, :to => :owner_class
    
    attr_reader :owner
    
    def initialize(owner)
      raise ArgumentError,'An ActiveRecord owner object must be specified.' if owner.blank? || !owner.respond_to?(:new_record?)
      raise NoGroupIdError.new(owner) unless owner.class.column_names.include?('group_id')
      @owner = owner
    end
    
    def group_ids
      @group_ids ||= find_selves(group_id_scope_options).map(&:id)
    end
    alias_method :ids, :group_ids
    
    def quoted_ids
      group_ids.map { |id| quote_value(id,columns_hash[primary_key]) }.join(',')
    end
    
    def group
      @group ||= find_selves(group_scope_options)
    end
    
    def each
      group.each { |member| yield member }
    end
    
    
    protected
    
    def all_grouped?
      false
    end
    
    def no_group?
      owner.group_id.blank?
    end
    
    def find_selves(options={})
      owner.class.find :all, options
    end
    
    def group_scope_options
      return {} if all_grouped?
      conditions = no_group? ? { primary_key => owner.id } : { :group_id => owner.group_id }
      { :conditions => conditions }
    end
    
    def group_id_scope_options
      { :select => primary_key }.merge(group_scope_options)
    end
    
    def owner_class
      owner.class
    end
    
  end
end

