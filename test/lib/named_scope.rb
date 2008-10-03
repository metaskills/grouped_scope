unless defined? ActiveRecord::NamedScope
  require "named_scope/core_ext"
  require "named_scope/named_scope"
  require "named_scope/named_scope_patch_#{ActiveRecord::Base.respond_to?(:find_first) ? '1.2' : '2.0'}"
  ActiveRecord::Base.send :include, ActiveRecord::NamedScope
end

