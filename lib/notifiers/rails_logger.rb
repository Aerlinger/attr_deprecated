module AttrDeprecated
  class LogSubscriber < ActiveSupport::LogSubscriber

    def logger_config
      AttrDeprecated.configuration.try(:rails_logger) || {}
    end

    def log_color(text, color, bold = true)
      if logger_config[:color]
        color(text, color, bold)
      else
        text
      end
    end

    def log_method(msg, level = :info)
      case level
        when :debug
          debug(msg)
        when :info
          info(msg)
        when :warn
          warn(msg)
        when :error
          error(msg)
        when :fatal
          fatal(msg)
        else
          unknown(msg)
      end
    end

    def format_message(payload)
      formatted_backtrace = payload[:backtrace].join("\n")

      title         = log_color("DEPRECATION WARNING:", YELLOW)
      klass_str     = log_color(payload[:klass], CYAN)
      attribute_str = log_color(payload[:attribute], BLUE)
      args_str      = log_color(payload[:args], MAGENTA)

      ["\n#{title} `#{attribute_str}` was called from #{klass_str} with args: #{args_str}",
      formatted_backtrace].join("\n")
    end

    def deprecated_attributes(event)
      deprecation_message = format_message(event.payload)
      
      log_method(deprecation_message, logger_config[:level])
    end

    def logger
      ActiveRecord::Base.logger
    end
  end
end

AttrDeprecated::LogSubscriber.attach_to :active_record
