require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

desc "Start app for development"
task :start do
  system 'ruby -rubygems application.rb'
end

task :default => :spec

