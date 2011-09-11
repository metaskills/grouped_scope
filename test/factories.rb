FactoryGirl.define do
  
  sequence(:id)     { |n| n }
  sequence(:email)  { |n| "test_#{n}@domain.com" }
  sequence(:title)  { |n| "Report Title ##{n}" }

  factory :report do
    title     { FactoryGirl.generate(:title) }
    body      'Bla bla bla. Bla. Bla bla.'
  end
  
  factory :employee do
    name      { "Factory Employee ##{FactoryGirl.generate(:id)}" }
    email     { FactoryGirl.generate(:email) }
  end

  factory :employee_with_reports, :parent => :employee do
    reports   { |e| [e.association(:report), e.association(:report)] }
  end

  factory :employee_with_urgent_reports, :parent => :employee do
    reports   { |e| [e.association(:report), e.association(:report, :title=>'URGENT'), 
                     e.association(:report), e.association(:report, :body=>'This is URGENT.')] }
  end

  factory :legacy_employee do
    name      { "Legacy Factory Employee ##{FactoryGirl.generate(:id)}" }
    email     { FactoryGirl.generate(:email) }
  end

  factory :legacy_report do |r|
    r.title   { FactoryGirl.generate(:title) }
    r.body    'Legacy bla bla. Legacy. Legacy bla.'
  end

  factory :legacy_employee_with_reports, :parent => :legacy_employee do
    reports   { |e| [e.association(:legacy_report), e.association(:legacy_report)] }
  end

end

