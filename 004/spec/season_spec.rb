require 'blue_hawaii/season'

module BlueHawaii
  describe Season do
    describe '#date_in_season?' do
      let(:in_range_date) { Date.parse("11-02-09") }
      let(:out_of_range_date) { Date.parse("11-03-09") }
      let(:test_date) { Date.parse("11-05-08") }
      let(:other_season) {
        details = {
          "start" => "05-01", "end" => "05-13", "rate" => 137
        }
        Season.new("Test Season", details)
      }
      let(:season) {
        details = {
          "start" => "01-01", "end" => "03-01", "rate" => 250
        }
        Season.new("Test Season", details)
      }

      it 'returns true when date in range' do
        expect(season.date_in_range?(in_range_date)).to be(true)
        expect(other_season.date_in_range?(test_date)).to be(true)
      end

      it 'returns false when date out of range' do
        expect(season.date_in_range?(out_of_range_date)).to be(false)
      end
    end
  end
end

