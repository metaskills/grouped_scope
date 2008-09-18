class Autotest::Railsplugin < Autotest
  
  def initialize
    super
    
    # Ignore these directories in the plugin.
    add_exception %r%^\./(?:autotest|tasks)%
    
    # Ignore these ruby files in the root of the plugin folder.
    add_exception %r%^\./(install|uninstall)\.rb$%
    
    # Ignore these misc files in the root of the plugin folder.
    add_exception %r%^\./(.*LICENSE|Rakefile|README.*|CHANGELOG.*)$%
    
    # Ignore any log file.
    add_exception %r%.*\.log$%
    
    clear_mappings
    
    # self.libs = [
    #   "lib",
    #   "test"
    # ].join(File::PATH_SEPARATOR)
    
    # self.add_mapping %r%^test/.*/.*_test_sqlserver.rb$% do |filename, _|
    #   filename
    # end
    
    self.add_mapping(/^lib\/.*\.rb$/) do |filename, _|
      possible = File.basename(filename).gsub '_', '_?'
      files_matching %r%^test/.*#{possible}$%
    end
    
    self.add_mapping(/^test.*\/.*_test.rb$/) do |filename, _|
      filename
    end
    
    # TODO MAPPINGS
    #   * test/helper will run everything again.
    
  end
  
  
  
end

