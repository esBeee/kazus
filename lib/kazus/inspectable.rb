module Kazus
  # Class that represents a single object that should be inspected. Has two attributes:
  #
  # @object <-> The object to be inspected. Mandatory.
  # @id <-> An ID in the overall collection for this object. Can be anything that implements to_s.
  # @options <-> The options hash. See below for a list of implemented options.
  # @data <-> A hash used internal to store all debug information to be logged in the end.
  #
  # Available options:
  # :detailed <-> Boolean. If true, titles every key-value-pair of a hash with the key and adds a
  #               full inspection of the value.
  #
  # An instances #inspection method returns a human readable string that gives details about the object.
  class Inspectable
    def initialize object, id, options = {}
      @object = object
      @id = id
      @options = options
      @data = {}
    end

    # Returns a formatted string that gives a good insight on the object.
    # Takes a title as first argument optionally, currently used in case 
    # this object is a value to a key of a hash (then the key is the title).
    def inspection title=nil
      # If this object is a hash and options[:detailed] is true,
      # treat each value as another Inspectable and name the values
      # with the respective keys.
      if @options[:detailed] && @object.class == Hash
        return detailed_hash_values
      end

      # The following methods all store potentially given
      # information in @data.
      collect_title(title)
      collect_class
      collect_count
      collect_errors # Errors here refers to ActiveModel errors.
      collect_inspect
      collect_to_s
      collect_stack_trace

      # Return the full inspection.
      "       " + id_string(true) + print_data + id_string(false)
    end

    # A simple helper that stores a key-value-pair in the @data hash.
    def pick_up_data name, information
      @data[name] = information
    end

    # Prints all key-value-pairs contained in @data into a well readable string.
    def print_data
      printout = ""
      @data.each { |name, value| printout += name + ": " + value + " | " }

      # Remove superflous last 3 chars.
      printout.gsub(/ \| $/, "")
    end

    # Treats every value as an Inspectable and titles it with its key.
    # Returns the collective inspection-string of all contained key-value-pairs.
    def detailed_hash_values
      inspection = ""

      index = 0
      @object.each do |key, value|
        inspection += self.class.new(value, "#{@id}.#{index}").inspection(key)
        index += 1
      end

      inspection
    end

    # Hands out the given @id for the left or the right
    # end of the inspection string, respectively.
    def id_string right
      id = @id.to_s
      right ? id + "| " : " |" + id
    end

    # Collect the given title.
    def collect_title title
      if title
        pick_up_data("TITLE", title.to_s)
      end
    end

    # Collect the object's class name.
    def collect_class
      pick_up_data("CLASS", @object.class.to_s)
    end

    # Collect the object's response to #count, if given.
    def collect_count
      # Rescue in case this object doesn't implement a :count method
      begin
        count = @object.count
        pick_up_data("COUNT", @object.count.to_s)
      rescue
        # Don't really care if @object doesn't implement :count
      end
    end

    # COLLECT methods - Each tries to get an information from @object
    # and - if available - stores it in the @data hash.
    #
    # If this is an ActiveRecord instance, it might have errors that
    # should be printed.
    def collect_errors
      # Rescue in case this object doesn't implement the required methods.
      begin
        error_messages = @object.errors.full_messages
        pick_up_data("ERRORS", error_messages.join(", "))
      rescue
        # Don't really care.
      end
    end

    # Collect the object's response to #to_s.
    def collect_to_s
      s = @object.to_s

      # Don't collect if string is blank or it's the same as #inspect
      # delivered.
      unless s.length == 0 || @data["INSPECT"] == s
        pick_up_data("TO_S", @object.to_s)
      end
    end

    # Collect the object's response to #inspect.
    def collect_inspect
      s = @object.inspect

      # Don't collect if string is blank or it's the same as #to_s
      # delivered.
      unless s.length == 0 || @data["TO_S"] == s
        pick_up_data("INSPECT", @object.inspect)
      end
    end

    # If this object has a backtrace, collect it.
    def collect_stack_trace
      # Rescue in case this object doesn't implement the required methods.
      begin
        backtrace = @object.backtrace
        pick_up_data("BACKTRACE", backtrace.join(" ### "))
      rescue
        # Don't really care.
      end
    end
  end
end
