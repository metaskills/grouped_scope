
ActiveRecord::Associations::AssociationProxy.class_eval do
  protected
  def with_scope(*args, &block)
    @reflection.klass.send :with_scope, *args, &block
  end
end

class ActiveRecord::Base
  class << self
    def find(*args)
      options = args.extract_options!
      validate_find_options(options)
      set_readonly_option!(options)
      case args.first
        when :first then find_initial(options)
        when :last  then find_last(options)
        when :all   then find_every(options)
        else             find_from_ids(args, options)
      end
    end
    private
    def attribute_condition_with_named_scope(argument)
      case argument
        when ActiveRecord::NamedScope::Scope then "IN (?)"
        else attribute_condition_without_named_scope(argument)
      end
    end
    alias_method_chain :attribute_condition, :named_scope
  end
end

ActiveRecord::Associations::AssociationCollection.class_eval do
  protected
  def method_missing(method, *args)
    if @target.respond_to?(method) || (!@reflection.klass.respond_to?(method) && Class.respond_to?(method))
      if block_given?
        super { |*block_args| yield(*block_args) }
      else
        super
      end
    elsif @reflection.klass.scopes.include?(method)
      @reflection.klass.scopes[method].call(self, *args)
    else          
      with_scope(construct_scope) do
        if block_given?
          @reflection.klass.send(method, *args) { |*block_args| yield(*block_args) }
        else
          @reflection.klass.send(method, *args)
        end
      end
    end
  end
end

