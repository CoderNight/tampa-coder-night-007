require_relative '../spec_helper.rb'

describe "Season" do
  let (:start_day_of_year) { :start_day_of_year }
  let (:end_day_of_year) { :end_day_of_year }
  let (:rate) { :rate }
  let (:season) { Season.new(start_day_of_year, end_day_of_year, rate) }

  subject { season }

  it {should respond_to(:start_day_of_year) }
  it {should_not respond_to(:start_day_of_year=) }

  it {should respond_to(:end_day_of_year) }
  it {should_not respond_to(:end_day_of_year=) }

  it {should respond_to(:rate) }
  it {should_not respond_to(:rate=) }

  it "can be instantiated" do
    Season.new(start_day_of_year, end_day_of_year, rate).should_not be_nil
  end

  it "can be instantiated and set property values" do
    season = Season.new(start_day_of_year, end_day_of_year, rate)

    season.start_day_of_year.should == start_day_of_year
    season.end_day_of_year.should == end_day_of_year
    season.rate.should == rate
  end

  describe "when calculating contained dates" do
    start_date = Date.parse("2013/04/09")
    end_date = Date.parse("2013/05/15")
    season = Season.new(start_date, end_date, :rate_not_used)

    {start_date: start_date,
    date_after_start_date: start_date + 1,
    date_before_end_date: end_date - 1,
    end_date: end_date }.each do |desc, date|
      it "returns true for a contained date (#{desc})" do
        season.contains(date).should be_true
      end
    end

    {date_before_start_date: start_date - 1,
    date_after_end_date: end_date + 1 }.each do |desc, date|
      it "returns false for an outside date (#{desc})" do
        season.contains(date).should be_false
      end
    end
  end

  describe "the == method" do
    let (:start_day_of_year) { :start_day_of_year }
    let (:end_day_of_year) { :end_day_of_year }
    let (:rate) { :rate }
    let (:ref_season) { Season.new(start_day_of_year, end_day_of_year, rate) }

    it "returns true if start_day_of_year, end_day_of_year, and rate are the same" do
      Season.new(start_day_of_year, end_day_of_year, rate).should == ref_season
    end

    it "returns false if start_day_of_year is different" do
      Season.new(:other_start, end_day_of_year, rate).should_not == ref_season
    end

    it "returns false if end_day_of_year is different" do
      Season.new(start_day_of_year, :other_end, rate).should_not == ref_season
    end

    it "returns false if rate is different" do
      Season.new(start_day_of_year, end_day_of_year, :other_rate).should_not == ref_season
    end
  end
end
