require 'json'
require 'blue_hawaii/hotel'

module BlueHawaii
  describe Hotel do
    let(:test_input) { File.join(File.dirname(__FILE__), '../support/sample_input.txt') }
    let(:test_json_input) { File.join(File.dirname(__FILE__), '../support/sample_vacation_rentals.json') }
    let(:test_json) { JSON.parse(File.read(test_json_input).to_s) }
    let(:simple_hotel_json) { test_json[1] }
    let(:complex_hotel_json) { test_json[0] }

    describe '#parse' do
      context 'with a simple hotel json' do
        let(:hotel) { Hotel.parse(simple_hotel_json) }

        it 'builds the correct hotel' do
          expect(hotel.name).to eq("Paradise Inn")
          expect(hotel.cleaning_fee).to eq(120)
          expect(hotel.seasons.length).to eq(1)
          expect(hotel.seasons.first.name).to eq("default")
          expect(hotel.seasons.first.rate).to eq(250)
        end
      end

      context 'with a complex hotel json' do
        let(:hotel) { Hotel.parse(complex_hotel_json) }
        it 'builds the correct hotel' do
          expect(hotel.name).to eq("Fern Grove Lodge")
          expect(hotel.cleaning_fee).to eq(98)
          expect(hotel.seasons.length).to eq(2)
          expect(hotel.seasons.first.name).to eq("one")
          expect(hotel.seasons.first.rate).to eq(137)
          expect(hotel.seasons.last.name).to eq("two")
          expect(hotel.seasons.last.rate).to eq(220)
        end
      end
    end

    describe '#rate_for(date)' do

      context 'simple hotel json' do
        let(:hotel) { Hotel.parse(simple_hotel_json) }

        it 'gives the correct rate for a given date' do
          expect(hotel.rate_for(Date.parse("2014/02/09"))).to eq("$385.22")
        end

        it 'gives the correct rate for a given date range' do
          date_input_string = File.read(test_input).to_s
          start_date = Date.parse("2014/02/09")
          end_date = Date.parse("2014/02/10")
          expect(hotel.rate_for(start_date..end_date)).to eq("$385.22")
          end_date = Date.parse("2014/02/11")
          expect(hotel.rate_for(start_date..end_date)).to eq("$645.51")
        end
      end

      context 'complex hotel json' do
        let(:hotel) { Hotel.parse(complex_hotel_json) }

        it 'gives the correct rate for a given date' do
          expect(hotel.rate_for(Date.parse("2014/02/09"))).to eq("$331.08")
        end

        it 'gives the correct rate for a given date range' do
          date_input_string = File.read(test_input).to_s
          start_date = Date.parse("2014/02/09")
          end_date = Date.parse("2014/02/10")
          expect(hotel.rate_for(start_date..end_date)).to eq("$331.08")
          end_date = Date.parse("2014/02/11")
          expect(hotel.rate_for(start_date..end_date)).to eq("$560.13")
        end
      end
    end
  end
end
