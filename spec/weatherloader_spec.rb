require 'spec_helper'

describe WeatherLoader do
  
  let(:weather_uri) { "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json" }

  context 'when no weather data is in Redis' do
    let(:wl) do
      redis = FakeRedis::Redis.new
      redis.del "current_weather"
      WeatherLoader.new(redis)
    end
    before { stub_request(:get, weather_uri).to_return(
               :status  => 200,
               :headers => { 'Content-Type' => 'application/json;charset=utf-8' },
               :body    => fixture('weather.json')) }

    describe '#get_weather' do
      it 'gets the current weather' do
        result = wl.get_weather
        expect(result).to be_a(Hash)
        expect(result['code']).to eq(28)
        expect(result['temp']).to eq(20)
        expect(result['text']).to eq('Mostly Cloudy')
      end
    end
  end

  context 'when weather data is already in Redis' do
    let(:weather) { {'temp' => 35, 'code' => 26, 'text' => 'Cloudy'} }
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
    let(:wl)  { WeatherLoader.new(FakeRedis::Redis.new) }
    before    { stub_request(:get, weather_uri).to_return(
                  :status  => 200,
                  :headers => { 'Content-Type' => 'application/json;charset=utf-8' },
                  :body    => fixture('weather.json')) }

    it 'downloads the weather as a hash' do
      result = wl.download_weather
      expect(result).to be_a(Hash)
      expect(result['code']).to eq(28)
      expect(result['temp']).to eq(20)
      expect(result['text']).to eq('Mostly Cloudy')
    end
  end
end