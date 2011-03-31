require 'nokogiri'

require 'icuke/sdk'
require 'icuke/simulator_driver'

module ICukeWorld
  def icuke_driver
    @icuke_driver ||= ICuke::SimulatorDriver.default_driver(icuke_configuration)
  end
  
  def icuke_configuration
    @icuke_configuration ||= ICuke::Configuration.new({
      :build_configuration => 'Debug'
    })
  end
end

After do
  icuke_driver.quit
end

##
# :section: Loading the iOS Application
#
# Launching the application is the most difficult part.  Many parts can be
# omitted, but the full form looks like this:
#
#   Given "iCuke" from "app/iCuke/iCuke.xcodeproj" with build configuration "Debug" is loaded in the retina iphone simulator with SDK 4.0
#
# In this case:
# * "iCuke" is the name of the app to load.
# * "app/iCuke/iCuke.xcodeproj" is the path to the Xcode project.
# * "Debug" specifies the build configuration.  "Debug" is used if not
#   specified.
# * "retina" or "non-retina" can optionally be specified.  If specified, the
#   simulator is configured for retina or non-retina version of the device
#   before launching the application.  If not specified, the simulator
#   chooses, which means that it will run with the last selected resolution.
# * "iphone" or "ipad" selects the device type.  "iphone" is the default.
# * The optional clause "with SDK 4.0" selects how iCuke interacts with
#   application.  If not specified, iCuke attempts to guess based on which SDKs
#   are installed; however, it can guess wrong.  Possible values are "3.1" and
#   "4.0".  "4.0" should be used on 4.2 and newer SDKs
#
Given /^(?:"([^\"]*)" from )?"([^\"]*)"(?: with build configuration "([^\"]*)")? is loaded in the (?:(retina|non-retina) )?(?:(iphone|ipad) )?simulator(?: with SDK ([0-9.]+))?$/ do |target, project, configuration, retina, platform, sdk_version|
  if sdk_version
    ICuke::SDK.use(sdk_version)
  elsif platform
    ICuke::SDK.use_latest(platform.downcase.to_sym)
  else
    ICuke::SDK.use_latest
  end
  attrs = { :target => target,
            :platform => platform,
            :env => {
              'DYLD_INSERT_LIBRARIES' => ICuke::SDK.dylib_fullpath
            }
          }
  attrs.merge!(:retina => !(retina =~ /non/)) if retina
  attrs.merge!(:build_configuration => configuration) if configuration
  icuke_driver.launch(File.expand_path(project), attrs)
end

Given /^the module "([^\"]*)" is loaded in the simulator$/ do |path|
  path.sub!(/#{File.basename(path)}$/, ICuke::SDK.dylib(File.basename(path)))
  simulator.load_module(File.expand_path(path))
end

##
# :section: Seeing What's on the Screen
#
# The two following rules detect accessibility text on the screen:
#
#   Then I should see "some text" within "some scope"
#   Then I should not see "some text" within "some scope"
#
Then /^I should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" not found in: #{screen.xml}} unless icuke_driver.screen.visible?(text, scope)
end

Then /^I should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" was found but was not expected in: #{screen.xml}} if icuke_driver.screen.visible?(text, scope)
end

##
# :section: Sending Input to the App
#
# The following rules are available:
#
#   When I tap "some label"
#   When I type "some text" in "some field label"
#   When I drag from <source> to <destination>
#   When I select the "some label" slider and drag <distance> pixels <direction>
#   When I move the "label" slider to <n> percent
#   When I scroll <direction> to "some text"
#   When I suspend the application
#   When I resume the application
#
When /^I tap "([^\"]*)"$/ do |label|
  icuke_driver.tap(label)
end

When /^I type "([^\"]*)" in "([^\"]*)"$/ do |text, textfield|
  icuke_driver.type(textfield, text)
end

When /^I drag from (.*) to (.*)$/ do |source, destination|
  icuke_driver.drag_with_source(source, destination)
end

When /^I select the "(.*)" slider and drag (.*) pixels (down|up|left|right)$/ do |label, distance, direction|
  icuke_driver.drag_slider_to(label, direction.to_sym, distance.to_i)
end

When /^I move the "([^\"]*)" slider to (.*) percent$/ do |label, percent|
  icuke_driver.drag_slider_to_percentage(label, percent.to_i)
end

When /^I scroll (down|up|left|right)(?: to "([^\"]*)")?$/ do |direction, text|
  if text
    icuke_driver.scroll_to(text, :direction => direction.to_sym)
  else
    icuke_driver.scroll(direction.to_sym)
  end
end

When /^I suspend the application/ do
  icuke_driver.suspend
end

When /^I resume the application/ do
  icuke_driver.resume
end

##
# :section: Debugging Tools
#
#   Then I put the phone into recording mode
#
#   Then show me the screen
#
# "show me the screen" is the quintessential step used for debugging tests.  It dumps
# the raw XML received from the iOS app.
#
Then /^I put the phone into recording mode$/ do
  icuke_driver.record
end

Then /^show me the screen$/ do
  puts icuke_driver.screen.xml.to_s
end
