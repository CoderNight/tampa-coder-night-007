require_relative '../spec_helper.rb'

describe "The Rate Calculator (Integration)" do
  it "calculates rates correctly for simple input" do
    rate_calculator = RateCalculator.new

    json_units = '[{"name":"Fern Grove Lodge","seasons":[{"one":{"start":"05-01","end":"05-13","rate":"$137"}},{"two":{"start":"05-14","end":"04-30","rate":"$220"}}],"cleaning fee":"$98"}]'
    reservation_string = "2011/05/07 - 2011/05/20"
    tax_rate = 1.05

    dict_results = rate_calculator.calculate_rates(json_units, reservation_string, tax_rate)

    dict_results.should_not be_nil
    dict_results.count.should == 1
    dict_results.keys[0].should == "Fern Grove Lodge"
    dict_results.values[0].should == 2495.85
  end
end
