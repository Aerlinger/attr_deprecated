class DeprecatedAttributeLogger
  def initialize(target)
    @target = target
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

  def log_deprecated_attribute_usage(klass, attrs)
    if logger?
      logger.warn do
        "WARNING: Called deprecated attribute for #{klass.name}: #{attrs.join(', ')}\n" +
          backtrace.map { |trace| "\t#{trace}" }.join("\n")
      end
    end
  end
end
