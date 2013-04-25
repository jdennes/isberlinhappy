require 'httparty'
require 'redis'
require 'json'

# Loads weather data.
class WeatherLoader

  # Attempt to get weather data from Redis. If it's not found,
  # download it.
  def self.get_weather
    # Attempt to get current weather from Redis.
    uri = URI.parse(ENV['REDISTOGO_URL'])
    r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    redis_result = r.get("current_weather")

    # If weather isn't in Redis, download it.
    if redis_result.nil?
      current_weather = WeatherLoader.download_weather
    else
      current_weather = JSON.parse(redis_result)
    end
    current_weather
  end

  # Download weather data and store it in Redis.
  def self.download_weather
    # Download weather data using Yahoo! weather API
    response = HTTParty.get "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json"
    temp = response['query']['results']['channel']['item']['condition']['temp'].to_i
    code = response['query']['results']['channel']['item']['condition']['code'].to_i
    text = response['query']['results']['channel']['item']['condition']['text']

    # Store the weather data in Redis
    uri = URI.parse(ENV['REDISTOGO_URL'])
    r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    current_weather = {'temp' => temp, 'code' => code, 'text' => text}
    r.set "current_weather", current_weather.to_json

    p "Downloaded weather into Redis: Temp: #{temp}, Code: #{code}, Text: #{text}"
    current_weather
  end
end
