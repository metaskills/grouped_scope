class Autotest::Railsplugin < Autotest
  
  def initialize
    super
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

