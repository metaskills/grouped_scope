require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'quietbacktrace'
require 'mocha'
require File.join(File.dirname(__FILE__),'lib/boot') unless defined?(ActiveRecord)
require 'factory_girl'
require 'lib/test_case'
require 'grouped_scope'

class GroupedScope::TestCase
  
  def setup_environment(options={})
    options.reverse_merge! :group_column => :group_id
    setup_database(options)
  end
  
  protected
  
  def setup_database(options)
    ActiveRecord::Base.class_eval do
      silence do
        connection.create_table :employees, :force => true do |t|
          t.column :name,         :string
          t.column :email,        :string
          t.column options[:group_column],  :integer
        end
        connection.create_table :reports, :force => true do |t|
          t.column :title,        :string
          t.column :body,         :string
          t.column :employee_id,  :integer
        end
        connection.create_table :legacy_employees, :force => true, :id => false do |t|
          t.column :name,         :string
          t.column :email,        :string
          t.column options[:group_column],  :integer
        end
        connection.create_table :legacy_reports, :force => true do |t|
          t.column :title,        :string
          t.column :body,         :string
          t.column :email,        :string
        end
        connection.create_table :foo_bars, :force => true do |t|
          t.column :foo,          :string
          t.column :bar,          :string
        end
      end
    end
  end
  
end

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



