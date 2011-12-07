$:.push File.expand_path("../lib", __FILE__)
require "grouped_scope/version"

Gem::Specification.new do |s|
  s.name          = 'grouped_scope'
  s.version       = GroupedScope::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Ken Collins']
  s.email         = ['ken@metaskills.net']
  s.homepage      = 'http://github.com/metaskills/grouped_scope/'
  s.summary       = 'Extends has_many associations to group scope.'
  s.description   = 'Extends has_many associations to group scope. For ActiveRecord 3.1!'
  s.files         = `git ls-files`.split("\n") - ["grouped_scope.gemspec"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options  = ['--charset=UTF-8']
  s.add_dependency 'activerecord', '~> 3.1.0'
end

