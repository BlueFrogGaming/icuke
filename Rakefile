require 'rubygems'
require 'bundler'
begin
  Bundler.setup
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require './lib/icuke/sdk'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "iCuke"
    gem.summary = %Q{Cucumber support for iOS applications}
    gem.description = %Q{Cucumber support for iOS applications}
    gem.email = "jason.felice@bluefroggaming.com"
    gem.homepage = "http://github.com/BlueFrogGaming/iCuke"
    gem.authors = ["Jason Felice"]
    gem.add_dependency "cucumber", ">= 0"
    gem.add_dependency "httparty", ">= 0"
    gem.add_dependency "nokogiri", ">= 0"
    gem.add_dependency "rake", ">= 0"
    gem.add_dependency "background_process"
    gem.extensions = ['ext/Rakefile']
    gem.files.include "ext/WaxSim/**/*"
    gem.files.exclude "ext/WaxSim/build/**/*"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

file 'app/build/Debug-iphonesimulator/Universal.app/Universal' do
  require 'lib/icuke/sdk'
  ICuke::SDK.use_latest
  sh "cd app && xcodebuild -target Universal -configuration Debug -sdk #{ICuke::SDK.fullname}"
end
task :app => 'app/build/Debug-iphonesimulator/Universal.app/Universal'

task :lib do
  sh 'cd ext && rake'
end

task :clean do
  sh 'cd ext && rake clean'
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => [:lib, :app]
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

begin
  require 'rspec/core/rake_task'

  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc "Run all examples (not available)"
  task :spec do
    abort "Rspec is not available. In order to run specs, you must: sudo gem install rspec"
  end
end

task :default => [:spec, :features]
