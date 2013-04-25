require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'sass'
require './lib/weatherloader'
require './lib/decisionmaker'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

configure :production do
  require 'newrelic_rpm'
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

get '/' do
  @dm = DecisionMaker.get_decision_maker
  @decision = @dm.weather_hashed
  haml :index
end
