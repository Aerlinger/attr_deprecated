# AttrDeprecated

A simple and non-intrusive way to mark deprecated columns/attributes in your models so they may be more safely removed.
Any usage of a deprecated attribute will be logged with a warning message and a trace of where the deprecated attribute
was called. Exceptions and Airbrake messages can be raised as well.

## Why?

Because we all have crap we don't want in our schema but are too afraid to remove.

## Installation

Add this line to your application's Gemfile:

    gem 'attr_deprecated'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attr_deprecated

## Usage

**In your model**

    class User < ActiveRecord::Base
      attr_deprecated :some_deprecated_column, :some_other_deprecated_column

      ...
    end

**Example**:

    > User.attr_deprecated
     => <DeprecatedAttributeSet: {"some_deprecated_column", "some_other_deprecated_column"}>
    >
    > User.attr_deprecated? :some_deprecated_column
     => true
    >
    > User.first.some_deprecated_column
    WARNING: Called deprecated attribute on User: some_deprecated_column
    .../.rvm/rubies/ruby-2.1.0/lib/ruby/2.1.0/irb.rb:396:in `start'
    .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands/console.rb:47:in `start'
    .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands/console.rb:8:in `start'
    .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands.rb:41:in `<top (required)>'
    ...


## TODO:

Add configuration:

Suppose you have a project with a `production`, `staging`, `development`, and `test` environment defined. You can define the behavior of attr_deprecated for each environment through the config params:

    AttrDeprecated.configure do |config|
      config.do_logging = [:production, :staging, :development, :test]
      config.do_exceptions = [:production]

      # Only if you're using Airbrake:
      config.do_airbrake = [:production, :staging]
    end


## Contributing

1. Fork it ( http://github.com/Aerlinger/attr_deprecated/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
