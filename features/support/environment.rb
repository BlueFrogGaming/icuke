
class Environment
  attr_reader :sandbox
  attr_accessor :env

  def initialize
    ENV['TMPDIR'] = '/tmp' # Work-around for bundler bug with '++' in path name.
    @sandbox = Sandbox.new
    @env = ENV.to_hash
  end

  def cleanup
    @sandbox.close
  end

  BUNDLER_ENVIRONMENT_VARIABLES = [ 'BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE', 'RUBYOPT', 'GEM_HOME', 'GEM_PATH' ]
  def unbundlerize!
    BUNDLER_ENVIRONMENT_VARIABLES.each {|v| env.delete(v)}
  end

  def with_env
    old_env = ENV.to_hash
    ENV.replace(@env)
    begin
      yield
    ensure
      ENV.replace(old_env)
    end
  end
  private :with_env

  def enter
    Dir.chdir(@sandbox.path) do
      with_env do
        yield
      end
    end
  end

end
