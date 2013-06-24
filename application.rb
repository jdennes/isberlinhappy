require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'sass'
require './lib/numeric'
require './lib/weatherloader'
require './lib/decisionmaker'

configure do
  require 'newrelic_rpm' if production?
  set :views, "#{File.dirname(__FILE__)}/views"
end

helpers do
  def versioned_stylesheet(style)
    "/#{style}.css?" + File.mtime(File.join(settings.public_folder, "scss", "#{style}.scss")).to_i.to_s
  end

  def partial(name, locals={})
    haml "_#{name}".to_sym, :layout => false, :locals => locals
  end
end

%w(reset screen).each do |style|
  get "/#{style}.css" do
    content_type :css, :charset => 'utf-8'
    path = "public/scss/#{style}.scss"
    last_modified File.mtime(path)
    scss File.read(path)
  end
end

get '/' do
  redis_uri = URI.parse(ENV['REDISTOGO_URL'])
  redis = Redis.new(
    :host => redis_uri.host,
    :port => redis_uri.port,
    :password => redis_uri.password
  )
  wl = WeatherLoader.new redis
  @dm = DecisionMaker.get_decision_maker wl
  @decision = @dm.weather_hashed

  if request.env['HTTP_ACCEPT'] == 'application/json'
    content_type 'application/json', :charset => 'utf-8'
    return [200, {
      :happy  => @decision[:happy],
      :text   => @decision[:text],
      :temp_c => @decision[:temp],
      :temp_f => @decision[:temp].celsius_to_fahrenheit
    }.to_json]
  else
    content_type :html, :charset => 'utf-8'
    return haml :index
  end
end
