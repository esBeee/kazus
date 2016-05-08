# Require the default ruby logger 'Logger' in case the user didn't configure
# a logger.
require "logger"

module Kazus
  # This class holds the configuration for the kazus gem.
  # At the moment only the logger is configurable.
  class Configuration
    attr_accessor :logger

    def initialize
      @logger = Logger.new(STDOUT)
    end
  end

  class << self
    attr_accessor :configuration

    # This method can be called by the user with a block
    # so he can configure the gem.
    def configure
      ensure_presence_of_configuration
      yield(configuration)
    end

    # If gem wasn't configured yet (i.e. Kazus.configuration is nil),
    # initialize it with a new Configuration instance.
    def ensure_presence_of_configuration
      self.configuration ||= Configuration.new
    end
  end
end
