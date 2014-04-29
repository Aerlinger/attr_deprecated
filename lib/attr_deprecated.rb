require "attr_deprecated/version"
require "notifiers/deprecation_logger"
require "active_model/deprecated_attribute_set"

require 'active_support/concern'
require 'active_record'
require 'active_model'

module AttrDeprecated
  extend ActiveSupport::Concern

  included do
    class_attribute :_deprecated_attributes, instance_writer: false

    @_deprecation_logger = AttrDeprecated::DeprecatedAttributeLogger.new(self)
  end

  module ClassMethods
    ##
    # == attr_deprecated
    #
    # class macro definition to non-destructively mark an attribute as deprecated.
    #
    # The original method (i.e. the one marked as deprecated) is renamed and wrapped in an alias that dispatches the notification.
    # (See the `around_alias` pattern. [Paolo Perotta. Metaprogramming Ruby, p. 121])
    #
    def attr_deprecated(*attr_names)
      attr_names = DeprecatedAttributeSet.new(attr_names.compact)
      self._deprecated_attributes ||= DeprecatedAttributeSet.new

      # Taking the difference of the two sets ensures we don't deprecate the same attribute more than once
      (attr_names - _deprecated_attributes).each do |attribute|
        _set_attribute_as_deprecated attribute
      end

      self._deprecated_attributes += attr_names
    end

    def deprecated_attributes
      _deprecated_attributes || DeprecatedAttributeSet.new
    end

    def clear_deprecated_attributes!
      self._deprecated_attributes = _deprecated_attributes.clear
    end

    def _set_attribute_as_deprecated(attribute)
      original_getter = "__deprecated_#{attribute}".to_sym

      if instance_methods.include?(attribute.to_sym)
        alias_method(original_getter.to_sym, attribute.to_sym)
        klass = self

        define_method attribute.to_sym do |*args|
          klass._notify_deprecated_attribute_call(klass, attribute)

          send(original_getter, *args)
        end
      end
    end

    def _notify_deprecated_attribute_call(klass, attribute)
      @_deprecation_logger.log_deprecated_attribute_usage(klass, attribute)
    end
  end
end

ActiveSupport.on_load(:active_record) do
  #require "active_record/"
end
