module AttrDeprecated
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @configuration = Configuration.new
  end

  class Configuration
    attr_accessor :enable, :full_trace, :raise, :log, :slack

    def initialize
      @enabled       = true
      @full_trace   = false
      @raise        = false
      @rails_logger = { level: :debug, color: true }
    end
  end
end
