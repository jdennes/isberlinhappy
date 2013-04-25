require 'spec_helper'

describe DecisionMaker do

  describe '.get_decision_maker' do
    let (:weather) { {'temp' => 35, 'code' => 26, 'text' => 'Cloudy'} }
    let(:wl) do
      redis = FakeRedis::Redis.new
      redis.set "current_weather", weather.to_json
      WeatherLoader.new(redis)
    end

    it 'gets a DecisionMaker object ready to make decisions' do
      result = DecisionMaker.get_decision_maker(wl)
      expect(result).to be_a(DecisionMaker)
      expect(result.temp).to eq(35)
      expect(result.code).to eq(26)
      expect(result.text).to eq('Cloudy')
    end
  end

  context "when it's 20 degrees C and sunny" do
    let(:dm) { DecisionMaker.new(20, 32, 'Sunny') }

    describe '#temp_nice?' do
      it 'tells that the temperature is nice' do
        expect(dm.temp_nice?).to be_true
      end
    end

    describe '#conditions_nice?' do
      it 'tells that the conditions are nice' do
        expect(dm.conditions_nice?).to be_true
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("Yes!")
        expect(result[:details]).to eq("&mdash; Sunny and 20&deg;C in Berlin right now!")
      end
    end
  end

  context "when it's 15 degrees C and cloudy" do
    let(:dm) { DecisionMaker.new(15, 26, 'Cloudy') }

    describe '#temp_nice?' do
      it 'tells that the temperature is nice' do
        expect(dm.temp_nice?).to be_true
      end
    end

    describe '#conditions_nice?' do
      it 'tells that the conditions are nice' do
        expect(dm.conditions_nice?).to be_true
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("Yes!")
        expect(result[:details]).to eq("&mdash; Cloudy and 15&deg;C in Berlin right now!")
      end
    end
  end

  context "when it's 25 degrees C with showers" do
    let(:dm) { DecisionMaker.new(25, 11, 'Showers') }

    describe '#temp_nice?' do
      it 'tells that the temperature is nice' do
        expect(dm.temp_nice?).to be_true
      end
    end

    describe '#conditions_nice?' do
      it 'tells that the conditions are not nice' do
        expect(dm.conditions_nice?).to be_false
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("No!")
        expect(result[:details]).to eq("&mdash; Showers and 25&deg;C in Berlin right now!")
      end
    end
  end

  context "when it's 5 degrees C and sunny" do
    let(:dm) { DecisionMaker.new(-5, 32, 'Sunny') }

    describe '#temp_nice?' do
      it 'tells that the temperature is not nice' do
        expect(dm.temp_nice?).to be_false
      end
    end

    describe '#conditions_nice?' do
      it 'tells that the conditions are nice' do
        expect(dm.conditions_nice?).to be_true
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("No!")
        expect(result[:details]).to eq("&mdash; Sunny but only -5&deg;C in Berlin right now!")
      end
    end
  end

  context "when weather data can't be loaded" do
    let(:dm) { DecisionMaker.new(nil, nil, nil) }

    describe '#weather_hashed' do
      it "gets a hash of error weather" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("??")
        expect(result[:details]).to eq("&mdash; Sorry, something&rsquo;s broken!")
      end
    end
  end

end
