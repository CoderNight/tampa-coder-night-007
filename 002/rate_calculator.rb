require 'bigdecimal'
require 'date'
require 'JSON'

def command_line_run
  units_json_string = File.open("vacation_rentals.json").read
  reservation_string = File.open("input.txt").read
  tax_rate = BigDecimal.new("1.0411416")

  rates = RateCalculator.new.calculate_rates(units_json_string, reservation_string, tax_rate)
  rates.each do |property, rate|
    puts "#{property} $#{'%.2f' % rate }"
  end
end

class RateCalculator
  def calculate_rates(units_json_string, reservation_string, tax_rate)
    unit_hydrator = UnitHydrator.new
    units = unit_hydrator.hydrate_json(units_json_string)

    reservation_range_generator = ReservationRangeGenerator.new
    reservation_range = reservation_range_generator.generate(reservation_string)

    unit_rates = {}
    units.each do |unit|
      unit_rate_calculator = UnitRateCalculator.new(unit, reservation_range, tax_rate)
      unit_rates[unit.name] = unit_rate_calculator.calculate
    end
    unit_rates
  end
end

class DayOfYear
  attr_reader :month, :day

  def initialize(month, day)
    @month = month
    @day = day
  end

  def ==(other)
    other.month == @month && other.day == @day
  end

  @first_day = DayOfYear.new(1, 1)
  @last_day = DayOfYear.new(12, 31)

  def self.first_day
    @first_day
  end

  def self.last_day
    @last_day
  end
end

class Season
  # TODO: enforce that start is before end?
  attr_reader :start_day_of_year, :end_day_of_year, :rate

  def initialize(start_day_of_year, end_day_of_year, rate)
    @start_day_of_year = start_day_of_year
    @end_day_of_year = end_day_of_year
    @rate = rate
  end

  def contains(date)
    first_day = Date.new(date.year, @start_day_of_year.month, @start_day_of_year.day)
    last_day = Date.new(date.year, @end_day_of_year.month, @end_day_of_year.day)

    first_day <= date && date <= last_day
  end

  def ==(other)
    other.start_day_of_year == @start_day_of_year \
      && other.end_day_of_year == @end_day_of_year \
      && other.rate == @rate
  end
end

class Unit
  attr_reader :name, :seasons, :cleaning_fee

  def initialize(name, seasons, cleaning_fee)
    @name = name
    @seasons = seasons
    @cleaning_fee = cleaning_fee
  end

  def rate_for_date(date)
    @seasons.each do |season|
      return season.rate if season.contains(date)
    end
    0
  end
end

class UnitHydrator
  def hydrate_json(units_json_string)
    return [] if units_json_string.nil? || (0 == units_json_string.length)

    JSON.parse(units_json_string).map { |unit_dict| parse_unit(unit_dict) }
  end

  private
    def parse_unit(unit_dict)
      name = parse_name(unit_dict)
      seasons = parse_seasons(unit_dict)
      cleaning_fee = parse_cleaning_fee(unit_dict)

      Unit.new(name, seasons, cleaning_fee)
    end

    def parse_name(unit_dict)
      unit_dict["name"]
    end

    def parse_seasons(unit_dict)
      seasons = []

      unless (json_seasons = unit_dict["seasons"]).nil?
        json_seasons.each do |json_season_dict|
          json_season_dict.values.each do |json_season|
            seasons.push(*parse_season(json_season))
          end
        end
      else
        rate = parse_rate(unit_dict)
        seasons << Season.new(DayOfYear.first_day, DayOfYear.last_day, rate)
      end

      seasons
    end

    def parse_season(json_season)
      rate = parse_rate(json_season)

      start_month, start_day = split_month_and_day(json_season["start"])
      start_day_of_year = DayOfYear.new(start_month, start_day)

      end_month, end_day = split_month_and_day(json_season["end"])
      end_day_of_year = DayOfYear.new(end_month, end_day)

      overlaps_new_year = (end_month < start_month) || ((end_month == start_month) && (end_day < start_day))
      if(overlaps_new_year)
        return [ Season.new(DayOfYear.first_day, end_day_of_year, rate),
                 Season.new(start_day_of_year, DayOfYear.last_day, rate) ]
      else
        return Season.new(start_day_of_year, end_day_of_year, rate)
      end
    end

    def parse_rate(json_dict)
      BigDecimal.new(json_dict["rate"][1..-1])
    end

    def parse_cleaning_fee(json_dict)
      cleaning_fee_string = json_dict["cleaning fee"]
      if cleaning_fee_string.nil?
        cleaning_fee = 0
      else
        cleaning_fee = BigDecimal.new(cleaning_fee_string[1..-1])
      end
    end

    def split_month_and_day(month_day_string)
      month_day_string.split("-").map { |int_str| int_str.to_i }
    end
end

class ReservationRangeGenerator
  def generate(date_range_string)
    start_date, end_date = date_range_string.split("-").map { |x| Date.parse(x) }
    start_date.upto(end_date)
  end
end

class UnitRateCalculator
  def initialize(unit, reservation_range, tax_rate)
    @unit = unit
    @reservation_range = reservation_range
    @tax_rate = tax_rate
  end

  def base_rate
    total = 0
    @reservation_range.take(@reservation_range.count - 1).each do |date|
      total += @unit.rate_for_date(date)
    end
    total += @unit.cleaning_fee
  end

  def calculate
    base_rate * @tax_rate
  end
end

command_line_run if __FILE__==$0
