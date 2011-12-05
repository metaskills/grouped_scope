module GroupedScope
  module Arish
    module Associations
      class AssociationScope < ActiveRecord::Associations::AssociationScope

        private

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

=begin

# Initial #add_constraints Idea
# -----------------------------

super(scope).tap do |s|
  case reflection.macro
  when :has_many
    ...
  end if reflection.grouped_scope?
end


# Simple AssociationScope Methods
# -------------------------------

as = ActiveRecord::Associations::AssociationScope.new(User.first.association(:columns)) ; as.object_id
as.klass          # => Column(3 columns)
as.owner          # => #<User id: 8, ...>
as.active_record  # => User(14 columns)


# Reflection Stuff For Join Through
# ---------------------------------

as.reflection
# => #<ActiveRecord::Reflection::AssociationReflection:0x007fdcd890bd18 @macro=:has_many, @name=:columns, @options={:order=>"position", :extend=>[]}, @active_record=User(14 columns), @plural_name="columns", @collection=true, @class_name="Column", @klass=Column(3 columns), @foreign_key="user_id", @active_record_primary_key="id", @type=nil>

as.reflection.association_primary_key # => "id"
as.reflection.association_foreign_key # => "column_id"


# How Tables Work In #add_constraints
# -----------------------------------

tables = as.send(:construct_tables)
table = tables.first

key = as.reflection.foreign_key                         # => "user_id"
foreign_key = as.reflection.active_record_primary_key   # => "id"

table[key].eq(as.owner[foreign_key]).to_sql             # => "columns"."user_id" = 8
table[key].in([1,2,3]).to_sql                           # => "columns"."user_id" IN (1, 2, 3)
table[key].in(as.owner.group.ids).to_sql                # => 





s = as.scope ; s.object_id
equalities = s.where_values.grep(Arel::Nodes::Equality)

e = equalities.first
# => #<Arel::Nodes::Equality:0x007fdcd8546ed0 @left=#<struct Arel::Attributes::Attribute relation=#<Arel::Table:0x007fdcd85471a0 @name="columns", @engine=ActiveRecord::Base, @columns=nil, @aliases=[], @table_alias=nil, @primary_key=nil>, name="user_id">, @right=8>





=end
