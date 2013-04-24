require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'sass'
require 'httparty'

configure do
  require 'newrelic_rpm' if production?
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

def temp_nice?(temp)
  temp >= 15
end

def conditions_nice?(code)
  # Mapped from: http://developer.yahoo.com/weather/#codes
  lightning_thunder   = [0,1,2,3,4,37,38,39,45,47] # lightning/thunder
  sleet_drizzle_rain  = [5,6,7,8,9,10,11,12,18,40] # sleet/drizzle/rain
  snow                = [13,14,15,16,41,42,43,46]  # snow
  hail                = [17,35]                    # hail
  haze_dust           = [19..22]                   # haze/dust
  windy               = [23,24]                    # windy
  cloudy              = [25,26,44]                 # cloudy
  partly_cloudy_night = [27,29]                    # partly cloudy - night
  partly_cloudy_day   = [28,30]                    # partly cloudy - day
  clear_night         = [31,33]                    # clear - night
  sunny               = [32,34,36]                 # sunny

  (!lightning_thunder.include?(code) and
    !sleet_drizzle_rain.include?(code) and
    !snow.include?(code) and
    !hail.include?(code))
end

def weather_hashed(temp, code, text)
  nice_temp = temp_nice?(temp)
  nice_conditions = conditions_nice?(code)
  happy = (nice_temp and nice_conditions) ? 'Yes!' : 'No!'
  join = !nice_temp ? "but only" : "and"
  details = "&mdash; #{text} #{join} #{temp}&deg;C in Berlin right now!"
  { :happy => happy, :details => details }
end

def berlin_weather
  url = "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json"
  begin
    response = HTTParty.get url
    temp = response['query']['results']['channel']['item']['condition']['temp'].to_i
    code = response['query']['results']['channel']['item']['condition']['code'].to_i
    text = response['query']['results']['channel']['item']['condition']['text']
    weather = weather_hashed(temp, code, text)
  rescue
    return error_weather
  end
  weather
end

get '/' do
  @weather = berlin_weather
  haml :index
end
