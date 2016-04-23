require 'logger'

module Kazus
  class Configuration
    attr_accessor :logger

    def initialize
      @logger = Logger.new(STDOUT)
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
