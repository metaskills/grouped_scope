require 'rubygems'
require 'bundler'
require "bundler/setup"
Bundler.require(:default, :development, :test)
require 'grouped_scope'
require 'minitest/autorun'
require 'factories'

WillPaginate.enable_activerecord

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__)+'/debug.log')
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/]
  def execute_with_query_record(sql, name = nil, &block)
    $queries_executed ||= []
    $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
    execute_without_query_record(sql, name, &block)
  end
  alias_method_chain :execute, :query_record
end


module GroupedScope
  class TestCase < MiniTest::Spec
    
    include Mocha::API
    
    before { setup_environment }
    after  { mocha_teardown }
    
    def setup_environment(options={})
      options.reverse_merge! :group_column => :group_id
      setup_database(options)
      Department.create! :name => 'IT'
      Department.create! :name => 'Human Resources'
      Department.create! :name => 'Finance'
    end
    
    protected
    
    def assert_same_elements(a1, a2, msg = nil)
      [:select, :inject, :size].each do |m|
        [a1, a2].each { |a| a.must_respond_to m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}." }
      end
      assert a1h = a1.inject({}) { |h,e| h[e] ||= a1.select { |i| i == e }.size; h }
      assert a2h = a2.inject({}) { |h,e| h[e] ||= a2.select { |i| i == e }.size; h }
      a1h.must_equal a2h, msg
    end
    
    def assert_sql(*patterns_to_match)
      $queries_executed = []
      yield
    ensure
      failed_patterns = []
      patterns_to_match.each do |pattern|
        failed_patterns << pattern unless $queries_executed.any?{ |sql| pattern === sql }
      end
      assert failed_patterns.empty?, "Query pattern(s) #{failed_patterns.map(&:inspect).join(', ')} not found in:\n#{$queries_executed.inspect}"
    end

    def assert_queries(num = 1)
      $queries_executed = []
      yield
    ensure
      assert_equal num, $queries_executed.size, "#{$queries_executed.size} instead of #{num} queries were executed."
    end

    def assert_no_queries(&block)
      assert_queries(0, &block)
    end
    
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
          connection.create_table :departments, :force => true do |t|
            t.column :name,         :string
          end
          connection.create_table :department_memberships, :force => true do |t|
            t.column :employee_id,    :integer
            t.column :department_id,  :integer
            t.column :meta_info,      :string
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
end

class Employee < ActiveRecord::Base
  has_many :reports do ; def urgent ; find(:all,:conditions => {:title => 'URGENT'}) ; end ; end
  has_many :taxonomies, :as => :classable
  has_many :department_memberships
  has_many :departments, :through => :department_memberships
  grouped_scope :reports, :departments
end

class Report < ActiveRecord::Base
  named_scope :with_urgent_title, :conditions => {:title => 'URGENT'}
  named_scope :with_urgent_body, :conditions => "body LIKE '%URGENT%'"
  belongs_to :employee
  def urgent_title? ; self[:title] == 'URGENT' ; end
  def urgent_body? ; self[:body] =~ /URGENT/ ; end
end

class Department < ActiveRecord::Base
  named_scope :it, :conditions => {:name => 'IT'}
  named_scope :hr, :conditions => {:name => 'Human Resources'}
  named_scope :finance, :conditions => {:name => 'Finance'}
  has_many :department_memberships
  has_many :employees, :through => :department_memberships
end

class DepartmentMembership < ActiveRecord::Base
  belongs_to :employee
  belongs_to :department
end

class LegacyEmployee < ActiveRecord::Base
  set_primary_key :email
  has_many :reports, :class_name => 'LegacyReport', :foreign_key => 'email'
  grouped_scope :reports
  alias_method :email=, :id=
end

class LegacyReport < ActiveRecord::Base
  belongs_to :employee, :class_name => 'LegacyEmployee', :foreign_key => 'email'
end

class FooBar < ActiveRecord::Base
  has_many :reports
  grouped_scope :reports
end



