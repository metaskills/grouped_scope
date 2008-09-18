require 'test/unit'
require 'rubygems'
require 'activerecord'
require 'active_support'
require 'shoulda'
require 'mocha'
require 'grouped_scope'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__)+'/debug.log')
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

def setup_environment(options={})
  options.reverse_merge! :gc => :group_id
  ActiveRecord::Base.connection.create_table :employees, :force => true do |t|
    t.column :name,         :string
    t.column :email,        :string
    t.column options[:gc],  :integer
  end
  ActiveRecord::Base.connection.create_table :reports, :force => true do |t|
    t.column :title,  :string
    t.column :body,   :string
  end
  Object.send(:remove_const,'Employee') rescue nil
  Object.const_set 'Employee', Class.new(ActiveRecord::Base)
  Employee.class_eval do
    has_many :reports
    grouped_scope :reports
  end
end

