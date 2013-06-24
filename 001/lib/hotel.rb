#!/usr/bin/env ruby

require 'date'
require 'json'

def calculate_period season, date_range
  season.map(&:values).map(&:first).map do |period|
    rate = period['rate'][1..-1].to_f
    if period['start']
      start_date = Date.parse(date_range.first.year.to_s + "-" + period['start'])
      end_date = Date.parse(date_range.last.year.to_s + "-" + period['end'])
      if end_date < start_date 
        if end_date < date_range.first
          end_date = end_date.next_year
        elsif date_range.last < start_date
          start_date = start_date.prev_year
        end
      end
      days = ((start_date..end_date).to_a & date_range.to_a).count
      days * rate
    else
      date_range.count * rate
    end
  end.reduce(:+)
end
def dollar_fmt val
  "$%.2f" % val
end
def calculate_total data_file, input_file
  json = JSON.load(File.new(data_file))
  start_date, end_date = File.read(input_file).split(" - ").map {|str| Date.parse(str) }
  date_range = start_date..(end_date-1)
  json.map do |site|
    cleaning_fee = (site['cleaning fee'] || '$0')[1..-1].to_f
    rental_cost = calculate_period((site['seasons'] || [{"one" => site}]), date_range)
    site['name'] + ": " + dollar_fmt((cleaning_fee + rental_cost) * 1.0411416)
  end.join("\n")
end

if __FILE__ == $0
  if ARGV.count == 2
    print calculate_total(ARGV[0], ARGV[1])
  else
    puts "Usage: #{$0} <data-file> <input-file>"
  end
end
