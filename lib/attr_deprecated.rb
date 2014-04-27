require "attr_deprecated/version"

require 'active_support'
require 'active_record'
require 'active_model'

module AttrDeprecated
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    ##
    # == attr_deprecated
    # class macro definition to non-destructively mark an attribute as deprecated.
    #
    # The original method (i.e. the one marked as deprecated) is renamed and wrapped in an alias that dispatches the notification.
    # (See the `around_alias` pattern. [Paolo Perotta. Metaprogramming Ruby, p. 121])
    #
    def attr_deprecated(*attr_names)
      attr_names.each do |attr_name|
        original_getter = "__#{attr_name}_deprecated".to_sym
        original_setter = "__#{attr_name}_deprecated=".to_sym

        # TODO: Use alias_attribute from ActiveSupport to handle both getter and setter

        #alias_method(original_setter, "#{attr_name}=".to_sym)

        # The getter
        unless defined?(attr_name.to_sym)
          define_method attr_name.to_sym, -> do
            puts "WARNING: deprecated attribute #{original_getter} was called:"
            puts Thread.current.backtrace.join("\n")

            method(original_getter).call()
          end
        end

        # The setter
        unless defined?("#{attr_name}=".to_sym)
          define_method "#{attr_name}=".to_sym, ->(value) do
            puts "WARNING: deprecated attribute #{original_setter} was called:"
            puts Thread.current.backtrace.join("\n")

            method(original_setter).call(value)
          end
        end

        alias_method(original_getter, attr_name.to_sym)
        alias_method(original_setter, "#{attr_name}=".to_sym)
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include AttrDeprecated
end
