require 'spec_helper'

set :environment, :test

describe 'The isberlinhappy app' do
  def app
    Sinatra::Application
  end

  it "shows whether or not berlin is happy today" do
    get '/'
    expect(last_response).to be_ok
  end
end