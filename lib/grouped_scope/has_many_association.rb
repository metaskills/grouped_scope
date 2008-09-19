module GroupedScope
  module HasManyAssociation
    
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :construct_sql, :group_scope
      end
    end

    def construct_sql_with_group_scope
      if @owner.class.grouped_scopes[@reflection.name]
        @finder_sql = "#{@reflection.klass.table_name}.#{@reflection.primary_key_name} IN (#{@owner.group.quoted_ids})"
        @finder_sql << " AND (#{conditions})" if conditions
        @counter_sql = @finder_sql
      else
        construct_sql_without_group_scope
      end
    end
    
  end
end

