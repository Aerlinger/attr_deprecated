require "attr_deprecated/version"

require 'active_support'
require 'active_record'
require 'active_model'

module AttrDeprecated
  def self.included(base)
    base.send :extend, ClassMethods
  end

  @@attrs_deprecated = []

  module ClassMethods

    ##
    # == attr_deprecated
    # class macro definition to non-destructively mark an attribute as deprecated.
    #
    # The original method (i.e. the one marked as deprecated) is renamed and wrapped in an alias that dispatches the notification.
    # (See the `around_alias` pattern. [Paolo Perotta. Metaprogramming Ruby, p. 121])
    #
    def attr_deprecated(*attr_names)
      @@attrs_deprecated = attr_names

      @@attrs_deprecated.each do |original_attr_name|
        attributes = [original_attr_name,
                      "#{original_attr_name}=".to_sym]

        attributes.each do |attribute|
          set_attribute_as_deprecated attribute
        end
      end
    end

    def attrs_deprecated
      @@attrs_deprecated
    end

    def set_attribute_as_deprecated(attribute)
      original_getter = "__deprecated_#{attribute}".to_sym

      if instance_methods.include?(original_getter.to_sym)
        remove_method original_getter.to_sym
      end

      if instance_methods.include?(attribute.to_sym)
        alias_method(original_getter.to_sym, attribute.to_sym)

        define_method attribute.to_sym do |*args|
          msg = <<-MESSAGE
            WARNING: deprecated attribute #{original_getter} was called:
            #{Thread.current.backtrace.join("\n")}
          MESSAGE

          puts msg

          send(original_getter, *args)
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include AttrDeprecated
end
