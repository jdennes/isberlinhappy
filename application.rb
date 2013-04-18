require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'sass'
require 'httparty'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

helpers do
  def versioned_stylesheet(style)
    "/#{style}.css?" + File.mtime(File.join(settings.public_folder, "scss", "#{style}.scss")).to_i.to_s
  end
end

before do
  content_type :html, :charset => 'utf-8'
end

%w(reset screen).each do |style|
  get "/#{style}.css" do
    content_type :css, :charset => 'utf-8'
    path = "public/scss/#{style}.scss"
    last_modified File.mtime(path)
    scss File.read(path)
  end
end

def error_weather
  {:happy => "??", :details => "Sorry, something's broken!"}
end

def weather_makes_berlin_happy(temp, code)
  # This decision will become smarter.
  temp.to_i > 15
end

def berlin_weather
  url = "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json"
  begin
    response = HTTParty.get url

    temp = response['query']['results']['channel']['item']['condition']['temp']
    code = response['query']['results']['channel']['item']['condition']['code']
    weather = {
      :happy => (weather_makes_berlin_happy(temp, code) ? 'Yes!' : 'No!'),
      :details => "&mdash; It's #{temp}&deg;C right now!"
    }
  rescue
    return error_weather
  end
  weather
end

get '/' do
  @weather = berlin_weather
  haml :index
end
