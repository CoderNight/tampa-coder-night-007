require_relative 'season'

module BlueHawaii
  class Hotel
    TAX_RATE = 1.0411416

    attr_accessor :name, :cleaning_fee, :seasons

    def initialize(hash)
      self.name = hash["name"]
      self.cleaning_fee = hash["cleaning fee"] || 0
      self.seasons = hash["seasons"].map { |season|
        name, details = season.to_a.flatten
        Season.new(name, details)
      }
    end

    def self.parse(json)
      if default_rate = json["rate"]
        json.delete("rate")
        json["seasons"] = [
          {"default" => {
            "start" => "01-01", "end" => "12-31", "rate" => default_rate
          }
        }]
      end

      if json["cleaning fee"]
        json["cleaning fee"] = json["cleaning fee"].gsub(/\$/, '').to_i
      end

      json["seasons"].each do |season|
        name, details = season.to_a.flatten
        details["rate"] = details["rate"].gsub(/\$/, '').to_i
      end

      new(json)
    end

    def rate_for(date)
      rate = if date.is_a?(Range)
        dates = date.to_a
        if dates.length > 1
          dates = dates.take(dates.length - 1)
        end

        dates.reduce(0) { |sum, date|
          if season = seasons.find { |season| season.date_in_range?(date) }
            sum += season.rate
          end
        }
      else
        season = seasons.find { |season| season.date_in_range?(date) }
        season.rate
      end || 0

      rate += cleaning_fee

      rate = (rate * TAX_RATE)
      rate = (rate * 10**2).round.to_f / 10**2

      "$#{"%.2f" % rate}"
    end

  end
end
