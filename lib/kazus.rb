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

      # If Incident.standardize_log_level is nil, the first argument isn't a valid log level. Assume that
      # EVERY given argument is an object to be inspected in this case.
      # Also, if there is only one argument, treat it as an object to be inspected.
      if args.length == 1 || (log_level=Incident.standardize_log_level(args[0])).nil?
        # Log as :debug
        log_level = :debug

        # Assume all objects are to be inspected.
        objects_to_inspect = args

        # Inform about log_level was chosen by kazus in the description. Since the user
        # didn't deliver a description this seems like an appropriate place.
        incident_description = nil
      else
        # The first argument was a valid log level. Let's check if the second argument
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

      incident = Incident.new(
        log_level: log_level,
        description: incident_description,
        objects_to_inspect: objects_to_inspect
      )
      incident.log
    end
  end
end
