module BlueHawaii
  class Season
    attr_accessor :name, :start_date, :end_date, :rate

    def initialize(name, details)
      self.name = name
      self.start_date = details["start"]
      self.end_date = details["end"]
      self.rate = details["rate"]
    end

    def date_in_range?(date)
      year = date.year
      _start_date = Date.parse("#{year}-#{start_date}")
      _end_date = Date.parse("#{year}-#{end_date}")

      if _end_date < _start_date
        _end_date = Date.parse("#{year+1}-#{end_date}")
        if date < _start_date && year < _end_date.year
          date = Date.parse("#{year+1}-#{date.month}-#{date.day}")
        end
      end

      date >= _start_date && date <= _end_date
    end
  end
end
