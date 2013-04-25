require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

desc "Start app for development"
task :start do
  system 'foreman start'
end

desc "Run job"
task :job do
  system 'foreman run ruby job.rb'
end

task :default => :spec

