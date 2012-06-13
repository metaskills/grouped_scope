module GroupedScope
  module Arish
    module PredicateBuilder
      
      extend ActiveSupport::Concern
      
      included do
        singleton_class.alias_method_chain :build_from_hash, :grouped_scope
      end
      
      module ClassMethods
        def build_from_hash_with_grouped_scope(engine, attributes, default_table, allow_table_name = true)
          attributes.select{ |column, value| GroupedScope::SelfGroupping === value }.each do |column_value|
            column, value = column_value
            attributes[column] = value.arel_table[column.to_s].in(value.ids_sql)
          end
          build_from_hash_without_grouped_scope(engine, attributes, default_table, allow_table_name)
        end
        
      end

    end
  end
end

ActiveRecord::PredicateBuilder.send :include, GroupedScope::Arish::PredicateBuilder
