require "kazus/inspectable"

module Kazus
  # Class that represents an incident to be logged. Its attributes are
  #
  # @log_level <-> Must be one of :debug, :info, :warn, :error, :fatal, :unknown. (To be exact: it
  #                has to be included in the list of log levels accesible as Kazus::LOG_LEVELS)
  # @description <-> A string describing the incident or nil, if no description exists.
  # @objects_to_inspect <-> Must be an array of any length that holds objects that will be inspected and logged.
  #
  # You might call it like this:
  # Incident.new(log_level: 1, description: "Some error occured", objects_to_inspect: [])
  class Incident
    def initialize hsh = {}
      @log_level = hsh[:log_level]
      @description = hsh[:description]
      @objects_to_inspect = hsh[:objects_to_inspect]
    end

    # Comissions the inspections of all given information and merges them
    # into one string to be logged.
    def log
      inspection = "[KAZUS|#{@log_level}]"
      inspection += " " + @description if @description
      inspection += objects_to_inspect_inspection # Can be a blank string if no objects are given.

      # Log the message with the given logger.
      begin
        Kazus.configuration.logger.send(@log_level, inspection)
      rescue
        # TODO: Whatever can be done in this case
      end
    end


    private

    # Returns the inspection of the various objects to be logged.
    def objects_to_inspect_inspection
      return "" if @objects_to_inspect.empty?

      inspection = " "
      inspection += "-- " if @description
      inspection += "RELATED OBJECTS:"

      # Create an inspection for each given object and add it to the collective inspection.
      @objects_to_inspect.each_with_index do |object, index|
        # If it's the last argument, set detailed true. In case it's a hash,
        # it'll get a special treatment.
        detailed = (@objects_to_inspect.length - 1 == index)

        # Add individual inspection to collectice inspection.
        inspection += Inspectable.new(object, index, detailed: detailed).inspection
      end

      # Return the collective inspection.
      inspection
    end

    class << self
      # Takes the log level as integer (0, 1, ... , 5) or as string/symbol
      # (:debug, :info, :warn, :error, :fatal, :unknown) and returns the log level
      # as symbol.
      #
      # Returns nil if given log_level is not valid.
      def standardize_log_level log_level
        if log_level.class == Fixnum
          return nil if log_level < 0 # Prevent the next line from handing out anything in this case
          LOG_LEVELS[log_level] # Returns nil if log_level > 5
        else
          requested_log_level_symbol = log_level.class == String ? log_level.to_sym : log_level
          LOG_LEVELS.include?(requested_log_level_symbol) ? requested_log_level_symbol : nil
        end
      end
    end
  end
end
