require 'rspec'

require File.join(File.dirname(__FILE__), '../rate_calculator.rb')

RSpec::Matchers.define :be_a_full_year do
  match do |actual|
    actual.start_day_of_year.should == DayOfYear.first_day
    actual.end_day_of_year.should == DayOfYear.last_day
  end
end
