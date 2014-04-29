require 'active_support/concern'

module AttrDeprecated
  module Configuration
    extend ActiveSupport::Concern

    included do
      add_config :log_environments
      add_config :exception_environments
      add_config :airbrake_environments
    end

    module ClassMethods
      def configure
        yield self
      end

      def add_config(value)
        @name = value if value
      end
    end
  end
end
