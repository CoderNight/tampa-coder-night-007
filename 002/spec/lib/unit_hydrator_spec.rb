require_relative '../spec_helper.rb'

describe "The Unit Hydrator" do
  before do
    @unit_hydrator = UnitHydrator.new
  end

  describe "hydrating units" do
    [nil, ""].each do |empty_value|
      it "returns no units for empty JSON (#{empty_value || 'nil'})" do
        ret_val = @unit_hydrator.hydrate_json(empty_value)
        ret_val.should_not be_nil
        ret_val.count.should == 0
      end
    end

    describe "reading a single unit" do
      it "reads a single unit" do
        units_json_string = %{[{"name":"doesntmatter","rate":"$42"}]}
        unit_results = @unit_hydrator.hydrate_json(units_json_string)
        unit_results.should_not be_nil
        unit_results.count.should == 1
      end

      it "reads the unit name" do
        unit_name = "Paradise Inn"
        units_json_string = %{[{"name":"#{unit_name}","rate":"$42"}]}
        unit_results = @unit_hydrator.hydrate_json(units_json_string)
        unit_results[0].name.should == unit_name
      end

      describe "when cleaning fee is specified" do
        it "reads the cleaning fee" do
            cleaning_fee = 120
            units_json_string = %{[{"name":"doesntmatter","rate":"$42","cleaning fee":"$#{cleaning_fee}"}]}
            unit_results = @unit_hydrator.hydrate_json(units_json_string)
            unit_results[0].cleaning_fee.should == cleaning_fee
        end
      end

      describe "when cleaning fee is not specified" do
        it "sets cleaning fee to 0" do
            units_json_string = %{[{"name":"doesntmatter","rate":"$42"}]}
            unit_results = @unit_hydrator.hydrate_json(units_json_string)
            unit_results[0].cleaning_fee.should == 0
        end
      end

      describe "when no seasons are specified" do
        it "returns a unit with 1 full year season" do
          unit_rate = 250
          units_json_string = %{[{"name":"doesntmatter","rate":"$#{unit_rate}"}]}
          unit_results = @unit_hydrator.hydrate_json(units_json_string)

          unit = unit_results[0]
          unit.seasons.should_not be_nil
          unit.seasons.count.should == 1

          unit.seasons[0].should be_a_full_year
          unit.seasons[0].rate.should == unit_rate
        end
      end

      describe "when two seasons are specified" do
        it "returns a unit with two seasons if seasons do not overlap new years" do
          unit_1_rate = 137
          unit_2_rate = 220

          units_json_string = %{[{"name":"doesntmatter","seasons":[{"one":{"start":"01-01","end":"01-13","rate":"$#{unit_1_rate}"}},{"two":{"start":"01-14","end":"12-31","rate":"$#{unit_2_rate}"}}]}]}

          unit_results = @unit_hydrator.hydrate_json(units_json_string)

          unit = unit_results[0]
          unit.seasons.should_not be_nil
          unit.seasons.count.should == 2

          unit.seasons[0].should == Season.new(DayOfYear.new(1, 1), DayOfYear.new(1, 13), unit_1_rate)
          unit.seasons[1].should == Season.new(DayOfYear.new(1, 14), DayOfYear.new(12, 31), unit_2_rate)
        end

        it "returns a unit with three seasons if seasons overlap new years (same month)" do
          unit_1_rate = 137
          unit_2_rate = 220

          units_json_string = %{[{"name":"doesntmatter","seasons":[{"one":{"start":"01-15","end":"01-30","rate":"$#{unit_1_rate}"}},{"two":{"start":"01-31","end":"01-14","rate":"$#{unit_2_rate}"}}]}]}

          unit_results = @unit_hydrator.hydrate_json(units_json_string)

          unit = unit_results[0]
          unit.seasons.should_not be_nil
          unit.seasons.count.should == 3

          unit.seasons[0].should  == Season.new(DayOfYear.new(1, 15), DayOfYear.new(1, 30), unit_1_rate)
          unit.seasons[1].should == Season.new(DayOfYear.new(1, 1), DayOfYear.new(1, 14), unit_2_rate)
          unit.seasons[2].should == Season.new(DayOfYear.new(1, 31), DayOfYear.new(12, 31), unit_2_rate)
        end

        it "returns a unit with three seasons if seasons overlap new years (different month)" do
          unit_1_rate = 137
          unit_2_rate = 220

          units_json_string = %{[{"name":"doesntmatter","seasons":[{"one":{"start":"01-30","end":"03-15","rate":"$#{unit_1_rate}"}},{"two":{"start":"03-16","end":"01-29","rate":"$#{unit_2_rate}"}}]}]}

          unit_results = @unit_hydrator.hydrate_json(units_json_string)

          unit = unit_results[0]
          unit.seasons.should_not be_nil
          unit.seasons.count.should == 3

          unit.seasons[0].should == Season.new(DayOfYear.new(1, 30), DayOfYear.new(3, 15), unit_1_rate)
          unit.seasons[1].should == Season.new(DayOfYear.new(1, 1), DayOfYear.new(1, 29), unit_2_rate)
          unit.seasons[2].should == Season.new(DayOfYear.new(3, 16), DayOfYear.new(12, 31), unit_2_rate)
        end
      end
    end

    it "can hydrate multiple units" do
      unit_1_name = "unit_1"
      unit_1_rate = 42
      unit_1_cleaning_fee = 120

      unit_2_name = "unit_2"
      unit_2_rate = 314
      unit_2_cleaning_fee = 67

      units_json_string = %{[{"name":"#{unit_1_name}","rate":"$#{unit_1_rate}","cleaning fee":"$#{unit_1_cleaning_fee}"},{"name":"#{unit_2_name}","rate":"$#{unit_2_rate}","cleaning fee":"$#{unit_2_cleaning_fee}"}]}
      unit_results = @unit_hydrator.hydrate_json(units_json_string)

      #TODO: lots of assertions
      unit_results.count.should == 2
      unit_results[0].name.should == unit_1_name
      unit_results[0].seasons[0].rate.should == unit_1_rate
      unit_results[0].seasons[0].should be_a_full_year
      unit_results[0].cleaning_fee.should == unit_1_cleaning_fee

      unit_results[1].name.should == unit_2_name
      unit_results[1].seasons[0].rate.should == unit_2_rate
      unit_results[1].seasons[0].should be_a_full_year
      unit_results[1].cleaning_fee.should == unit_2_cleaning_fee
    end
  end
end
