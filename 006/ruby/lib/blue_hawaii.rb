require "date"
require "json"

class BlueHawaii
  attr :rentals
  attr :dates

  def initialize(reservation, rentals)
    @dates = Range.new(*File.read(reservation).split(' - ').map { |d| Date.parse(d) })
    @rentals = JSON.parse(File.read(rentals)).map { |data| Rental.new(data)}
  end

  def inspect
    @rentals.inject("") do |output, rental|
      amount = rental.total_for_range(dates)
      output << "#{rental.name}: $#{"%.2f" % amount}\n"
    end
  end

  def self.money_to_number(money)
    if money
      Integer(money[1..-1])
    else
      0
    end
  end

  class Rental
    TAX_RATE = 4.11416

    attr :name, :seasons, :fee

    def initialize(data)
      @name = data["name"]
      @fee = BlueHawaii.money_to_number(data["cleaning fee"])
      @seasons = if data["seasons"]
        data["seasons"].map { |s| Season.new(*s.values[0].values_at(*%w[rate start end])) }
      else
        [Season.new(data["rate"], "01-01", "12-31")]
      end
    end

    def total_for_range(dates)
      total = dates.first(dates.count - 1).map { |d| rate(d) }.inject(:+)
      total += fee
      total += total * (TAX_RATE / 100)
    end

    def rate(date)
      seasons.find { |s| s.has?(date) }.rate
    end
  end

  class Season
    attr :rate
    attr :start_month
    attr :start_day
    attr :end_month
    attr :end_day

    def initialize(rate_string, start_string, end_string)
      @rate = BlueHawaii.money_to_number(rate_string)
      @start_month, @start_day = start_string.split("-").map(&:to_i)
      @end_month, @end_day = end_string.split("-").map(&:to_i)
    end

    def has?(date)
      if start_month <= end_month
        (date.month > start_month ||
          (date.month == start_month) && (date.day >= start_day)
        ) &&
        (date.month < end_month ||
          (date.month == end_month) && (date.day <= end_day)
        )
      else
        (date.month > start_month ||
          (date.month == start_month) && (date.day >= start_day)
        ) ||
        (date.month < end_month ||
          (date.month == end_month) && (date.day <= end_day)
        )
      end
    end
  end
end

