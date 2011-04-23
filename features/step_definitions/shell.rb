require 'bundler'
require 'rake'
require 'sandbox'
require 'shellwords'

Given /^I have built the gem$/ do
  sh 'rake build'
end

Given /^I am in a sandbox directory$/ do
  ENV['TMPDIR'] = '/tmp' # Work-around for bundler bug with '++' in path name.
  @sandbox = Sandbox.new
end

After do
  if @sandbox
    @sandbox.close
    @sandbox = nil
  end
end

BUNDLER_ENVIRONMENT = [ 'BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE', 'RUBYOPT', 'GEM_HOME', 'GEM_PATH' ]
def with_environment_vars_unset(vars)
  old_values = {}
  vars.each do |v|
    old_values[v] = ENV[v]
    ENV.delete(v)
  end
  begin
    yield
  ensure
    old_values.each do |k,v|
      ENV[k]=v
    end
  end
end

def with_environment_vars(vars)
  old_values = {}
  vars.each do |k,v|
    old_values[k] = ENV[k]
    ENV[k]=v
  end
  begin
    yield
  ensure
    old_values.each do |k,v|
      ENV[k]=v
    end
  end
end

def local_env
  { 'CURRENT_REPO' => Dir.getwd,
    'CURRENT_REF' => `git log -1 --pretty=format:%h` }
end

Given /^I run "([^"]*)"$/ do |command|
  le = local_env
  Dir.chdir(@sandbox.path) do
    with_environment_vars_unset(BUNDLER_ENVIRONMENT) do
      with_environment_vars(le) do
        sh command
      end
    end
  end
end

Given /^I have a file named "([^"]*)" containing$/ do |filename, contents|
  le = local_env
  Dir.chdir(@sandbox.path) do
    contents.gsub!(/\$[A-Za-z0-9_]+/) {|name| le[name[1..-1]] || ""}
    File.open(filename, 'w') {|f| f.write(contents)}
  end
end

Then /^there should be no error$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I copy "([^"]*)" to "([^"]*)" recursively$/ do |src, dst|
  le = local_env
  Dir.chdir(@sandbox.path) do
    with_environment_vars_unset(BUNDLER_ENVIRONMENT) do
      with_environment_vars(le) do
        sh "cp -r \"#{src}/\" \"#{dst}/\""
      end
    end
  end
end

Then /^everything should be hoopy$/ do
end

