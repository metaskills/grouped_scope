
source :rubygems
source 'http://gems.github.com/'

spec = eval(File.read('grouped_scope.gemspec'))
ar_version = spec.dependencies.detect{ |d|d.name == 'activerecord' }.requirement.to_s

gem 'sqlite3', '1.3.4'
gem 'activerecord', ar_version, :require => 'active_record'
gem 'will_paginate', '2.3.16'

group :development do
  gem 'rake', '0.8.7'
end

group :test do
  gem 'minitest',     '~> 2.8.1'
  gem 'factory_girl', '~> 2.3.2'
  gem 'mocha',        '~> 0.10.0'
end

