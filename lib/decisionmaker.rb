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

  # Weather codes mapped from: http://developer.yahoo.com/weather/#codes
  def weather_codes
    {
      :lightning_thunder   => [0,1,2,3,4,37,38,39,45,47], # lightning/thunder
      :sleet_drizzle_rain  => [5,6,7,8,9,10,11,12,18,40], # sleet/drizzle/rain
      :snow                => [13,14,15,16,41,42,43,46],  # snow
      :hail                => [17,35],                    # hail
      :haze_dust           => [19..22],                   # haze/dust
      :windy               => [23,24],                    # windy
      :cloudy              => [25,26,44],                 # cloudy
      :partly_cloudy_night => [27,29],                    # partly cloudy - night
      :partly_cloudy_day   => [28,30],                    # partly cloudy - day
      :clear_night         => [31,33],                    # clear - night
      :sunny               => [32,34,36]                  # sunny
    }
  end

  # Decide whether the conditions represented by the condition code are nice.
  def conditions_nice?
    ( !weather_codes[:lightning_thunder].include?(@code) and
      !weather_codes[:sleet_drizzle_rain].include?(@code) and
      !weather_codes[:snow].include?(@code) and
      !weather_codes[:hail].include?(@code) )
  end

  def weather_icon
    return '&#xe01a;' if weather_codes[:lightning_thunder].include?(@code)
    return '&#xe011;' if weather_codes[:sleet_drizzle_rain].include?(@code)
    return '&#xe016;' if weather_codes[:snow].include?(@code)
    return '&#xe017;' if weather_codes[:hail].include?(@code)
    return '&#xe009;' if weather_codes[:haze_dust].include?(@code)
    return '&#xe005;' if weather_codes[:windy].include?(@code)
    return '&#xe018;' if weather_codes[:cloudy].include?(@code)
    return '&#xe008;' if weather_codes[:partly_cloudy_night].include?(@code)
    return '&#xe007;' if weather_codes[:partly_cloudy_day].include?(@code)
    return '&#xe002;' if weather_codes[:clear_night].include?(@code)
    return '&#xe000;' if weather_codes[:sunny].include?(@code)
    raise "Can't get weather icon when this DecisionMaker has no weather data to use."
  end

  # Get a hash of the current weather conditions.
  def weather_hashed
    # There's no temp or code set, so return 'error weather'
    if (@temp.nil? and @code.nil?)
      return {:happy => "??", :details => "&mdash; Sorry, something&rsquo;s broken!"}
    end

    happy = (temp_nice? and conditions_nice?) ? 'Yes!' : 'No!'
    if (conditions_nice? and !temp_nice?)
      join = "but only"
    elsif (!conditions_nice? and !temp_nice?)
      join = "and only"
    else
      join = "and"
    end
    details = "&mdash; #{@text} #{join} #{@temp}&deg;C in Berlin right now! &nbsp;<span class='icon'>#{weather_icon}</span>"
    { :happy => happy, :details => details }
  end

  # Gets a DecisionMaker object loaded with weather data, ready
  # to make decisions.
  def self.get_decision_maker(weather_loader)
    begin
      data = weather_loader.get_weather
      dm = DecisionMaker.new(data['temp'], data['code'], data['text'])
    rescue Exception => e
      p "Error: #{e}"
      dm = DecisionMaker.new nil, nil, nil
    end
    dm
  end
end
