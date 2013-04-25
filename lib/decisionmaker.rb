require 'httparty'

# Makes decisions about weather conditions.
class DecisionMaker
  attr_reader :temp
  attr_reader :code
  attr_reader :text

  # Initialise using temp, code, and text
  def initialize(temp, code, text)
    @temp = temp
    @code = code
    @text = text
  end

  # Decide whether the temperature is nice.
  def temp_nice?
    @temp >= 15
  end

  # Decide whether the conditions represented by the condition code are nice.
  def conditions_nice?
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

    ( !lightning_thunder.include?(@code) and
      !sleet_drizzle_rain.include?(@code) and
      !snow.include?(@code) and
      !hail.include?(@code) )
  end

  # Get a hash of the current weather conditions.
  def weather_hashed
    # There's no temp or code set, so return 'error weather'
    if (@temp.nil? and @code.nil?)
      return {:happy => "??", :details => "&mdash; Sorry, something&rsquo;s broken!"}
    end

    happy = (temp_nice? and conditions_nice?) ? 'Yes!' : 'No!'
    join = !temp_nice? ? "but only" : "and"
    details = "&mdash; #{@text} #{join} #{@temp}&deg;C in Berlin right now!"
    { :happy => happy, :details => details }
  end

  # Gets a DecisionMaker object loaded with weather data, ready
  # to make decisions.
  def self.get_decision_maker
    url = "http://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%20638242%20and%20u%20%3D%20'c'&format=json"
    begin
      response = HTTParty.get url
      temp = response['query']['results']['channel']['item']['condition']['temp'].to_i
      code = response['query']['results']['channel']['item']['condition']['code'].to_i
      text = response['query']['results']['channel']['item']['condition']['text']
      dm = DecisionMaker.new temp, code, text
    rescue
      dm = DecisionMaker.new nil, nil, nil
    end
    dm
  end
end
