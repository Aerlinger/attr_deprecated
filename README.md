# attr_deprecated

A simple and non-intrusive way to mark deprecated columns/attributes in your models so they may be more safely removed.
Any usage of a deprecated attribute will be logged with a warning message with a trace of where the deprecated attribute
was called. Exceptions can be raised as well.

*AttrDeprecated is a work in progress*

## Why?

Because we all have crap we don't want in our schema but are too afraid to remove. Use `attr_deprecated` to mark specific
attributes in a model and will log a deprecation warning if the attribute is called in your code.

attr_deprecated will automatically hook into ActiveModel, however, it can also be used with plain-old Ruby classes.

## Installation

  gem 'attr_deprecated'

## Configuration

```ruby
AttrDeprecated.configure do |config|
  config.raise = false
  config.notifiers = {
    log: { level: :debug }
  }
end
```


## Usage

**In your model:**

```ruby
class User < ActiveRecord::Base
  attr_deprecated :some_deprecated_column, :some_other_deprecated_column

  ...
end
```

**Example**:

    > User.attr_deprecated
     => <DeprecatedAttributeSet: {"some_deprecated_column", "some_other_deprecated_column"}>
    >
    > User.attr_deprecated? :some_deprecated_column
     => true
    >
    > User.new.some_deprecated_column
    WARNING: Called deprecated attribute on User: some_deprecated_column
    .../.rvm/rubies/ruby-2.1.0/lib/ruby/2.1.0/irb.rb:396:in `start'
    .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands/console.rb:47:in `start'
    .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands/console.rb:8:in `start'
    .../.rvm/gems/ruby-2.1.0/gems/railties-3.2.17/lib/rails/commands.rb:41:in `<top (required)>'
    ...


## Contributing

1. Fork it ( http://github.com/Aerlinger/attr_deprecated/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
