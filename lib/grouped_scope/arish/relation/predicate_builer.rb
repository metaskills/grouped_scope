module GroupedScope
  module Arish
    module PredicateBuilder
      
      extend ActiveSupport::Concern
      
      included do
        singleton_class.alias_method_chain :build_from_hash, :grouped_scope
      end
      
      module ClassMethods
        
        def build_from_hash_with_grouped_scope(engine, attributes, default_table)
          attributes.select{ |k,v| GroupedScope::SelfGroupping === v }.each do |kv|
            k, v = kv
            attributes[k] = v.ids
          end
          build_from_hash_without_grouped_scope(engine, attributes, default_table)
        end
        
      end

    end
  end
end

ActiveRecord::PredicateBuilder.send :include, GroupedScope::Arish::PredicateBuilder
