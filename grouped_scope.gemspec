Gem::Specification.new do |s|
  s.name     = "grouped_scope"
  s.version  = "0.5.0"
  s.date     = "2009-01-07"
  s.summary  = "Extends has_many associations to group scope."
  s.email    = "ken@metaskills.net"
  s.homepage = "http://github.com/metaskills/grouped_scope/"
  s.description = "Extends has_many associations to group scope."
  s.has_rdoc = true
  s.authors  = ["Ken Collins"]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "Rakefile",
    "README.rdoc",
    "init.rb",
    "lib/grouped_scope.rb",
    "lib/grouped_scope/association_reflection.rb",
    "lib/grouped_scope/class_methods.rb",
    "lib/grouped_scope/core_ext.rb",
    "lib/grouped_scope/errors.rb",
    "lib/grouped_scope/grouping.rb",
    "lib/grouped_scope/has_many_association.rb",
    "lib/grouped_scope/has_many_through_association.rb",
    "lib/grouped_scope/instance_methods.rb",
    "lib/grouped_scope/self_grouping.rb"]
  s.test_files = [
    "test/factories.rb",
    "test/grouped_scope/association_reflection_test.rb",
    "test/grouped_scope/class_methods_test.rb",
    "test/grouped_scope/has_many_association_test.rb",
    "test/grouped_scope/has_many_through_association_test.rb",
    "test/grouped_scope/self_grouping_test.rb",
    "test/helper.rb",
    "test/lib/boot.rb",
    "test/lib/core_ext.rb",
    "test/lib/named_scope.rb",
    "test/lib/named_scope/core_ext.rb",
    "test/lib/named_scope/named_scope.rb",
    "test/lib/named_scope/named_scope_patch_1.2.rb",
    "test/lib/named_scope/named_scope_patch_2.0.rb",
    "test/lib/test_case.rb" ]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc","CHANGELOG","MIT-LICENSE"]
end
