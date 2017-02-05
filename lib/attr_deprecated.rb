require 'active_support'

require "attr_deprecated/version"
require "attr_deprecated/configuration"

require "notifiers/deprecation_logger"
require "active_model/deprecated_attribute_set"

require 'active_record'
require 'active_model'

module AttrDeprecated
  extend ActiveSupport::Concern

  included do
    class_attribute :_deprecated_attributes, instance_writer: false
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
    def attr_deprecated(*attributes)
      attributes                  = DeprecatedAttributeSet.new(attributes.compact)
      self._deprecated_attributes ||= DeprecatedAttributeSet.new

      # Rails uses lazy initialization to wrap methods, so make sure we pre-initialize any deprecated attributes
      if defined?(ActiveRecord) && ancestors.include?(ActiveRecord::Base)

        # Initialize a new instance of our ActiveRecord model from `attributes`
        new(Hash[attributes.zip(attributes.map {})])
      end

      # Taking the difference of the two sets ensures we don't deprecate the same attribute more than once
      (attributes - _deprecated_attributes).each do |attribute|
        _set_attribute_as_deprecated attribute
      end

      self._deprecated_attributes += attributes
    end

    def deprecated_attribute?(attribute)
      _deprecated_attributes.include?(attribute)
    end

    def deprecated_attributes
      _deprecated_attributes || DeprecatedAttributeSet.new
    end

    def clear_deprecated_attributes!
      self._deprecated_attributes = _deprecated_attributes.clear
    end

    def _set_attribute_as_deprecated(attribute)
      original_method = instance_method(attribute.to_sym)

      klass = self
      define_method attribute.to_sym do |*args|
        klass._notify_deprecated_attribute_call(attribute)

        original_method.bind(self).call(*args)
      end
    end

    def _notify_deprecated_attribute_call(attribute)
      @_deprecation_logger ||= AttrDeprecated::DeprecatedAttributeLogger.new(self)

      @_deprecation_logger.log_deprecated_attribute_usage(self, attribute)
    end
  end
end

module AttrDeprecated
  class << self
    include AttrDeprecated::Configuration

    def configure(&block)
      AttrDeprecated::Configuration.configure(&block)
    end
  end
end

if defined? Rails || ENV['test']
  class ActiveRecord::Base
    include AttrDeprecated
  end

  require 'attr_deprecated/railtie.rb' if defined?(Rails)
end
