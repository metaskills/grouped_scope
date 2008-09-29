require 'rubygems'

plugin_root     = File.expand_path(File.join(File.dirname(__FILE__),'..'))
framework_root  = ["#{plugin_root}/rails", "#{plugin_root}/../../rails"].detect { |p| File.directory? p }
rails_version   = ENV['RAILS_VERSION']
rails_version   = nil if rails_version && rails_version == ''

['.','lib','test'].each do |plugin_lib|
  load_path = File.expand_path("#{plugin_root}/#{plugin_lib}")
  $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)
end

if rails_version.nil? && framework_root
  puts "Found framework root: #{framework_root}"
  $:.unshift "#{framework_root}/activesupport/lib", "#{framework_root}/activerecord/lib"
else
  puts "Using rails#{" #{rails_version}" if rails_version} from gems"
  if rails_version
    gem 'rails', rails_version
  else
    gem 'activerecord'
  end
end

require 'active_record'
require 'active_support'

gem 'mislav-will_paginate', '2.3.4'
require 'will_paginate'
WillPaginate.enable_activerecord

unless defined? ActiveRecord::NamedScope
  require 'core_ext'
  require 'named_scope'
  require ActiveRecord::Base.respond_to?(:find_first) ? 'named_scope_patch_1.2.6' : 'named_scope_patch_2.0'
  ActiveRecord::Base.send :include, GroupedScope::NamedScope
end

