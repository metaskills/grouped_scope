module GroupedScope
  module Arish
    module Associations
      class AssociationScope < ActiveRecord::Associations::AssociationScope


        private

        def add_constraints(scope)
          super(scope).tap do |s|
            case reflection.macro
            when :has_many
              
              # s.where_values
              # [#<Arel::Nodes::Equality:0x007ffa41eb9c70 @left=#<struct Arel::Attributes::Attribute relation=#<Arel::Table:0x007ffa41eb9f40 @name="columns", @engine=ActiveRecord::Base, @columns=nil, @aliases=[], @table_alias=nil, @primary_key=nil>, name="user_id">, @right=8>]

            end if reflection.grouped_scope?
          end
        end

      end
    end
  end
end
