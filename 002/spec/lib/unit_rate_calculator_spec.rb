require_relative '../spec_helper.rb'

describe "The Unit Rate Calculator" do
  let (:unit) { :unit }
  let (:reservation_range) { :reservation_range }
  let (:tax_rate) { :tax_rate }

  it "can be instantiated" do
    UnitRateCalculator.new(unit, reservation_range, tax_rate).should_not be_nil
  end

  describe "when calculating rates" do
    describe "base rate calculation" do
      it "includes the unit's rate_for_date value for each date not including the last (constant)" do
        constant_rate = 7.0
        zero_cleaning_fee = 0.0;
        num_days = 2

        unit = Object.new
        unit.stub(:rate_for_date) { constant_rate }
        unit.stub(:cleaning_fee) { zero_cleaning_fee }

        res_range = Date.today.upto(Date.today + num_days)

        unit_rate_calculator = UnitRateCalculator.new(unit, res_range, tax_rate)
        unit_rate_calculator.base_rate.should == (constant_rate * num_days)
      end

      it "includes the unit's rate_for_date for each date not including the last (variable)" do
        res_range = Date.today.upto(Date.today + 3)
        rates = { res_range.to_a[0] => 1,
                  res_range.to_a[1] => 3,
                  res_range.to_a[2] => 5,
                  res_range.to_a[3] => 7 }

        unit = Object.new
        unit.stub(:cleaning_fee) { 0 }
        unit.stub(:rate_for_date) do |arg|
          rates[arg]
        end

        unit_rate_calculator = UnitRateCalculator.new(unit, res_range, tax_rate)
        unit_rate_calculator.base_rate.should == rates.values.take(rates.count - 1).inject{ |sum, x| sum + x }
      end

      it "includes the cleaning fee" do
        cleaning_fee = 42.0
        num_days = 2

        unit = Object.new
        unit.stub(:rate_for_date) { 0 }
        unit.stub(:cleaning_fee) { cleaning_fee }

        res_range = Date.today.upto(Date.today + num_days)

        unit_rate_calculator = UnitRateCalculator.new(unit, res_range, tax_rate)
        unit_rate_calculator.base_rate.should == cleaning_fee
      end
    end

    it "multiplies the base rate by the tax rate" do
      tax_rate = 2.0
      base_rate = 5.0
      unit_rate_calculator = UnitRateCalculator.new(:unit, :res_range, tax_rate)

      unit_rate_calculator.stub(:base_rate) { base_rate }

      unit_rate_calculator.calculate.should == tax_rate * base_rate;
    end
  end
end
