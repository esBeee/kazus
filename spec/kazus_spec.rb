require 'spec_helper'

describe Kazus do
  describe "#log" do
    describe "when user didn't configure a logger" do
      it "logs without throwing an exception" do
        expect(Kazus.log()).to eq(true)
      end
    end

    describe "when user configured a logger" do
      let(:logger) { double("logger") }

      before do
        Kazus.configure do |config|
          config.logger = logger
        end
      end

      it 'has a version number' do
        expect(Kazus::VERSION).not_to be nil
      end

      it 'has a list of all available log levels' do
        expect(Kazus::LOG_LEVELS).to eq [:debug, :info, :warn, :error, :fatal, :unknown]
      end

      it "logs as :warn if called without arguments" do
        expected_message = "[KAZUS|warn] You are calling #Kazus.log without arguments."
        expect(logger).to receive(:warn).with(expected_message)
        Kazus.log()
      end

      it "logs all n - 2 objects given as arguments 3 to n" do
        array_of_integers = (7..999).to_a
        expected_message = "[KAZUS|debug] RELATED OBJECTS:"
        array_of_integers.each { |n| expected_message += "       #{n - 7}| CLASS: Fixnum | INSPECT: #{n} |#{n - 7}" }
        expect(logger).to receive(:debug).with(expected_message)
        Kazus.log(*array_of_integers)
      end

      context "when first argument is not a valid log level" do
        it "logs an inspection of all given objects if it is not a string" do
          expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: Fixnum | INSPECT: -1 |0       1| CLASS: " +
            "String | INSPECT: \"Something\" | TO_S: Something |1       2| CLASS: Array | COUNT: 0 | INSPECT: [] |2"
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log(-1, "Something", [])
        end

        it "uses the argument as description if it is a string" do
          expected_message = "[KAZUS|debug] Something happened"
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log("Something happened")
        end
      end

      context "when first argument is a valid log level" do
        it "logs an inspection of the first argument if called with only one argument" do
          expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: Symbol | INSPECT: :unknown | TO_S: unknown |0"
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log(:unknown)
        end

        it "uses it as description if there's only one argument" do
          expected_message = "[KAZUS|debug] unknown"
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log("unknown")
        end

        it "uses it as log level if there's more than one argument" do
          expected_message = "[KAZUS|unknown] RELATED OBJECTS:       0| CLASS: Fixnum | INSPECT: 1 |0"
          expect(logger).to receive(:unknown).with(expected_message)
          Kazus.log("unknown", 1)
        end

        context "when second argument is a string" do
          it "logs with given log level and given description if there are two arguments" do
            expected_message = "[KAZUS|warn] This and that went wrong"
            expect(logger).to receive(:warn).with(expected_message)
            Kazus.log(:warn, "This and that went wrong")
          end

          it "logs with given log level and given description and given object if called with 3 arguments" do
            expected_message = "[KAZUS|info] This and that went wrong -- RELATED OBJECTS:       0| CLASS: Fixnum | INSPECT: 1 |0"
            expect(logger).to receive(:info).with(expected_message)
            Kazus.log(:info, "This and that went wrong", 1)
          end
        end

        context "when second argument is not a string" do
          it "logs with given log level and 2 objects if called with 3 arguments" do
            expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: NilClass | INSPECT: nil |0       " +
              "1| CLASS: Fixnum | INSPECT: 1 |1"
            expect(logger).to receive(:debug).with(expected_message)
            Kazus.log(:debug, nil, 1)
          end
        end

        %w(error warn info debug unknown fatal).each do |valid_log_level|
          it "'#{valid_log_level}' as string" do
            expected_message = "[KAZUS|#{valid_log_level}] This and that went wrong"
            expect(logger).to receive(valid_log_level.to_sym).with(expected_message)
            Kazus.log(valid_log_level, "This and that went wrong")
          end

          it "':#{valid_log_level}'" do
            expected_message = "[KAZUS|#{valid_log_level}] This and that went wrong"
            expect(logger).to receive(valid_log_level.to_sym).with(expected_message)
            Kazus.log(valid_log_level.to_sym, "This and that went wrong")
          end
        end

        (0..5).each do |valid_log_level|
          it "'#{valid_log_level}' as integer" do
            symbol_representation = Kazus::LOG_LEVELS[valid_log_level]
            expected_message = "[KAZUS|#{symbol_representation}] This and that went wrong"
            expect(logger).to receive(symbol_representation).with(expected_message)
            Kazus.log(valid_log_level, "This and that went wrong")
          end
        end
      end

      describe "special data types" do
        it "logs Exceptions as expected" do
          expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: Exception | INSPECT: #<Exception: Thi" +
            "sException> | TO_S: ThisException | BACKTRACE: A ### B |0"
          expect(logger).to receive(:debug).with(expected_message)

          exception = Exception.new("ThisException")
          exception.set_backtrace(["A", "B"])
          Kazus.log(exception)
        end

        it "logs a Hash detailed as last argument" do
          expected_message = "[KAZUS|debug] Something went wrong -- RELATED OBJECTS:       0| CLASS: Fixnum | INSPECT: 1 |0" +
            "       1.0| TITLE: Value 1 | CLASS: Fixnum | INSPECT: 1 |1.0       1.1| TITLE: Value 2 | CLASS: Hash | COUNT: 2 " +
            "| INSPECT: {:a=>[], :b=>2} |1.1"
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log(:debug, "Something went wrong", 1, "Value 1" => 1, "Value 2" => {a: [], b: 2})
        end

        it "logs a Hash not detailed as forelast argument" do
          expected_message = '[KAZUS|debug] RELATED OBJECTS:       0| CLASS: Hash | COUNT: 2 | INSPECT: {"Value 1"=>1, ' +
            '"Value 2"=>{:a=>[], :b=>2}} |0       1| CLASS: Fixnum | INSPECT: 1 |1'
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log({"Value 1" => 1, "Value 2" => {a: [], b: 2}}, 1)
        end

        it "logs a NilClass element" do
          expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: NilClass | INSPECT: nil |0"
          expect(logger).to receive(:debug).with(expected_message)
          Kazus.log(nil)
        end

        describe "called with an object, that responds to the method call '.errors.full_messages' (like an ActiveModel instance does)" do
          it "logs error messages if there are any" do
            # Create a double that accepts the method call '.errors.full_messages' and
            # let return an array of strings.
            errors_double = double("errors")
            ar_object = double("ar_object", errors: errors_double, count: nil, backtrace: nil)
            allow(errors_double).to receive(:full_messages) { ["This is why it's invalid", "And this is another reason"] }

            expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: RSpec::Mocks::Double | COUNT:  | ERRORS: " +
              "This is why it's invalid, And this is another reason | INSPECT: #<Double \"ar_object\"> | TO_S: #[Double \"ar_object\"] |0"
            expect(logger).to receive(:debug).with(expected_message)
            Kazus.log(ar_object)
          end

          it "logs the information that no  errors exist if '.errors.full_messages' returns an empty array" do
            # Create a double that accepts the method call '.errors.full_messages' and
            # let return an array of strings.
            errors_double = double("errors")
            ar_object = double("ar_object", errors: errors_double, count: nil, backtrace: nil)
            allow(errors_double).to receive(:full_messages) { [] }

            expected_message = "[KAZUS|debug] RELATED OBJECTS:       0| CLASS: RSpec::Mocks::Double | COUNT:  | " +
              "ERRORS: [] | INSPECT: #<Double \"ar_object\"> | TO_S: #[Double \"ar_object\"] |0"
            expect(logger).to receive(:debug).with(expected_message)
            Kazus.log(ar_object)
          end
        end
      end
    end
  end
end
