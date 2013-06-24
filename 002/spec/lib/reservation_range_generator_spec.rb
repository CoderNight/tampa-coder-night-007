require_relative '../spec_helper.rb'

describe "The Reservation Range Generator" do
  it "can be instantiated" do
    ReservationRangeGenerator.new.should_not be_nil
  end

  describe "when generating ranges" do
    let(:start_date_string) { "2011/04/02" }
    let(:end_date_string) { "2011/05/05" }
    let(:date_range_string) { "#{start_date_string} - #{end_date_string}" }

    let(:start_date) { Date.parse(start_date_string) }
    let(:end_date) { Date.parse(end_date_string) }

    let(:range_generator) { ReservationRangeGenerator.new }

    it "generates a range" do
      range_generator.generate(date_range_string).should_not be_nil
    end

    it "returns an enumerator with the start date" do
      range = range_generator.generate(date_range_string)
      range.first.should == start_date
    end

    it "returns an enumerator with the end date" do
      range = range_generator.generate(date_range_string)
      last_item = nil
      range.each { |x| last_item = x }

      last_item.should == end_date
    end
  end
end
