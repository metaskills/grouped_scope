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
  s.description   = 'Extends has_many associations to group scope. For ActiveRecord!'
  s.files         = `git ls-files`.split("\n") - ["grouped_scope.gemspec"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options  = ['--charset=UTF-8']
  s.add_runtime_dependency 'activerecord', '~> 3.1'
  s.add_development_dependency 'sqlite3',      '~> 1.3'
  s.add_development_dependency 'rake',         '~> 0.9.2'
  s.add_development_dependency 'minitest',     '~> 2.8.1'
  s.add_development_dependency 'factory_girl', '~> 2.3.2'
  s.add_development_dependency 'mocha',        '~> 0.10.0'
end

