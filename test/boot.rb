
require 'activerecord'
require 'active_support'

plugin_root     = File.join(File.dirname(__FILE__), '..')
framework_root  = ["#{plugin_root}/rails", "#{plugin_root}/../../rails"].detect { |p| File.directory? p }
rails_version   = ENV['RAILS_VERSION']
rails_version   = nil if rails_version && rails_version == ''

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

