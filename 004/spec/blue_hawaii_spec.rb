require 'blue_hawaii'

describe BlueHawaii do
  let(:test_input) { File.join(File.dirname(__FILE__), '../support/sample_input.txt') }
  let(:test_hotel_json_input) { File.join(File.dirname(__FILE__), '../support/sample_vacation_rentals.json') }
  let(:test_output) { File.join(File.dirname(__FILE__), '../support/sample_output.txt') }

  it 'gives the hotel rates for a given input' do
    expected = File.read(test_output).to_s
    expect(BlueHawaii.hotel_rates(test_input, test_hotel_json_input)).to eq(expected)
  end
end
