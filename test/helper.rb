require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'mocha'
require 'boot' unless defined?(ActiveRecord)
require 'activerecord'
require 'active_support'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.join(File.dirname(__FILE__), '..', 'lib', 'grouped_scope')

require 'grouped_scope'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__)+'/debug.log')
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

def setup_environment(options={})
  options.reverse_merge! :group_column => :group_id
  setup_database(options)
  setup_models(options)
end

def setup_database(options)
  ActiveRecord::Base.connection.create_table :employees, :force => true do |t|
    t.column :name,         :string
    t.column :email,        :string
    t.column options[:group_column],  :integer
  end
  ActiveRecord::Base.connection.create_table :reports, :force => true do |t|
    t.column :title,        :string
    t.column :body,         :string
    t.column :employee_id,  :integer
  end
  ActiveRecord::Base.connection.create_table :legacy_employees, :force => true, :id => false do |t|
    t.column :name,         :string
    t.column :email,        :string
    t.column options[:group_column],  :integer
  end
  ActiveRecord::Base.connection.create_table :legacy_reports, :force => true do |t|
    t.column :title,        :string
    t.column :body,         :string
    t.column :email,        :string
  end
end

def setup_models(options)
  ['Employee','Report','LegacyEmployee','LegacyReport'].each do |klass|
    Object.send(:remove_const,klass) rescue nil
    Object.const_set klass, Class.new(ActiveRecord::Base)
  end
  Employee.class_eval do
    has_many :reports
    grouped_scope :reports
  end
  Report.class_eval do
    belongs_to :employee
  end
  LegacyEmployee.class_eval do
    set_primary_key :email
    has_many :reports, :class_name => 'LegacyReport', :foreign_key => 'email'
    grouped_scope :reports
  end
  LegacyReport.class_eval do
    belongs_to :employee, :class_name => 'LegacyEmployee'
  end
end


