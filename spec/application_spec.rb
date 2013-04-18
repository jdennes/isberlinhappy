require 'spec_helper'

set :environment, :test

describe 'isberlinhappy app' do
  def app
    Sinatra::Application
  end

  it "should get a weather hash appropriate for when something in the app breaks" do
    result = error_weather
    result.should == {:happy => "??", :details => "Sorry, something's broken!"}
  end

  it "should tell when the whether the weather makes Berlin happy" do
    result = weather_makes_berlin_happy 20, 0
    result.should be_true
  end

  it "should tell when the whether the weather makes Berlin sad" do
    result = weather_makes_berlin_happy 12, 0
    result.should be_false
  end

  it "should get a weather hash for the current conditions in Berlin" do
    result = berlin_weather
    result[:happy].should_not be_nil
    result[:details].should match /&mdash; It's (\d+)&deg;C right now!/
  end

  it "should show whether berlin is happy today" do
    get '/'
    last_response.should be_ok
  end
end