require 'spec_helper'

describe DecisionMaker do

  let(:weather_uri) { "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json" }

  context "when weather data can be successfully retrieved" do
    let(:weather) { {'temp' => 35, 'code' => 26, 'text' => 'Cloudy'} }
    let(:wl) do
      redis = FakeRedis::Redis.new
      redis.set "current_weather", weather.to_json
      WeatherLoader.new(redis)
    end

    describe '.get_decision_maker' do
      it 'gets a DecisionMaker object ready to make decisions' do
        result = DecisionMaker.get_decision_maker(wl)
        expect(result).to be_a(DecisionMaker)
        expect(result.temp).to eq(35)
        expect(result.code).to eq(26)
        expect(result.text).to eq('Cloudy')
      end
    end
  end

  context "when weather data cannot be retrieved" do
    let(:wl) do
      redis = FakeRedis::Redis.new
      redis.del "current_weather"
      WeatherLoader.new(redis)
    end
    before { stub_request(:get, weather_uri).to_return(
               :status  => 500,
               :headers => { 'Content-Type' => 'application/json;charset=utf-8' },
               :body    => "Something's broken!") }

    describe '.get_decision_maker' do
      it 'gets a DecisionMaker object which has no weather data' do
        result = DecisionMaker.get_decision_maker(wl)
        expect(result).to be_a(DecisionMaker)
        expect(result.code).to be_nil
        expect(result.temp).to be_nil
        expect(result.text).to be_nil
      end
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

    describe '#weather_icon' do
      it "gets an icon representing the weather conditions" do
        expect(dm.weather_icon).to eq("&#xe000;")
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("Yes!")
        expect(result[:details]).to eq("&mdash; Sunny and 20&deg;C in Berlin right now! &nbsp;<span class='icon'>&#xe000;</span>")
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

    describe '#weather_icon' do
      it "gets an icon representing the weather conditions" do
        expect(dm.weather_icon).to eq("&#xe018;")
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("Yes!")
        expect(result[:details]).to eq("&mdash; Cloudy and 15&deg;C in Berlin right now! &nbsp;<span class='icon'>&#xe018;</span>")
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

    describe '#weather_icon' do
      it "gets an icon representing the weather conditions" do
        expect(dm.weather_icon).to eq("&#xe011;")
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("No!")
        expect(result[:details]).to eq("&mdash; Showers and 25&deg;C in Berlin right now! &nbsp;<span class='icon'>&#xe011;</span>")
      end
    end
  end

  context "when it's -5 degrees C and sunny" do
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

    describe '#weather_icon' do
      it "gets an icon representing the weather conditions" do
        expect(dm.weather_icon).to eq("&#xe000;")
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("No!")
        expect(result[:details]).to eq("&mdash; Sunny but only -5&deg;C in Berlin right now! &nbsp;<span class='icon'>&#xe000;</span>")
      end
    end
  end

  context "when it's -2 degrees C and snowing" do
    let(:dm) { DecisionMaker.new(-2, 16, 'Snow') }

    describe '#temp_nice?' do
      it 'tells that the temperature is not nice' do
        expect(dm.temp_nice?).to be_false
      end
    end

    describe '#conditions_nice?' do
      it 'tells that the conditions are not nice' do
        expect(dm.conditions_nice?).to be_false
      end
    end

    describe '#weather_icon' do
      it "gets an icon representing the weather conditions" do
        expect(dm.weather_icon).to eq("&#xe016;")
      end
    end

    describe '#weather_hashed' do
      it "gets a hash of weather conditions" do
        result = dm.weather_hashed
        expect(result[:happy]).to eq("No!")
        expect(result[:details]).to eq("&mdash; Snow and only -2&deg;C in Berlin right now! &nbsp;<span class='icon'>&#xe016;</span>")
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

    describe '#weather_icon' do
      it "raises an error when there is no weather data to use" do
        expect { dm.weather_icon }.to raise_error "Can't get weather icon when this DecisionMaker has no weather data to use."
      end
    end
  end

end
