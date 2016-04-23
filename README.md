# kazus gem

Kazus provides a simple logging helper. It accepts any amount or type of arguments and logs everything well readable, while including eventually given information like backtraces, validation errors of ActiveModel instances (the gem doesn't depend on rails, though) or the object's length (of an array or a hash). It is designed to not throw errors whatever the arguments are.

For example, lines like

```ruby
Rails.logger.error "@statement has unexpected validation errors: #{@statement.errors.full_messages.inspect}"
```

can be replaced by

```ruby
Kazus.log :error, "Unexpected validation errors", "@statement" => @statement, "Another value" => 5
```

which logs

```
[KAZUS|error] Unexpected validation errors -- RELATED OBJECTS:       0.0| TITLE: @statement | CLASS: Statement | ERRORS: User must exist, body can't be blank | INSPECT: #<Statement id: nil, user_id: nil, body: nil, created_at: nil, updated_at: nil> | TO_S: #<Statement:0x007f9a971683c8> |0.0       0.1| TITLE: Another value | CLASS: Fixnum | INSPECT: 5 |0.1
```

or simply

```ruby
Kazus.log @statement
```

to log

```
[KAZUS|debug] RELATED OBJECTS:       0| CLASS: Statement | ERRORS: User must exist, body can't be blank | INSPECT: #<Statement id: nil, user_id: nil, body: nil, created_at: nil, updated_at: nil> | TO_S: #<Statement:0x007faffcd962d8> |0
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kazus', git: 'git://github.com/esBeee/kazus.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kazus

## Configuration

### In general

You can configure kazus to use another logger than the default [Logger](http://ruby-doc.org/stdlib-2.1.0/libdoc/logger/rdoc/Logger.html). To do so, make sure to call `Kazus.configure` with a block, like

```ruby
Kazus.configuration do |config|
  config.logger = Rails.logger
end
```

to use [Rails.logger](http://guides.rubyonrails.org/debugging_rails_applications.html#what-is-the-logger-questionmark), for example.

### In rails

If you are using rails, you can simply run

```sh
$ rails generate kazus:install
```

to copy an initialzer file into `config/initializers/`.

## Usage

Kazus provides only one method:

### #Kazus.log

Can be called with an arbitrary amount of arguments without raising an exception. It doesn't make sense to call it without arguments, though. It'll log a warning in this case.

If there's only one argument given, it will be interpreted as an object to be inspected and logged at level :debug.

Else if the first argument is a valid log level, which is one of

  * 0, 1, 2, 3, 4 or 5

or

  * :debug, :info, :warn, :error, :fatal or :unknown

or

  * "debug", "info", "warn", "error", "fatal" or "unknown"

it will be interpreted as - surprise - log level. If it's anything else, every argument, including the first, will be interpreted as objects to be inspected. The log level will then default to :debug.

If the second argument is a string (while the first argument is a valid log level), it will be interpreted as the incident description (which only has a meaning for formatting of the log message). If it's anything else, it will be interpreted as an object to be inspected as all following arguments are, too.

The third and any following argument will always be interpreted as objects to be inspected.

### Pattern

All messages include the sequence of letters ```KAZUS```. I use this to parse the logs for important messages. If you want to parse for certain log levels, for example ```fatal```, the pattern is ```KAZUS|fatal```. Same goes for any other log level named above.

## Examples

You can call ```Kazus.log``` with just an array for quick debugging purposes:

```ruby
Kazus.log [1, "A"]
```

will output

```
[KAZUS|debug] RELATED OBJECTS:       0| CLASS: Array | COUNT: 2 | INSPECT: [1, "A"] |0
```


Or you can log an unexpected exception. Kazus includes the backtrace in such cases:

```ruby
Kazus.log :fatal, "An exception was thrown unexpectedly", exception
```

will output

```
[KAZUS|fatal] An exception was thrown unexpectedly -- RELATED OBJECTS:       0| CLASS: Exception | INSPECT: #<Exception: ThisException> | TO_S: ThisException | BACKTRACE: /A/k/o/llad.rb ### /B/k/o/llad.rb |0
```


If the last given argument is a hash, kazus titles each value with its key:

```ruby
Kazus.log "Number A" => 54, "Number B" => 32
```

will output

```
[KAZUS|debug] RELATED OBJECTS:       0.0| TITLE: Number A | CLASS: Fixnum | INSPECT: 54 |0.0       0.1| TITLE: Number B | CLASS: Fixnum | INSPECT: 32 |0.1
```


If you are using rails and you call ```Kazus.log``` with a model instance, its error messages get included in the logs:

```ruby
statement = Statement.new
statement.valid? # Generate error messages

Kazus.log :info, nil, statement
```

will output

```
[KAZUS|info] RELATED OBJECTS:       0| CLASS: NilClass | INSPECT: nil |0       1| CLASS: Statement | ERRORS: User must exist, body can't be blank | INSPECT: #<Statement id: nil, user_id: nil, body: nil, created_at: nil, updated_at: nil> | TO_S: #<Statement:0x007fb108353318> |1
```

## TODO

Right now, the log message gets created every time you call ```Kazus.log```, even if the app is configured to not log a message with a low level like the level you might have chosen for your ```Kazus.log``` call. I'll appreciate if anyone hints to a possible solution. Until then, you might not want to spread tons of ```Kazus.log(:debug)``` calls all over your app, but rather use it to log in unexpected situations or to quickly debug something, with the intention to remove the method call shortly after.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/esBeee/kazus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

