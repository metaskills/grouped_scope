require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

def reset_invoked
  ['test_rails','test'].each do |name|
    Rake::Task[name].instance_variable_set '@already_invoked', false
  end
end


desc 'Default: run unit tests.'
task :default => :test_rails

desc 'Test the GroupedScope plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Test the GroupedScope plugin with Rails 2.3.2, 2.2.2, and 2.1.1 gems'
task :test_rails do
  test = Rake::Task['test']
  versions = ['2.3.2','2.2.2','2.1.1']
  versions.each do |version|
    ENV['RAILS_VERSION'] = "#{version}"
    test.invoke
    reset_invoked unless version == versions.last
  end
end

desc 'Generate documentation for the GroupedScope plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GroupedScope'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


