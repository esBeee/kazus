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
      Kazus.configuration ||= Configuration.new

      # Check if function was called without arguments and return in that case.
      if args.length == 0
        error_message = %q{You are calling #Kazus.log without arguments.}
        return log(:warn, error_message)
      end

      # Let #map_args decide what the log level will be, what incident description
      # will be logged, and what objects will be inspected.
      log_level, incident_description, objects_to_inspect = map_args(args)

      incident = Incident.new(
        log_level: log_level,
        description: incident_description,
        objects_to_inspect: objects_to_inspect
      )
      incident.log
    end


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
      if args.length == 1 || (log_level=Incident.standardize_log_level(args[0])).nil?
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
  end
end
