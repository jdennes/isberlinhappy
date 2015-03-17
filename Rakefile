begin
  require "rspec/core/rake_task"
  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  # Avoid errors when development and test dependencies aren't present
end

desc "Start app for development"
task :start do
  system "foreman start"
end

desc "Run job"
task :job do
  system "foreman run ruby job.rb"
end

task :default => :spec
