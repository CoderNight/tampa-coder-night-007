require './spec_helper.rb'
require './rates.rb'

describe Season do
  let(:json) { JSON.parse( '{"start":"10-01","end":"05-13","rate":"$137"}' ) }
  let(:subject) { Season.new(json) }

  it "parses rate" do
    subject.rate.should == 137
  end

  it "parses start and end dates" do
    subject.start_month.should == 10
    subject.start_day.should   == 1
    subject.end_month.should   == 5
    subject.end_day.should     == 13
  end
end

describe Property do
  let(:json) { JSON.parse('{"name":"Fern Grove Lodge","seasons":[{"one":{"start":"05-01","end":"05-13","rate":"$137"}},{"two":{"start":"05-14","end":"04-30","rate":"$220"}}],"cleaning fee":"$98"}') }
  let(:subject) { Property.new(json) }

  it "parses name and cleaning fee from json" do
    subject.name.should         == "Fern Grove Lodge"
    subject.cleaning_fee.should == 98
  end

  it "parses seasons from json" do
    subject.should have(2).seasons
    subject.seasons[0].rate.should == 137
  end

  it "creates a default season if no seasons defined" do
    json = JSON.parse('{"name":"Paradise Inn","rate":"$250","cleaning fee":"$120"}')
    subject = Property.new(json)
    subject.should have(1).seasons
    subject.seasons[0].rate.should == 250
  end

  describe "calculating rates" do
    it "calculates a total including fees and taxes from a subtotal" do
      subject.total(100).should == (100 + 98) * SALES_TAX
    end

    it "calculates a daily rate" do
      subject.daily_rate(Date.new(2013, 1, 1)).should  == 0
      subject.daily_rate(Date.new(2013, 5, 1)).should  == 137
      subject.daily_rate(Date.new(2013, 11, 1)).should == 220
    end

    it "calculates rates from a single season" do
      start_date = Date.new(Date.today.year, 5, 2)
      end_date = Date.new(Date.today.year, 5, 12)
      subject.rate(start_date, end_date).should == ((137 * 10) + 98) * SALES_TAX
    end

    it "calculates rates from multiple seasons" do
      start_date = Date.new(Date.today.year, 5, 2)
      end_date = Date.new(Date.today.year, 5, 20)
      expected_sub = (137 * 12) + (220 * 6)
      subject.rate(start_date, end_date).should == (expected_sub + 98) * SALES_TAX
    end
  end
end

describe RateCalculator do
  let(:sample_rentals) do
    JSON.parse(File.read('./sample_vacation_rentals.json'))
  end

  describe "processes sample rentals file" do
    let(:subject) { RateCalculator.new(sample_rentals) }

    it "creates properties" do
      subject.properties.size.should == 3
      subject.properties.first.name.should == "Fern Grove Lodge"
      subject.properties.first.should have(2).seasons
    end

    it "calculates rates for all properties for a date range" do
      rates = subject.calculate_rates('./sample_input.txt')
      rates.size.should == 3
      rates["Fern Grove Lodge"].should == 2474.7935832
    end

    it "should format currency" do
      subject.format_currency(2474.7935832).should == "$2474.79"
      subject.format_currency(2474.08923).should   == "$2474.09"
      subject.format_currency(1275.3984600).should == "$1275.40"
    end

    it "should format output" do
      rates = subject.calculate_rates('./sample_input.txt')
      output = subject.format(rates)
      sample_output = File.read('./sample_output.txt')
      output.should == sample_output
    end
  end
end

