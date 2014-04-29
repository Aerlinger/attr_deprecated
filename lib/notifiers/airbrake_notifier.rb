module AttrDeprecated
  class AirbrakeNotifier
    def initialize(target)
      @target = target
    end

    def notify_airbrake(attribute)
      if defined?(Airbrake)
        Airbrake.notify Exception.new
                          "WARNING: Called deprecated attribute for #{klass.name}: #{attrs.join(', ')}\n" +
                          backtrace.map { |trace| "\t#{trace}" }.join("\n")

      end
    rescue
    end
  end
end
