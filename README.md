# AttrDeprecated

A simple and non-intrusive way to mark deprecated columns/attributes in your models. Any usage of these attributes will logged with a warning message and a trace of where the deprecated attribute was called. An exception can be optionally raised as well.

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

    class User < ActiveRecord::Base
      attr_deprecated :some_shit_column, :some_other_shit_column

      ...
    end

    > User.attr_deprecated
    #<Set: {"some_shit_column", "some_other_shit_column"}>

    > User.attr_deprecated? :some_other_shit_column
    #true

    > User.first.some_shit_column
    # WARNING: User#some_shit_column is deprecated
    #
    # ...
    # .../.rvm/rubies/ruby-2.1.0/lib/ruby/2.1.0/irb.rb:396:in `start'
    # .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands/console.rb:47:in `start'
    # .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands/console.rb:8:in `start'
    # .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands.rb:41:in `<top (required)>'

## Configuration
Suppose you have a project with a `production`, `staging`, `development`, and `test` environment defined

    AttrDeprecated.configure do |config|
      config.do_logging only: [:production, :staging, :development, :test]
      config.do_exceptions only: [:production] # Can use except: [:d

      # Only if you're using Airbrake:
      config.do_airbrake only: [:production, :staging]
    end

## TODO:
Print relevant bindings as well

## Contributing

1. Fork it ( http://github.com/<my-github-username>/attr_deprecated/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
