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
    # The original method (i.e. the one marked as deprecated) is wrapped in an alias that dispatches the notification.
    # (See the `around_alias` pattern. [Paolo Perotta. Metaprogramming Ruby, p. 121])
    #
    #
    def attr_deprecated(*attr_names)
      attr_names.each do |attr_name|
        original_getter = "_#{attr_name}_deprecated".to_sym
        #original_setter = "_#{attr_name}_deprecated=".to_sym

        attr_name.to_sym

        # TODO: Use alias_attribute from ActiveSupport to handle both getter and setter
        alias_method(original_getter, attr_name.to_sym)

        # The getter
        define_method attr_name.to_sym, -> do
          puts "WARNING: deprecated attribute #{original_getter} was called:"
          puts Thread.current.backtrace.join("\n")

          method(original_getter).call()
        end

        # TODO: The setter

      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include AttrDeprecated
end
