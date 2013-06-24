#!/usr/bin/env ruby
require 'date'
require 'json'

SALES_TAX = 1.0411416

class String
  def currency_to_i
    gsub(/\$/,'').to_i
  end
end

class Season
  attr_accessor :start_month, :start_day, :rate
  attr_accessor :end_month, :end_day, :end_year_increment

  def initialize(json=nil)
    parse(json) if json
  end

  def month_day(str)
    str.split('-').map(&:to_i)
  end

  def parse(json)
    self.rate                        = json["rate"].currency_to_i
    self.start_month, self.start_day = month_day(json["start"])
    self.end_month, self.end_day     = month_day(json["end"])
    self.end_year_increment          = (end_month < start_month ? 1 : 0)
  end
end

class Property
  attr_accessor :name, :seasons, :cleaning_fee

  def initialize(json=nil)
    self.cleaning_fee = 0
    self.seasons      = []
    parse(json) if json
  end

  def parse(json)
    self.name         = json["name"]
    self.cleaning_fee = json["cleaning fee"].currency_to_i if json["cleaning fee"]

    if json["seasons"]
      self.seasons = json["seasons"].map do |entry|
        Season.new(entry.values[0])
      end
    else
      season      = Season.new
      season.rate = json["rate"].currency_to_i
      seasons << season
    end
  end

  def daily_rate(day)
    season = seasons.find do |season|
      if season.start_month.nil?
        true
      else
        start_date = Date.new(day.year, season.start_month, season.start_day)
        end_date   = Date.new(day.year + season.end_year_increment, season.end_month, season.end_day)
        day >= start_date && day <= end_date
      end
    end

    (season ? season.rate : 0)
  end

  def rate(start_date, end_date)
    subtotal = (start_date...end_date).inject(0) do |sum, day|
      sum += daily_rate(day)
      sum
    end

    total(subtotal)
  end

  def total(subtotal)
    (subtotal + cleaning_fee) * SALES_TAX
  end
end

class RateCalculator
  attr_accessor :properties

  def initialize(json=nil)
    self.properties = []
    parse_properties(json) if json
  end

  def parse_properties(json)
    self.properties = json.map { |entry| Property.new(entry) }
  end

  def calculate_rates(input_filename)
    raise 'No rental properties defined' unless properties.any?

    date_range = File.read(input_filename)
    dates = date_range.split(' - ').map { |s| Date.strptime(s, "%Y/%m/%d") }
    properties.inject({}) do |dict, property|
      dict[property.name] = property.rate(dates[0], dates[1])
      dict
    end
  end

  def format_currency(amt)
    formatted = "$#{amt.round(2)}"
    (formatted[-3] == '.' ? formatted : formatted << "0")
  end

  def format(rates)
    rates.map do |location, rate|
      "#{location}: #{format_currency(rate)}"
    end.join("\n")
  end
end

if ARGV.size == 2
  rentals_file, dates_file = ARGV
  rentals_json = JSON.parse(File.read(rentals_file))
  calculator   = RateCalculator.new(rentals_json)
  rates        = calculator.calculate_rates(dates_file)
  puts calculator.format(rates)
else
  puts "Usage: rates.rb vacation_rentals.json input_dates.txt"
end

