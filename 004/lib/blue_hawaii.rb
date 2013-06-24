require 'date'
require 'json'

require_relative 'blue_hawaii/hotel'

module BlueHawaii
  def self.hotel_rates(date_input, hotels_json_input)

    date_input_string = File.read(date_input).to_s
    start_date, end_date = date_input_string.split(" - ").map { |date| Date.parse(date) }

    hotels_json = JSON.parse(File.read(hotels_json_input).to_s)
    hotels = hotels_json.map { |json| Hotel.parse(json) }

    rates = hotels.map { |hotel| "#{hotel.name}: #{hotel.rate_for(start_date..end_date)}" }

    puts rates.join("\n")
    rates.join("\n")
  end
end
