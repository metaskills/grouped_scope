require 'rubygems'
require 'bundler'
require "bundler/setup"
Bundler.require(:default, :development, :test)
require 'grouped_scope'
require 'minitest/autorun'
require 'factories'
require 'logger'


ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__),'debug.log'))
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
module ActiveRecord
  class SQLCounter
    cattr_accessor :ignored_sql
    self.ignored_sql = [/^PRAGMA table_info\(.*\)/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/, /^BEGIN/, /^COMMIT/]
    ignored_sql.concat [/^select .*nextval/i, /^SAVEPOINT/, /^ROLLBACK TO/, /^\s*select .* from all_triggers/im]
    def initialize
      $queries_executed = []
    end
    def call(name, start, finish, message_id, values)
      sql = values[:sql]
      unless 'CACHE' == values[:name]
        $queries_executed << sql unless self.class.ignored_sql.any? { |r| sql =~ r }
      end
    end
  end
  ActiveSupport::Notifications.subscribe('sql.active_record', SQLCounter.new)
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
      $queries_executed
    ensure
      failed_patterns = []
      patterns_to_match.each do |pattern|
        failed_patterns << pattern unless $queries_executed.any?{ |sql| pattern === sql }
      end
      assert failed_patterns.empty?, "Query pattern(s) #{failed_patterns.map{ |p| p.inspect }.join(', ')} not found.#{$queries_executed.size == 0 ? '' : "\nQueries:\n#{$queries_executed.join("\n")}"}"
    end

    def assert_queries(num = 1)
      $queries_executed = []
      yield
    ensure
      assert_equal num, $queries_executed.size, "#{$queries_executed.size} instead of #{num} queries were executed.#{$queries_executed.size == 0 ? '' : "\nQueries:\n#{$queries_executed.join("\n")}"}"
    end

    def assert_no_queries
      assert_queries(0) { yield }
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

class Department < ActiveRecord::Base
  scope :it, where(:name => 'IT')
  scope :hr, where(:name => 'Human Resources')
  scope :finance, where(:name => 'Finance')
  has_many :department_memberships
  has_many :employees, :through => :department_memberships
end

class DepartmentMembership < ActiveRecord::Base
  belongs_to :employee
  belongs_to :department
end

class Report < ActiveRecord::Base
  scope :with_urgent_title, where(:title => 'URGENT')
  scope :with_urgent_body, where("body LIKE '%URGENT%'")
  belongs_to :employee
  def urgent_title? ; self[:title] == 'URGENT' ; end
  def urgent_body? ; self[:body] =~ /URGENT/ ; end
end

class LegacyReport < ActiveRecord::Base
  belongs_to :employee, :class_name => 'LegacyEmployee', :foreign_key => 'email'
end

class Employee < ActiveRecord::Base
  has_many :reports do ; def urgent ; find(:all,:conditions => {:title => 'URGENT'}) ; end ; end
  has_many :taxonomies, :as => :classable
  has_many :department_memberships
  has_many :departments, :through => :department_memberships
  grouped_scope :reports, :departments
end

class LegacyEmployee < ActiveRecord::Base
  set_primary_key :email
  has_many :reports, :class_name => 'LegacyReport', :foreign_key => 'email'
  grouped_scope :reports
end

class FooBar < ActiveRecord::Base
  has_many :reports
  grouped_scope :reports
end



