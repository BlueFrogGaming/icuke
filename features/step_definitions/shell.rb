require 'bundler'
require 'rake'
require 'sandbox'
require 'shellwords'

World(Rake::DSL)

Given /^I am in a sandbox directory$/ do
  @environment = Environment.new
  @environment.unbundlerize!
  @environment.env.merge! 'CURRENT_REPO' => Dir.getwd,
                          'CURRENT_REF' => `git log -1 --pretty=format:%h`
end

After do
  if @environment
    @environment.cleanup
    @environment = nil
  end
end

Given /^I run "([^"]*)"$/ do |command|
  @environment.enter do
    sh command
  end
end

Given /^I have a file named "([^"]*)" containing$/ do |filename, contents|
  @environment.enter do
    contents.gsub!(/\$[A-Za-z0-9_]+/) {|name| @environment.env[name[1..-1]] || ""}
    File.open(filename, 'w') {|f| f.write(contents)}
  end
end

Given /^I copy "([^"]*)" to "([^"]*)" recursively$/ do |src, dst|
  @environment.enter do
    sh "cp -r \"#{src}/\" \"#{dst}/\""
  end
end

Then /^everything should be hoopy$/ do
end

