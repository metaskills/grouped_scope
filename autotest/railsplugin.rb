class Autotest::Railsplugin < Autotest
  
  def initialize
    super
    
    # Default libs for autotest. So far they suit us just fine.
    # self.libs = %w[. lib test].join(File::PATH_SEPARATOR)
    
    # Ignore these directories in the plugin.
    add_exception %r%^\./(?:autotest|tasks)%
    
    # Ignore these ruby files in the root of the plugin folder.
    add_exception %r%^\./(install|uninstall)\.rb$%
    
    # Ignore these misc files in the root of the plugin folder.
    add_exception %r%^\./(.*LICENSE|Rakefile|README.*|CHANGELOG.*)$%
    
    # Ignore any log file.
    add_exception %r%.*\.log$%
    
    clear_mappings
    
    # Easy start. Any test file saved runs that file
    self.add_mapping(%r%^test/.*_test.rb$%) do |filename, matchs|
      filename
    end
    
    # If any file in lib matches up to a file in the same directory structure of 
    # the test directory, ofcourse having _test.rb at the end, will run that test. 
    self.add_mapping(%r%^lib/(.*)\.rb$%) do |filename, matchs|
      filename_path = matchs[1]
      files_matching %r%^test/#{filename_path}_test\.rb$%
    end
    
    # If any core test file like the helper, boot, database.yml change, then run 
    # all matching .*_test.rb files in the test directory.
    add_mapping %r%^test/(boot|helper|test_helper)\.rb|database.yml% do
      files_matching %r%^test/.*_test\.rb$%
    end
    
  end
  
  
end

