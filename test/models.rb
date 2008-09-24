
class Employee < ActiveRecord::Base
  has_many :reports
  grouped_scope :reports
end

class Report < ActiveRecord::Base
  belongs_to :employee
end

class LegacyEmployee < ActiveRecord::Base
  set_primary_key :email
  has_many :reports, :class_name => 'LegacyReport', :foreign_key => 'email'
  grouped_scope :reports
end

class LegacyReport < ActiveRecord::Base
  belongs_to :employee, :class_name => 'LegacyEmployee'
end

class FooBar < ActiveRecord::Base
  has_many :reports
  grouped_scope :reports
end


