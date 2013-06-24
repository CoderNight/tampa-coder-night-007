require_relative '../spec_helper.rb'

describe "The Rate Calculator" do
  before do
    @units_json_string_input = "units json string input"
    @reservation_string_input = "reservation string input"
    @tax_rate = 0.42

    @unit_hydrator = Object.new
    UnitHydrator.stub(:new) { @unit_hydrator }

    @hydrated_units = {}
    @unit_hydrator.stub(:hydrate_json) { @hydrated_units }

    @reservation_range_generator = Object.new
    ReservationRangeGenerator.stub(:new) { @reservation_range_generator }

    @reservation_range = Object.new
    @reservation_range_generator.stub(:generate) { @reservation_range }

  end

  describe "when calculating rates" do
    it "sends the unit JSON input to a UnitHydrator" do
      @unit_hydrator = Object.new
      @unit_hydrator.should_receive(:hydrate_json).with(@units_json_string_input).and_return(@hydrated_units)

      RateCalculator.new.calculate_rates(@units_json_string_input, @reservation_string_input, @tax_rate)
    end

    it "sends the reservation string to a ReservationRangeGenerator" do
      @reservation_range_generator = Object.new
      @reservation_range_generator.should_receive(:generate).with(@reservation_string_input).and_return(@reservation_range)

      RateCalculator.new.calculate_rates(@units_json_string_input, @reservation_string_input, @tax_rate)
    end

    it "uses a UnitRateCalculator to generate rates for each unit" do
      unit1_name = "unit 1 name"
      unit1 = Object.new
      unit1.stub(:name) { unit1_name }

      unit2_name = "unit 2 name"
      unit2 = Object.new
      unit2.stub(:name) { unit2_name }

      @hydrated_units = [ unit1, unit2 ]

      unit_return_values = {}
      @hydrated_units.each do |unit|
        unit_rate_calculator = Object.new
        UnitRateCalculator.should_receive(:new).with(unit, @reservation_range, @tax_rate).and_return(unit_rate_calculator)

        unit_return_value = Object.new
        unit_return_values[unit] = unit_return_value
        unit_rate_calculator.should_receive(:calculate).and_return(unit_return_value)
      end

      calculated_rates = RateCalculator.new.calculate_rates(@units_json_string_input, @reservation_string_input, @tax_rate)
      calculated_rates.count.should == @hydrated_units.count
      @hydrated_units.each do |unit|
        calculated_rates[unit.name].should == unit_return_values[unit]
      end
    end
  end
end
