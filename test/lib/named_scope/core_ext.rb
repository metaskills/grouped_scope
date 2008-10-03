
unless Hash.instance_methods.include? 'except'
  Hash.class_eval do
    
    # Returns a new hash without the given keys.
    def except(*keys)
      rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| rejected.include?(key) }
    end
 
    # Replaces the hash without only the given keys.
    def except!(*keys)
      replace(except(*keys))
    end
    
  end
end

class ActiveRecord::Base
  class << self
    
    def first(*args)
      find(:first, *args)
    end

    def last(*args)
      find(:last, *args)
    end

    def all(*args)
      find(:all, *args)
    end
    
    private
    
    def find_last(options)
      order = options[:order]
      if order
        order = reverse_sql_order(order)
      elsif !scoped?(:find, :order)
        order = "#{table_name}.#{primary_key} DESC"
      end
      if scoped?(:find, :order)
        scoped_order = reverse_sql_order(scope(:find, :order))
        scoped_methods.select { |s| s[:find].update(:order => scoped_order) }
      end
      find_initial(options.merge({ :order => order }))
    end
    
    def reverse_sql_order(order_query)
      reversed_query = order_query.split(/,/).each { |s|
        if s.match(/\s(asc|ASC)$/)
          s.gsub!(/\s(asc|ASC)$/, ' DESC')
        elsif s.match(/\s(desc|DESC)$/)
          s.gsub!(/\s(desc|DESC)$/, ' ASC')
        elsif !s.match(/\s(asc|ASC|desc|DESC)$/)
          s.concat(' DESC')
        end
      }.join(',')
    end
    
  end
end

ActiveRecord::Associations::AssociationCollection.class_eval do
  
  def last(*args)
    if fetch_first_or_last_using_find? args
      find(:last, *args)
    else
      load_target unless loaded?
      @target.last(*args)
    end
  end
  
  private
  
  def fetch_first_or_last_using_find?(args)
    args.first.kind_of?(Hash) || !(loaded? || @owner.new_record? || @reflection.options[:finder_sql] || !@target.blank? || args.first.kind_of?(Integer))
  end
  
end
