module AttrDeprecated
  class DeprecatedAttributeLogger
    def initialize(target)
      @target = target
      super()
    end

    def logger
      @target.logger
    end

    def logger?
      @target.respond_to?(:logger) && @target.logger
    end

    def backtrace
      if defined? Rails
        Rails.backtrace_cleaner.clean(caller)
      else
        caller
      end
    end

    def log_deprecated_attribute_usage(klass, *attrs)
      warning_message = "WARNING: Called deprecated attribute on #{klass.name}: #{attrs.join(', ')}\n" +
        backtrace.map { |trace| "\t#{trace}" }.join("\n")
      #if logger?
      #  logger.warn do
      #    warning_message
      #  end
      #else
        puts warning_message
      #end
    end
  end
end
