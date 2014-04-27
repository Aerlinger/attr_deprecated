require "attr_deprecated/version"

require 'active_support'

module AttrDeprecated
  module Model

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def attr_deprecated(*attr_names)
        # TODO
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include AttrDeprecated::Model
end
