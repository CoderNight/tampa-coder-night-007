require_relative '../spec_helper.rb'

describe "A Rental Unit" do
  before do
    @name = :unit_name
    @seasons = :seasons
    @cleaning_fee = :cleaning_fee
    @unit = Unit.new(@name, @seasons, @cleaning_fee)
  end

  subject { @unit }

  it { should respond_to(:name) }
  it { should respond_to(:seasons) }
  it { should respond_to(:cleaning_fee) }

  it { should_not respond_to(:name=) }
  it { should_not respond_to(:seasons=) }
  it { should_not respond_to(:cleaning_fee=) }

  it "can be instantiated" do
    Unit.new(@name, @seasons, @cleaning_fee).should_not be_nil
  end

  it "can be instantiated and set property values" do
    unit = Unit.new(@name, @seasons, @cleaning_fee)

    unit.name.should == @name
    unit.seasons.should == @seasons
    unit.cleaning_fee.should == @cleaning_fee
  end

  describe "when calculating the rate for a date" do
    it "returns 0 if no seasons contain the date" do
      unit = Unit.new(@name, [], @cleaning_fee)
      unit.rate_for_date(Date.today).should == 0
    end

    it "returns the rate for the unit's only season if there is only one season" do
      rate = :rate
      season = Object.new
      season.stub(:contains) { true }
      season.stub(:rate) { rate }

      unit = Unit.new(@name, [season], @cleaning_fee)
      unit.rate_for_date(Date.today).should == rate
    end

    it "returns the rate for the first matching season if there are multiple seasons" do
      rate0 = :rate0
      season0 = Object.new
      season0.stub(:contains) { false }
      season0.stub(:rate) { rate0 }

      rate1 = :rate1
      season1 = Object.new
      season1.stub(:contains) { true }
      season1.stub(:rate) { rate1 }

      rate2 = :rate2
      season2 = Object.new
      season2.stub(:contains) { true }
      season2.stub(:rate) { rate2 }

      unit = Unit.new(@name, [season0, season1, season2], @cleaning_fee)
      unit.rate_for_date(Date.today).should == rate1
    end
  end
end
