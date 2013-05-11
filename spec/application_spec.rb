require 'spec_helper'

set :environment, :test

describe "The isberlinhappytoday Sinatra application" do

  let(:weather_uri) { "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json" }
  let(:app) { Sinatra::Application }

  describe "/reset.css" do
    it "serves the reset stylesheet" do
      get "/reset.css"
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to eq('text/css;charset=utf-8')
    end
  end

  describe "/screen.css" do
    it "serves the screen stylesheet" do
      get "/screen.css"
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to eq('text/css;charset=utf-8')
    end
  end

  describe "/" do
    before do
      ENV['REDISTOGO_URL'] = 'redis://username:password@example.com:9465/'
      stub_request(:get, weather_uri).to_return(
        :status  => 200,
        :headers => { 'Content-Type' => 'application/json;charset=utf-8' },
        :body    => fixture('weather.json'))
    end

    it "serves the main page" do
      get "/"
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')
      expect(last_response.body).to include("&mdash; Mostly Cloudy and 20&deg;C in Berlin right now! &nbsp;<span class='icon'>&#xe007;</span>")
    end

    it "serves a JSON payload when the Accept header is set to application/json" do
      get "/", {}, {'HTTP_ACCEPT' => 'application/json'}
      expect(last_response).to be_ok
      expect(last_response.headers['Content-Type']).to eq('application/json;charset=utf-8')
      expect(last_response.body).to include('"happy":"Yes!"')
      expect(last_response.body).to include('"text":"Mostly Cloudy"')
      expect(last_response.body).to include('"temp":20')
    end
  end
end
