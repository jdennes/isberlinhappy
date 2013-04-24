require 'spec_helper'

set :environment, :test

describe 'isberlinhappy app' do
  def app
    Sinatra::Application
  end

  it "should get a hash of weather conditions when it's 20 degrees C and sunny" do
    result = weather_hashed 20, 32, "Sunny"
    result[:happy].should == "Yes!"
    result[:details].should == "&mdash; Sunny and 20&deg;C in Berlin right now!"
  end

  it "should get a hash of weather conditions when it's 15 degrees C and cloudy" do
    result = weather_hashed 20, 32, "Cloudy"
    result[:happy].should == "Yes!"
    result[:details].should == "&mdash; Cloudy and 20&deg;C in Berlin right now!"
  end

  it "should get a hash of weather conditions when it's 25 degrees C with showers" do
    result = weather_hashed 25, 11, "Showers"
    result[:happy].should == "No!"
    result[:details].should == "&mdash; Showers and 25&deg;C in Berlin right now!"
  end

  it "should get a hash of weather conditions when it's 5 degrees C and sunny" do
    result = weather_hashed -5, 32, "Sunny"
    result[:happy].should == "No!"
    result[:details].should == "&mdash; Sunny but only -5&deg;C in Berlin right now!"
  end

  it "should get a hash of weather conditions when something in the app breaks" do
    result = error_weather
    result.should == {:happy => "??", :details => "Sorry, something's broken!"}
  end

  it "should show whether or not berlin is happy today" do
    get '/'
    last_response.should be_ok
  end
end