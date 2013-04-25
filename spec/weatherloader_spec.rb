require 'spec_helper'

describe WeatherLoader do

  context 'when no weather data is in Redis' do
    let(:wl) { WeatherLoader.new(FakeRedis::Redis.new) }
  
    describe '#get_weather' do
      it 'gets the current weather' do
        result = wl.get_weather
        expect(result).to be_a(Hash)
        expect(result).to have_key('temp')
        expect(result).to have_key('code')
        expect(result).to have_key('text')
      end
    end
  end

  context 'when weather data is already in Redis' do
    let (:weather) { {'temp' => 35, 'code' => 26, 'text' => 'Cloudy'} }
    let(:wl) do
      redis = FakeRedis::Redis.new
      redis.set "current_weather", weather.to_json
      WeatherLoader.new(redis)
    end

    describe '#get_weather' do
      it 'gets the current weather' do
        result = wl.get_weather
        expect(result).to eq(weather)
      end
    end
  end

  describe '#download_weather' do
    let(:wl) { WeatherLoader.new(FakeRedis::Redis.new) }

    it 'downloads the weather as a hash' do
      result = wl.download_weather
      expect(result).to be_a(Hash)
      expect(result).to have_key('temp')
      expect(result).to have_key('code')
      expect(result).to have_key('text')
    end
  end
end