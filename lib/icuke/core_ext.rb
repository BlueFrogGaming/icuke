require 'net/http'

module RequestWithSocketCheck
  def self.included(base)
    base.instance_eval do
      alias_method :request_without_socket_check, :request
      alias_method :request, :request_with_socket_check
    end
  end
  
  def request_with_socket_check(*args)
    begin
      request_without_socket_check(*args)
    rescue NoMethodError => e
      if e.message =~ /undefined method `closed\?' for nil/
        raise Errno::ECONNREFUSED
      else
        raise e
      end
    end
  end
end

if Net::HTTP::Revision.to_i == 25851
  Net::HTTP.send :include, RequestWithSocketCheck
end


class Hash

  # Merges self with another hash, recursively.
  # 
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  # 
  # Thanks to whoever made it.

  def deep_merge(hash)
    target = dup
    
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      
      target[key] = hash[key]
    end
    
    target
  end

end
