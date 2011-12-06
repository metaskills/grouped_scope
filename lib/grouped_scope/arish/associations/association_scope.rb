module GroupedScope
  module Arish
    module Associations
      class AssociationScope < ActiveRecord::Associations::AssociationScope
        
        
        private
        
        # A direct copy of of ActiveRecord's AssociationScope#add_constraints. If this was 
        # in chunks, it would be easier to hook into. This more elegant version which supers
        # up will only work for the has_many. https://gist.github.com/1434980 
        # 
        # We will just have to monitor rails every now and then and update this. Thankfully this
        # copy is only used in a group scope. FYI, our one line change is commented below.
        def add_constraints(scope)
          tables = construct_tables
        
          chain.each_with_index do |reflection, i|
            table, foreign_table = tables.shift, tables.first
        
            if reflection.source_macro == :has_and_belongs_to_many
              join_table = tables.shift
        
              scope = scope.joins(join(
                join_table,
                table[reflection.association_primary_key].
                in(join_table[reflection.association_foreign_key])
              ))
        
              table, foreign_table = join_table, tables.first
            end
        
            if reflection.source_macro == :belongs_to
              if reflection.options[:polymorphic]
                key = reflection.association_primary_key(klass)
              else
                key = reflection.association_primary_key
              end
        
              foreign_key = reflection.foreign_key
            else
              key         = reflection.foreign_key
              foreign_key = reflection.active_record_primary_key
            end
        
            conditions = self.conditions[i]
        
            if reflection == chain.last
              # GroupedScope changed this line.
              # scope = scope.where(table[key].eq(owner[foreign_key]))
              scope = scope.where(table[key].in(owner.group.ids))
        
              if reflection.type
                scope = scope.where(table[reflection.type].eq(owner.class.base_class.name))
              end
        
              conditions.each do |condition|
                if options[:through] && condition.is_a?(Hash)
                  condition = { table.name => condition }
                end
        
                scope = scope.where(interpolate(condition))
              end
            else
              constraint = table[key].eq(foreign_table[foreign_key])
        
              if reflection.type
                type = chain[i + 1].klass.base_class.name
                constraint = constraint.and(table[reflection.type].eq(type))
              end
        
              scope = scope.joins(join(foreign_table, constraint))
        
              unless conditions.empty?
                scope = scope.where(sanitize(conditions, table))
              end
            end
          end
        
          scope
        end

      end
    end
  end
end
