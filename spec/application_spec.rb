require 'spec_helper'

set :environment, :test

describe 'isberlinhappy app' do
  def app
    Sinatra::Application
  end

  it "should report that Berlin is happy when it's 20 degrees C and sunny" do
    result = weather_makes_berlin_happy 20, 32
    result.should be_true # Yes - warm and sunny!
  end

  it "should report that Berlin is happy when it's 15 degrees C and cloudy" do
    result = weather_makes_berlin_happy 15, 26
    result.should be_true # Yes - warm and cloudy!
  end

  it "should report that Berlin is NOT happy when it's 25 degrees C with showers" do
    result = weather_makes_berlin_happy 25, 11
    result.should be_false # No - warm, but showers!
  end

  it "should report that Berlin is NOT happy when it's 5 degrees C and sunny" do
    result = weather_makes_berlin_happy 12, 34
    result.should be_false # No - sunny, but too cold!
  end

  it "should get a hash of weather conditions which make Berlin happy" do
    result = weather_hashed true, 20, 32, "Sunny"
    result[:happy].should == "Yes!"
    result[:details].should == "&mdash; Sunny and 20&deg;C in Berlin right now!"
  end

  it "should get a hash of weather conditions which make Berlin NOT happy" do
    result = weather_hashed false, 25, 11, "Showers"
    result[:happy].should == "No!"
    result[:details].should == "&mdash; Showers and 25&deg;C in Berlin right now!"
  end

  it "should get a weather hash appropriate for when something in the app breaks" do
    result = error_weather
    result.should == {:happy => "??", :details => "Sorry, something's broken!"}
  end

  it "should show whether berlin is happy today" do
    get '/'
    last_response.should be_ok
  end
end