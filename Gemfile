
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
  gem 'minitest', '2.5.1'
  gem 'mini_shoulda', '0.4.0'
  gem 'factory_girl', '2.1.0'
  gem 'mocha', '0.10.0'
end

