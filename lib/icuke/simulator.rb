require 'icuke/core_ext'
require 'icuke/waxsim'

require 'httparty'

module ICuke
  class Simulator
    include Timeout
    include HTTParty
    
    class Error < StandardError; end

    def view
      get '/view'
    end
    
    def record
      get '/record'
    end
    
    def stop
      get '/stop'
    end
    
    def save(path)
      get '/save', :query => path
    end
    
    def load(path)
      get '/load', :query => path
    end
    
    def play
      get '/play'
    end
    
    def load_module(path)
      get '/module', :query => path
    end
    
    def fire_event(event)
      get '/event', :query => event.to_json
    end
    
    def set_defaults(defaults)
      get '/defaults', :query => defaults.to_json
    end

    MIN_ICUKE_PORT = 50000
    MAX_ICUKE_PORT = 50199

    def self.next_available_port
      @next_available_port ||= MIN_ICUKE_PORT - 1
      @next_available_port += 1
      @next_available_port = MIN_ICUKE_PORT if @next_available_port > MAX_ICUKE_PORT
      @next_available_port
    end

    def port
      @port ||= self.class.next_available_port
      @port
    end

    def new_port
      @port = nil
      port
    end

    def get(path, options = {})
      options[:base_uri] = "http://localhost:#{port}"
      options[:query] = URI.escape(options[:query]) if options.has_key?(:query)
      response = self.class.get(path, options)
      raise Simulator::Error, response.body unless response.code == 200
      response.body
    end
  end
end
