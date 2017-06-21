require "kazus/constants"
require "kazus/configuration"
require "kazus/incident"

module Kazus
  class << self
    # Logs a nicely formatted message with the configured logger or the default
    # logger, respectively.
    def log *args
      # Make sure a logger is available if gem wasn't configured until now.
      # The Configuration class defaults to the ruby Logger (STDOUT). Learn more
      # in kazus/configuration.rb.
      ensure_presence_of_configuration

      # Check if function was called without arguments and return in that case.
      if args.length == 0
        error_message = %q{You are calling #Kazus.log without arguments.}
        return log(:warn, error_message)
      end

      # Let #map_args decide what the log level will be, what incident description
      # will be logged, and what objects will be inspected.
      log_level, incident_description, objects_to_inspect = map_args(args)

      puts_only = __callee__ == :s

      # Return if the current logger has set a log level and the current
      # incident's log level is beyond the logger's log level.
      return if !puts_only && severity_beyond_log_level(log_level)

      incident = Incident.new(
        log_level: log_level,
        description: incident_description,
        objects_to_inspect: objects_to_inspect
      )

      if puts_only
        puts incident.inspection
      else
        incident.log
      end
    end

    alias_method :s, :log


    private

    # Takes an array and decides based on it, what will be the log level,
    # the incident description and the objects to be inspected.
    # Returns an array with those 3 parts:
    # => [log_level, incident_description, objects_to_inspect]
    def map_args args
      # Set log level, incident description, and objects to be inspected.
      #
      # Note: if standardize_log_level(args[0]) is nil, the first argument isn't a valid log level.
      #
      # Note also, that within this line the log level gets set (for use in
      # the else-block).
      if args.length == 1 || (log_level=standardize_log_level(args[0])).nil?
        # Log as :debug
        log_level = :debug

        # If the first argument is a string, use it as description.
        if args[0].class == String
          incident_description = args[0]

          # Inspect all further objects.
          objects_to_inspect = args[1..args.length] || []
        else
          # No incident description in this case
          incident_description = nil

          # Assume all objects are to be inspected.
          objects_to_inspect = args
        end
      else
        # The first argument is a valid log level. Let's check if the second argument
        # is a string. It will then be interpreted as the incident description, potentially followed
        # by objects to be inspected.
        # If it's something else, interpret this and all following arguments as objects
        # to be inspected.
        if args[1].class.to_s == "String"
          incident_description = args[1]
          objects_to_inspect = args[2..args.length] || []
        else
          incident_description = nil
          objects_to_inspect = args[1..args.length] || []
        end
      end

      [log_level, incident_description, objects_to_inspect]
    end

    # Takes the log level as integer (0, 1, ... , 5) or as string/symbol
    # (:debug, :info, :warn, :error, :fatal, :unknown) and returns the log level
    # as symbol.
    #
    # Returns nil if given log_level is not valid.
    def standardize_log_level log_level
      if log_level.is_a?(Integer)
        return nil if log_level < 0 # Prevent the next line from handing out anything in this case
        LOG_LEVELS[log_level] # Returns nil if log_level > 5
      else
        requested_log_level_symbol = log_level.class == String ? log_level.downcase.to_sym : log_level
        LOG_LEVELS.include?(requested_log_level_symbol) ? requested_log_level_symbol : nil
      end
    end

    # Returns true if the current logger has set a log level and the given
    # log level is beyond the logger's log level.
    def severity_beyond_log_level log_level
      loggers_log_level = standardize_log_level(Kazus.configuration.logger.level)
      if loggers_log_level && LOG_LEVELS.index(log_level) < LOG_LEVELS.index(loggers_log_level)
        return true
      end
    rescue Exception => e
      # Just ignore if this logger hasn't defined a log level.
    end
  end
end
