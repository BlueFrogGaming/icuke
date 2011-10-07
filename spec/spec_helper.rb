require 'rubygems'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'icuke'
$:.unshift(File.dirname(__FILE__))

begin
  require 'rspec'
  require 'rspec/autorun'
  RSpec.configure do |c|
    c.color_enabled = true
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
rescue LoadError
  require 'spec'
  require 'spec/autorun'
  Spec::Runner.configure do |c|
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
end

require 'cucumber'

RSpec::Matchers.define :include_touch do |type, x, y|
  match do |what|
    events = JSON.parse(what.to_json)
    events = [events] unless events.kind_of?(Array)
    events.detect do |e|
      e["Data"]["Type"].to_i == type.to_i &&
        e["Data"]["Paths"].first["Location"]["X"] == x &&
        e["Data"]["Paths"].first["Location"]["Y"] == y
    end
  end
end

def calculate_move(x1, y1, x2, y2, step_num)
  dx = x2 - x1
  dy = y2 - y1
  hypotenuse = Math.sqrt(dx*dx + dy*dy)
  step = 25 / hypotenuse
  return 40 + step_num * step * dx, 60 + step_num * step * dy
end

def timestamps(json)
  segments = json.split('"Time":')
  segments.delete_at 0
  timestamps = []
  segments.each do |segment|
    timestamps << segment.split(',')[0].to_i
  end
  timestamps
end


def World
end
def After
end
def Given(something)
end
def When(something)
end
def Then(something)
end
