require 'spec/spec_helper'
require 'icuke/waxsim'

describe ICuke::Simulator::Process do

  it "should provide a list of commands necessary to set up the environment" do
    p = ICuke::Simulator::Process.new('foo', {})
    p.should respond_to(:setup_commands)
    p.setup_commands.should be_kind_of(Array)
  end
  
  it "should not provide a defaults command when retina is not specified" do
    found = ICuke::Simulator::Process.new('foo', {}).setup_commands.detect {|c| c =~ /^defaults/}
    found.should be_nil
  end

  it "should set SimulateDevice to \"iPhone (Retina)\" if platform is iPhone and retina is required" do
    attrs = {:platform => :iphone, :retina => true}
    found = ICuke::Simulator::Process.new('foo', attrs).setup_commands.detect {|c| c =~ /^defaults/}
    found.should_not be_nil
    found.should == "defaults write com.apple.iphonesimulator SimulateDevice '\"iPhone (Retina)\"'"
  end

  it "should set SimulateDevice to \"iPhone\" if platform is iPhone and retina is rejected" do
    attrs = {:platform => :iphone, :retina => false}
    found = ICuke::Simulator::Process.new('foo', attrs).setup_commands.detect {|c| c =~ /^defaults/}
    found.should_not be_nil
    found.should == "defaults write com.apple.iphonesimulator SimulateDevice '\"iPhone\"'"
  end

  it "should set SimulateDevice to \"iPad\" if platform is iPad and retina is rejected" do
    attrs = {:platform => :ipad, :retina => false}
    found = ICuke::Simulator::Process.new('foo', attrs).setup_commands.detect {|c| c =~ /^defaults/}
    found.should_not be_nil
    found.should == "defaults write com.apple.iphonesimulator SimulateDevice '\"iPad\"'"
  end

  describe '#with_launch_options' do

    it "should return a new Process" do
      p = ICuke::Simulator::Process.new("foo.xcodeproj").with_launch_options({})
      p.should be_kind_of(ICuke::Simulator::Process)
    end

    it "should not mutate the original Process" do
      p1 = ICuke::Simulator::Process.new("foo.xcodeproj")
      p2 = p1.with_launch_options(:env => {'FOO' => 'F'})
      p1.launch_options.should_not == p2.launch_options
    end

    it "should replace existing simple values" do
      p = ICuke::Simulator::Process.new("foo.xcodeproj", :platform => :ipad).with_launch_options(:platform => :iphone)
      p.launch_options[:platform].should == :iphone
    end

    it "should not remove existing variables" do
      p = ICuke::Simulator::Process.new("foo.xcodeproj", :env => {'FOO' => 'F'}).with_launch_options(:env => {})
      p.launch_options[:env].should have_key('FOO')
      p.launch_options[:env]['FOO'].should == 'F'
    end
    
    it "should add environment variables" do
      p = ICuke::Simulator::Process.new("foo.xcodeproj", :env => {'FOO' => 'F'}).with_launch_options(:env => {'BAR' => 'B'})
      p.launch_options[:env].should have_key('BAR')
      p.launch_options[:env]['BAR'].should == 'B'
    end

    it "should replace existing environment variables" do
      p = ICuke::Simulator::Process.new("foo.xcodeproj", :env => {'FOO' => 'F'}).with_launch_options(:env => {'FOO' => 'B'})
      p.launch_options[:env].should have_key('FOO')
      p.launch_options[:env]['FOO'].should == 'B'
    end

  end

end
